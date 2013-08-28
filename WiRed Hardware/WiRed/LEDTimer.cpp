/*
 * LEDTimer.cpp
 *
 * Created: 5/26/2013 1:18:11 PM
 *  Author: Raaj
 */ 

#include "LEDTimer.h"

LEDTimer LEDFlasher;

 void LEDTimer::setLED(byte xLED1, byte xLED2){
	 
	LED1=xLED1;
	LED2=xLED2;
	LED1State=0;
	LED2State=0;
	pinMode(LED1, OUTPUT);
	pinMode(LED2, OUTPUT);
	
}

void LEDTimer::start(){
	
	timerState=true;
	Timer1.initialize(LEDBLINK_RATE);
	Timer1.attachInterrupt(timerISR);
	
}

void LEDTimer::stop(){
	timerState=false;
	Timer1.stop();
	Timer1.initialize(LEDSTOP_RATE);
}

void LEDTimer::resume(){
	
	timerState=true;
	Timer1.initialize(LEDBLINK_RATE);
	Timer1.resume();
	
}

void LEDTimer::quickFlash(){
	for(byte i=0;i<2;i++){
		digitalWrite(LED1,LOW);digitalWrite(LED2,LOW);
		delay(50);
		digitalWrite(LED1,HIGH);digitalWrite(LED2,HIGH);
		delay(50);
	}	
}

void LEDTimer:: quickSetLED(){
	
	if(LED1State==0)
		digitalWrite(LED1,LOW);
	else
		digitalWrite(LED1,HIGH);
	if(LED2State==0)
		digitalWrite(LED2,LOW);
	else
		digitalWrite(LED2,HIGH);
		
}

void LEDTimer::setState(byte xLED1State, byte xLED2State){
	
	LED1State=xLED1State;
	LED2State=xLED2State;
	
	if(((LED1State==2) && (LED2State==2))
	|| ((LED1State==0) && (LED2State==2))
	|| ((LED1State==2) && (LED2State==0))
	|| ((LED1State==0) && (LED2State==0))){
		stop();
		quickSetLED();
	}else{
		if(!timerState)
			resume();
	}		
	
}

void timerISR()
{
	switch(LEDFlasher.LED1State){
		
		case 0:
			digitalWrite(LEDFlasher.LED1,LOW);
			break;
		
		case 1:
			digitalWrite(LEDFlasher.LED1, digitalRead(LEDFlasher.LED1) ^ 1 );
			break;
		
		case 2:
			digitalWrite(LEDFlasher.LED1,HIGH);
			break;
		
		default:
			break;
	}
	
	switch(LEDFlasher.LED2State){
		
		case 0:
		digitalWrite(LEDFlasher.LED2,LOW);
		break;
		
		case 1:
		digitalWrite(LEDFlasher.LED2, digitalRead(LEDFlasher.LED2) ^ 1 );
		break;
		
		case 2:
		digitalWrite(LEDFlasher.LED2,HIGH);
		break;
		
		default:
		break;
	}

}

