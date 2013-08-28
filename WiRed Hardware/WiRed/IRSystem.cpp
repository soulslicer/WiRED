/*
* IRSystem.cpp
*
* Created: 6/30/2013 11:35:25 AM
*  Author: Raaj
*/

#include "IRSystem.h"

IRSystem::IRSystem(int recvpin):irrecv(recvpin){
	//irrecv.stop();
	//1650,550,350,500
//sendArray[RAW_SIZE]={0};
	//sendArray={33,11,7,10};
}


String IRSystem::getStringForServer(int keyCode){
	if(keyCode==-1) keyCode=KEYCODE_RAW;
	String finalString;
	boolean done=false;
	switch(keyCode){
		case KEYCODE_RAW:{
			finalString=String(KEYCODE_RAW);
			finalString+="-";
			finalString+=String((char)(results.rawlen+33));
			finalString+="-";
			for(int i=0;i<results.rawlen;i++){
				char x=(char)(results.rawbuf[i]+33);
				finalString+=String(x);
			}
			Serial.println("RAW");
			done=true;
			break;
		}
		
		case PANASONIC:{
			Serial.println(results.panasonicAddress,DEC);
			finalString=String(PANASONIC);
			finalString+="-";
			finalString+=String(results.panasonicAddress,DEC);
			finalString+="-";
			finalString+=String(results.value,DEC);
			Serial.println("PANASONIC");
			done=true;
			break;
		}	
	}
	
	if(!done){
	finalString=String(keyCode);
	finalString+="-";
	finalString+=String(results.bits,DEC);
	finalString+="-";
	finalString+=String(results.value,DEC);
	Serial.println("OTHER VALID");
	}	
	
	return finalString;
}

//0-3-550/350/500
void IRSystem::processAndExecuteString(String& fromServer){
	byte keyCode=fromServer[0]-'0';
	Serial.println(keyCode,DEC);

	//- is 45
	if(keyCode==KEYCODE_RAW){
		
		byte numLoops=3;
		char loopChar=fromServer[1];
		if(loopChar!='-')
			numLoops=(byte)(fromServer[1]-33);
			
		byte dataCount=((byte)(fromServer[2])-33);
		Serial.println(dataCount,DEC);
		Serial.println(numLoops,DEC);
		
		//unsigned int *sendArray = new unsigned int[RAW_SIZE];
		unsigned int sendArray[RAW_SIZE]={0};
			
		for(byte i=5;i<(dataCount+4);i++){
			char charInt=fromServer[i];
			Serial.print(charInt);
			int analogVal=(int)charInt-33;
			sendArray[i-5]=analogVal*USECPERTICK;
		}
		Serial.println("END");
		
		for(byte i=0;i<numLoops;i++){
			irsend.sendRaw(sendArray,dataCount-1,38);
			delay(200);
		}	
		
		//delete [] sendArray;
		
	}else{
		Serial.println(freeMemory());
		byte loc;
		for(byte i=2;i<fromServer.length();i++){
			if(fromServer[i]=='-'){
				loc=i;
				break;
			}
		}
		
		int bits=fromServer.substring(2,loc).toInt();
		unsigned long val=fromServer.substring(loc+1,fromServer.length()).toInt();
		
		//int bits=getValue(fromServer,'-',1).toInt();
		//unsigned long val=getValue(fromServer,'-',2).toInt();
		Serial.println(bits,DEC);
		Serial.println(val,DEC);
		
		if(keyCode==NEC){
			Serial.println("NEC");
			irsend.sendNEC(val,bits);
		}else if(keyCode==PANASONIC){
			Serial.println("PANASONIC");
			irsend.sendPanasonic(bits,val);
		}else if(keyCode==SONY){
			Serial.println("SONY");
			irsend.sendSony(bits,val);
		}else if(keyCode==RC5){
			Serial.println("RC5");
			irsend.sendRC5(bits,val);
		}else if(keyCode==RC6){
			Serial.println("RC6");
			irsend.sendRC6(bits,val);
		}
	}			
}

/*
void IRSystem::dump(decode_results *results) {
	int count = results->rawlen;
	if (results->decode_type == UNKNOWN) {
		Serial.print("Unknown encoding: ");
	}
	else if (results->decode_type == NEC) {
		Serial.print("Decoded NEC: ");
	}
	else if (results->decode_type == SONY) {
		Serial.print("Decoded SONY: ");
	}
	else if (results->decode_type == RC5) {
		Serial.print("Decoded RC5: ");
	}
	else if (results->decode_type == RC6) {
		Serial.print("Decoded RC6: ");
	}
	else if (results->decode_type == PANASONIC) {
		Serial.print("Decoded PANASONIC - Address: ");
		Serial.print(results->panasonicAddress,HEX);
		Serial.print(" Value: ");
	}
	else if (results->decode_type == JVC) {
		Serial.print("Decoded JVC: ");
	}
	Serial.print(results->value, HEX);
	Serial.print(" (");
	Serial.print(results->bits, DEC);
	Serial.println(" bits)");
	Serial.print("Raw (");
	Serial.print(count, DEC);
	Serial.print("): ");

	for (int i = 0; i < count; i++) {
		if ((i % 2) == 1) {
			Serial.print(results->rawbuf[i]*USECPERTICK, DEC);
		}
		else {
			Serial.print(-(int)results->rawbuf[i]*USECPERTICK, DEC);
		}
		Serial.print(" ");
	}
	Serial.println("");
}
*/

//first time length match second time length
uint8_t IRSystem::startReceiver(String& serverResp){
	uint8_t returnType=IR_DATINV;
	Serial.println("Receiver waiting..");
	irrecv.enableIRIn();
	while(1){
		if (irrecv.decode(&results)) {
			//dump(&results);
			Serial.println(results.rawlen);
			
			if(results.rawlen>15){
				serverResp=getStringForServer(results.decode_type);
				returnType=IR_DATACAP;
				LEDFlasher.quickFlash();
				break;
			}else{
				returnType=IR_DATINV; break;
			}
		}		
		
		if((millis()-startTime)>IRTIMEOUT_TIME){
			LEDFlasher.quickFlash();
			returnType=IR_TIMEOUT; break;
		}

	}
	irrecv.stop();	
	Serial.println("Receiver end");
	return returnType;
}

void IRSystem::stopReceiver(){
	irrecv.stop();
}

