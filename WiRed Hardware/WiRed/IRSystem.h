/*
 * IRSystem.h
 *
 * Created: 6/30/2013 11:35:16 AM
 *  Author: Raaj
 */ 


#ifndef IRSYSTEM_H_
#define IRSYSTEM_H_

#define RECV_PIN		8
#define KEYCODE_RAW		0
#define RAW_SIZE		132
#define IRTIMEOUT_TIME	10000

#define IR_DATACAP		0
#define IR_DATINV		1
#define IR_TIMEOUT		2

#include <avr/io.h>
#include <Arduino.h>
#include "IRremote.h"
#include "StringW.h"
#include "MemoryFree.h"
#include "LEDTimer.h"

using namespace std;

class IRSystem{
	public:
	IRSystem(int recvpin);
	uint8_t startReceiver(String& serverResp);
	void stopReceiver();
	
	String getStringForServer(int keyCode);
	void processAndExecuteString(String& fromServer);
	
	
	//private:
	IRrecv irrecv;
	IRsend irsend;
	
	decode_results results;

	unsigned long startTime;
	//int sendArray[RAW_SIZE];
	//int lengthOfArray;
	

	//void dump(decode_results *results);
	
};


#endif /* IRSYSTEM_H_ */