/*
 * LEDTimer.h
 *
 * Created: 5/26/2013 1:17:20 PM
 *  Author: Raaj
 */ 


#ifndef LEDTIMER_H_
#define LEDTIMER_H_

#define LEDBLINK_RATE	400000
#define LEDSTOP_RATE	5000000

#include <Arduino.h>
#include "TimerOne.h"

using namespace std;
const byte LEDON	=	2;
const byte LEDOFF	=	0;
const byte LEDBLINK	=	1;

class LEDTimer{

	public:
		void setLED(byte xLED1, byte xLED2);
		void start();
		void setState(byte xLED1State, byte xLED2State);
		void stop();
		void resume();
		byte LED1;
		byte LED2;
		
		//0-Off 1-Blink 2-On
		bool timerState;
		byte LED1State;
		byte LED2State;
		void quickSetLED();
		void quickFlash();
};

extern LEDTimer LEDFlasher;
void timerISR();

#endif /* LEDTIMER_H_ */
