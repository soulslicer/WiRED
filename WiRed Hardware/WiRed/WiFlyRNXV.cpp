/*
* WiFlyRNXV.cpp
*
* Created: 2/19/2013 11:39:21 PM
*  Author: Raaj, Ivan
*/

#include "WiFlyRNXV.h"

//Constructor-Start listen on uart
WiFlyRNXV::WiFlyRNXV(byte pinReceive, byte pinSend) : uart (pinReceive, pinSend),irSystem(IR_RECEIVEPIN){
	initializeString(responseBuffer,LONG_STRING);
	initializeString(ipValue,SHORT_STRING);
	inCommandMode=false;
	wifiStatus=false;
}

void WiFlyRNXV::start(){
	uart.begin(WIFLY_DEFAULT_BAUD_RATE);
	uart.listen();
	uart.flush();
}

void WiFlyRNXV::end(){
	uart.end();
}



//Check buffer with a particular. always stops at $
boolean WiFlyRNXV::checkBufferResponse(String compareValue,int timeout){

	//NULL case
	boolean noCase=false;
	if(compareValue==NULL) noCase=true;
	initializeString(responseBuffer,LONG_STRING);

	//Variables
	//char* responseBuffer;										//Buffer for response
	boolean bufRead = true;										//Finish Reading
	int  bufpos = 0;											//Buffer position
	char chResponse = 'A';										//Initial character response
	boolean compareSuccess=false;								//Compare Success

	//Fill the buffer
	unsigned long startTime = millis();
	while(bufRead){
		
		//Start getting values
		if(uart.available()){
			chResponse = uart.read();
			//Serial.print(chResponse);
			
			//Keep reading until $ seen
			if(noCase){
				if(chResponse=='$'){
					compareSuccess=true;
					break;
				}
			}

			//Place into String
			if(bufpos<100){
				responseBuffer[bufpos]=chResponse;
				bufpos++;
			}else{
				Serial.println("Overflow");
				bufpos=0;
			}


		}
		
		//Check for existence of the comparison string, or if timeout stop
		if(checkForString(compareValue,responseBuffer) && noCase==false){
			compareSuccess=true;
			bufRead=false;
		}else if((millis()-startTime)>timeout){
			compareSuccess=false;
			bufRead=false;
		}
	}
	
	uart.flush();
	//if(compareSuccess)Serial.println("Found: "+compareValue);
	//else Serial.println("Not found: "+compareValue);
	
	return compareSuccess;
}


//Enter Command Mode
boolean WiFlyRNXV::EnterCommandMode(){
	uart.flush();
	uart.print(COMMAND_MODE);
	delay(COMMAND_MODE_GUARD_TIME);
	if(checkBufferResponse("CMD",TIMEOUT_TIME))
	inCommandMode=true;
	else
	inCommandMode=false;
	
	return inCommandMode;
}

//Exit Command Mode
boolean WiFlyRNXV::ExitCommandMode(){
	uart.println("exit");
	delay(COMMAND_MODE_GUARD_TIME);
	inCommandMode=false;
	
	return inCommandMode;
}

//Exit Command Mode
void WiFlyRNXV::RebootWiFly(){
	if(!inCommandMode)	EnterCommandMode();
	delay(100);
	uart.print("reboot\r");
	inCommandMode=false;
}

//Check WiFi Status
boolean WiFlyRNXV::CheckWiFiStatus(){
	
	if(inCommandMode){
		ExitCommandMode();
		delay(1000);
	}
	
	if(checkBufferResponse("Associated!",TIMEOUT_TIME))
	wifiStatus=true;
	else
	wifiStatus=false;
	
	
	return wifiStatus;
}

/*
void WiFlyRNXV::FactoryRESET(){
	if(!inCommandMode)	EnterCommandMode();
	int delayW=500;
	delay(delayW);
	
	Serial.println("factory RESET"); uart.flush();
	uart.println("factory RESET"); delay(delayW);
	Serial.println("reboot"); uart.flush();
	uart.println("reboot"); delay(delayW);
	delay(2000);
	Serial.println("Factory RESET done");
	inCommandMode=false;
}
*/

