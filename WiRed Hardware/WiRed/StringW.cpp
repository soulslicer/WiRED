/*
 * StringW.cpp
 *
 * Created: 6/23/2013 12:33:34 PM
 *  Author: Raaj
 */ 


#include "StringW.h"

void testFunction(String& passString){
	passString+="asd";
}

boolean checkForString(String compare1, String compare2){
	int index=compare2.indexOf(compare1);
	if(index<0){
		return false;
	}else{
		//Serial.println("Contains: "+compare1+" : "+compare2);
		return true;
	}
}

void initializeString(String& passString,int type){
	switch(type){
		case LONG_STRING:{
			passString="";
			for(int i=0;i<140;i++) passString+=" ";
		//passString="                                                                                                    ";
		break;
		}		
		
		case SHORT_STRING:{
			passString="";
			for(int i=0;i<15;i++) passString+=" ";
		//passString="                    ";
		break;
		}		
	}
}

 String getValue(String& data, char separator, int index)
 {
	 int found = 0;
 int strIndex[] = {0, -1};
 int maxIndex = data.length()-1;

 for(int i=0; i<=maxIndex && found<=index; i++){
	 if(data.charAt(i)==separator || i==maxIndex){
		 found++;
		 strIndex[0] = strIndex[1]+1;
		 strIndex[1] = (i == maxIndex) ? i+1 : i;
	 }
 }

 return found>index ? data.substring(strIndex[0], strIndex[1]) : "";
}