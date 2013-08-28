/*
 * WiRed.cpp
 *
 * Created: 5/20/2013 10:52:25 PM
 *  Author: Raaj
 */ 

/* Includes and System Definitions */
#include <avr/io.h>
#include <Arduino.h>
#define F_CPU 16000000
#define ARDUINO 100
#include "WiFlyRNXV.h"
#include "LEDTimer.h"
#include "MemoryFree.h"

/* Code Definitions */
#define ADHOCPIN2	0
#define WIFLYRX		4
#define WIFLYTX		5
#define LED1		6
#define LED2		7

/* States */
//Program States
enum State {
	CONNECTED1,		//Connected to a wifi network - Get IP
	CONNECTED2,		//Register with server - Check validity
	CONNECTED3,		//Next State
	DISCONNECTED,	//No WiFi
	ADHOCCONNECT,	//In Ad-hoc mode, waiting for connection to WiFly
	ADHOCON,		//Connected, waiting for username and password response from App
	ADHOCEND,		//Data received, moving to check Wifi state
	UNKNOWNS			//Unknown state, currently no handle
};
State state=UNKNOWNS;

/* Objects and Variables */
WiFlyRNXV wiFly(WIFLYTX, WIFLYRX);
bool connected=false;
bool interrupted=false;
bool adhocsetbefore=false;

/* Function prototypes (START AT SETUP) */
void setup();
void loop();
void updateWiFi();

//Check WiFi Status
void updateWiFi(){
	State startState=CONNECTED1;
	LEDFlasher.setState(LEDBLINK,LEDOFF);
	bool wiFiStatus=wiFly.CheckWiFiStatus();
	if(wiFiStatus)
		state=startState;
	else
		state=DISCONNECTED;

	Serial.print("WiFi: ");
	Serial.println(wiFiStatus);
	
	if(state==startState){
		delay(4000);
		//wiFly.uart.flush();
		Serial.println("Ready to roll");
	}
}

//Interrupt
void interruptAdHoc(){
	static unsigned long last_interrupt_time = 0;
	unsigned long interrupt_time = millis();
	// If interrupts come faster than 200ms, assume it's a bounce and ignore
	if (interrupt_time - last_interrupt_time > 200){
		interrupted=true;
	}
	last_interrupt_time = interrupt_time;
}

void setup() {
	pinMode(13, OUTPUT);
	LEDFlasher.setLED(LED1,LED2);
	LEDFlasher.setState(LEDOFF,LEDOFF);
	LEDFlasher.start();
	
	Serial.begin(9600);
	Serial.println("Starting System..");
	
	wiFly.start();
	delay(2000);
	wiFly.ExitCommandMode();
	wiFly.RebootWiFly();
	updateWiFi();
	
	attachInterrupt(ADHOCPIN2, interruptAdHoc, RISING);
}

void loop() {
	
	if(interrupted){
		LEDFlasher.setState(LEDOFF,LEDBLINK);
		interrupted=false;
		Serial.println("Adhoc made activating..");
		wiFly.EnterAdHoc();
		Serial.println("Adhoc active");
		state=ADHOCCONNECT;
		LEDFlasher.setState(LEDOFF,LEDON);
		adhocsetbefore=true;
	}
	
	switch(state){
		case DISCONNECTED:
			updateWiFi();
			break;
			
		case ADHOCCONNECT:{
			if(wiFly.AdHocConnected()){
				state=ADHOCON;
				delay(3000);
				wiFly.uart.flush();
				Serial.println("Ready for Android/iOS");
				LEDFlasher.setState(LEDON,LEDON);
			}
			break;
		}
		
		case ADHOCON:{
			if(wiFly.AdHocEnded()){
				LEDFlasher.setState(LEDOFF,LEDOFF);
				state=DISCONNECTED;
				break;
			}
			break;
		}			
		
		case CONNECTED1:{
			delay(3000);
			if(wiFly.getIPValueFromWiFly())
				Serial.println("Got IP");
			else
				Serial.println("Failed IP");
				
			if(adhocsetbefore){
				delay(1000);
				if(wiFly.setHostIP())
					Serial.println("Host IP Set");
				else
					Serial.println("Failed to set host IP");
			}				
			
			state=CONNECTED2;
			LEDFlasher.setState(LEDON,LEDBLINK);
			break;
		}			
		
		case CONNECTED2:{
			delay(3000);
			if(adhocsetbefore){
				adhocsetbefore=false;
				if(wiFly.updateServer(SEND_REGISTER)){
					Serial.println("SUCCESS");
					LEDFlasher.setState(LEDON,LEDON);
					LEDFlasher.stop();
					state=CONNECTED3;
				}else{
					Serial.println("FAIL");
					LEDFlasher.setState(LEDBLINK,LEDBLINK);
					state=UNKNOWNS;					
				}				
			}else{
				if(wiFly.updateServer(SEND_UPDATE)){
					Serial.println("SUCCESS");
					LEDFlasher.setState(LEDON,LEDON);
					LEDFlasher.stop();
					state=CONNECTED3;
				}else{
					Serial.println("FAIL");
					LEDFlasher.setState(LEDBLINK,LEDBLINK);
					state=UNKNOWNS;					
				}					
			}
			
			delay(1000);
			Serial.println(freeMemory());
			break;
		}		
		
		case CONNECTED3:{
			wiFly.listenAndProcess();
			//wiFly.end();
			
			//state=UNKNOWNS;
			break;	
		}			
		
		case UNKNOWNS:
			break;

		default:
			break;
	}
	
		/*
	digitalWrite(13, HIGH);
	delay(500);
	digitalWrite(13, LOW);
	delay(500);
	Serial.println("Hello World!");
	*/
	
	/*
	while(wifly.uart.available()){
		Serial.print(wifly.uart.read());
	}
	*/
	
}