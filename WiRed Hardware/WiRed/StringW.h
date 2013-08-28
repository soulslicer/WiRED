/*
 * StringW.h
 *
 * Created: 6/23/2013 12:33:43 PM
 *  Author: Raaj
 */ 


#ifndef STRINGW_H_
#define STRINGW_H_

//Include Paths
#include <SoftwareSerial.h>
#include <Streaming.h>
#include <avr/pgmspace.h>
#include "MemoryFree.h"
#include "WString.h"

#define LONG_STRING		0
#define SHORT_STRING	1

using namespace std;

#ifdef __cplusplus
extern "C" {
	#endif

	void initializeString(String& passString,int type);
	boolean checkForString(String compare1, String compare2);
	String getValue(String& data, char separator, int index);

	#ifdef  __cplusplus
}

#endif
#endif