void WiFlyRNXV::EnterAdHoc(){
	
	initializeString(ipValue,SHORT_STRING);

	int delayW=500;
	
	if(!inCommandMode)	EnterCommandMode();
	
	delay(1000);
	// Setup adhoc network
	Serial.println("set ip address 169.254.1.1"); uart.flush();
	uart.println("set ip address 169.254.1.1"); delay(delayW);
	Serial.println("set ip netmask 255.255.0.0"); uart.flush();
	uart.println("set ip netmask 255.255.0.0"); delay(delayW);
	Serial.println("set ip dhcp 0"); uart.flush();
	uart.println("set ip dhcp 0"); delay(delayW);
	Serial.println("set ip proto 2"); uart.flush();
	uart.println("set ip proto 2"); delay(delayW);
	Serial.println("set wlan ssid WiRED"); uart.flush();
	uart.println("set wlan ssid WiRED"); delay(delayW);
	Serial.println("set wlan channel 1"); uart.flush();
	uart.println("set wlan channel 1"); delay(delayW);

	// Create adhoc network
	Serial.println("set wlan join 4"); uart.flush();
	uart.println("set wlan join 4"); delay(delayW);
	Serial.println("save"); uart.flush();
	uart.println("save"); delay(delayW);
	Serial.println("reboot"); uart.flush();
	uart.println("reboot"); delay(delayW);
	delay(2000);
	
	inCommandMode=false;
	
	uart.flush();
	Serial.println("Done AdHoc");
}

/*
boolean WiFlyRNXV::NetworkConnected(){
	boolean check=false;
	if(uart.available()){
		Serial.println("Checking if connected");
		check=checkBufferResponse("OK",TIMEOUT_TIME);
	}
	if(check){
		Serial.println("Connected!!!");
		return true;
	}else{
		return false;
	}
}
*/

boolean WiFlyRNXV::AdHocConnected(){
	boolean check=false;
	if(uart.available()) check=checkBufferResponse("Connected",TIMEOUT_TIME);
	if(check)
	return true;
	else
	return false;
}

boolean WiFlyRNXV::AdHocEnded(){
	boolean check=false;
	if(uart.available()){
		check=true;
		Serial.println("Data Received..Rebooting");
		uart.flush();
	}
	
	return check;
}


boolean WiFlyRNXV::getDataType(String& fillBuff,int action){
	initializeString(fillBuff,SHORT_STRING);
	
	if(!inCommandMode)	EnterCommandMode();
	
	String delimit;
	if(action==GET_IP){
		delimit="IP=";
		uart.println("get ip");
	}else if(action==GET_DEVID){
		delimit="d=";
		uart.println("show deviceid");
	}		
	
	boolean bufRead = true;										//Finish Reading
	boolean ipReadMode = false;									//Ready to write in IP
	boolean ipReadOver = false;									//Finished writing IP
	int  bufpos = 0;											//Buffer position
	char chResponse = 'A';										//Initial character response
	boolean compareSuccess=false;								//Compare Success
	int timeout=5000;											//Timeout value fixed

	//Fill the buffer
	unsigned long startTime = millis();
	while(bufRead){
		
		//Start getting values
		if(uart.available()){
			chResponse = uart.read();
			//Serial.print(chResponse);
			
			//Stop at character :
			if(chResponse==':'){
				ipReadOver=true;
				break;
			}

			if(ipReadMode==false){
				responseBuffer[bufpos]=chResponse;
			}else{
				fillBuff[bufpos]=chResponse;
			}
			bufpos++;
			
		}

		//Check for existence of the comparison string, or if timeout stop
		if(checkForString(delimit,responseBuffer) && ipReadMode==false){
			ipReadMode=true;
			bufpos=0;
		}else if((millis()-startTime)>timeout){
			compareSuccess=false;
			bufRead=false;
		}
	}
	
	if(ipReadOver==true){
		//ipValue.trim();
		ipValue.replace(" ","");
		Serial.print("IPVAL:");
		Serial.println(fillBuff);
		compareSuccess=true;
		delay(200);
		ExitCommandMode();
	}
	
	uart.flush();
	return compareSuccess;	
}

boolean WiFlyRNXV::setHostIP(){
	String hostIP;
	boolean getBool=getDataType(hostIP,GET_DEVID);
	if(getBool){
		EnterCommandMode();
		delay(500);
		String finalString="set ip host "+hostIP;
		Serial.println(finalString);
		uart.println(finalString);
		delay(500);
		uart.println("save");
		delay(500);
		ExitCommandMode();
		return true;
	}else{
		return false;
	}
}

boolean WiFlyRNXV::getIPValueFromWiFly(){
	return getDataType(ipValue,GET_IP);
}


uint8_t WiFlyRNXV::processResponse(bool removeOpen){
	if(removeOpen) responseBuffer.replace("*OPEN*","");
	responseBuffer=getValue(responseBuffer,'\n',0);
	String commandStr=responseBuffer.substring(0,1);
	uint8_t command=commandStr.toInt();
	responseBuffer=responseBuffer.substring(2,responseBuffer.length());
	return command;
}

//ResponseBuffer will be updated
uint8_t WiFlyRNXV::sendTCPString(String data,uint8_t command){
	
	bool status=false;
	uint8_t resp=0;
	
	initializeString(responseBuffer,LONG_STRING);
	
	Serial.print("SEND:");
	Serial.println(data);
	
	if(!inCommandMode)	EnterCommandMode();
	
	delay(500);
	uart.println("open");
	
	if(checkBufferResponse("*OPEN*",5000)){
		delay(300);
		uart.print(command,DEC);
		uart.print(":");
		uart.println(data);
	}
	
	if(checkBufferResponse("*CLOS*",5000)){
		Serial.print("RESP:");
		//Serial.println("TEST: "+responseBuffer);
		resp=processResponse(false);
		Serial.println(resp,DEC);
		Serial.print("RECV:");
		Serial.println(responseBuffer);
		status=true;
	}else{
		status=false;
	}
	
	//delete data;
	inCommandMode=false;
	return resp;
}

boolean WiFlyRNXV::updateServer(uint8_t command){
	boolean returnBool=false;
	switch(command){
		case SEND_REGISTER:{
			Serial.println("Sending server register");
			uint8_t resp=sendTCPString(ipValue,SEND_REGISTER);
			if(resp==REC_REGISTERED) returnBool=true;
			else returnBool=false;
			break;
		}
		case SEND_UPDATE:{
			Serial.println("Sending server update");
			uint8_t resp=sendTCPString(ipValue,SEND_UPDATE);
			if(resp==REC_UPDATED) returnBool=true;
			else returnBool=false;
			ipValue="";
			break;
		}
	}
	
	return returnBool;
}

String WiFlyRNXV::processActualResponse(uint8_t receivedCmd){
	String finalString;
	switch(receivedCmd){
		case REC_INITSEND:{
			String cmdString=String(SEND_INITREC);
			LEDFlasher.quickFlash();
			finalString=cmdString+":"+"Verified";
			break;
		}			
		
		case REC_RCVMODE:{
			String cmdString=String(SEND_RCVCAPTD);
			
			boolean keepChecking=true;
			responseBuffer="";
			irSystem.startTime=millis();
			LEDFlasher.quickFlash();
			while(keepChecking){
				uint8_t type=irSystem.startReceiver(responseBuffer);
				if(type==IR_DATACAP) keepChecking=false;
				else if(type==IR_DATINV) keepChecking=true;
				else if(type==IR_TIMEOUT){
					cmdString=String(SEND_IRTIMEOUT);
					responseBuffer="Timeout";
					keepChecking=false;
				}

				delay(100);
			}
			Serial.println("done");
			finalString=cmdString+":"+responseBuffer;
			break;
		}
		
		case REC_SNDMODE:{
			String cmdString=String(SEND_SENT);
			LEDFlasher.quickFlash();
			Serial.println("Sending..");
			irSystem.processAndExecuteString(responseBuffer);
			finalString=cmdString+":"+"Sent";
			break;
		}
	}
	return finalString;
}


void WiFlyRNXV::listenAndProcess(){
	uint8_t resp=0;
	
	if(uart.available()){
		if(checkBufferResponse(NULL,5000)){
			Serial.println("TCP OPEN");
			Serial.print("RESP:");
			resp=processResponse(true);
			Serial.println(resp,DEC);
			Serial.print("RECV:");
			responseBuffer.trim();
			Serial.println(responseBuffer);
			
			//Send some data
			uart.println(processActualResponse(resp));
			
			if(checkBufferResponse("*CLOS*",5000)){
				Serial.println("TCP CLOSE");
			}

		}
		
	}
	
	
}
