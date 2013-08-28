/*
 * WiFlyRNXV.h
 *
 * Created: 2/19/2013 11:29:18 PM
 *  Author: Raaj
 */ 

#ifndef WIFLYRNXV_H_
#define WIFLYRNXV_H_

/************************************************************************
 * WiFly
 
 1. Clean WiFly serial driver written from scratch
 2. Used to interface with main class to send and receive data
 ************************************************************************/

//Include Paths
#include <SoftwareSerial.h>
#include <Streaming.h>
#include <avr/pgmspace.h>
#include "MemoryFree.h"
#include "StringW.h"
#include "IRSystem.h"

//RX TX Pins
#define ARDUINO_RX_PIN				2
#define ARDUINO_TX_PIN				3
#define IR_RECEIVEPIN				8

//Hardware settings
//#define MAX_SWITCHES				4

//Default ports settings for WiFly

//#define WIFLY_DEFAULT_REMOTE_PORT	80
//#define WIFLY_DEFAULT_LOCAL_PORT	2000
#define WIFLY_DEFAULT_BAUD_RATE		9600
//#define WIFLY_DEFAULT_DELAY			2000


//Char Buffer Sizes for Command and Response


//CMD Wait Times based on manual

#define COMMAND_MODE_GUARD_TIME 	300
#define TIMEOUT_TIME				3000


//Local Remote Server Address Port
//const char* const REMOTE_ADDRESS="192.168.1.2";
//const char* const REMOTE_PORT="2005";
//const char* const LOCAL_PORT="2000";

//Communication Keywords


//Define commands
const char* const COMMAND_MODE="$$$";
const char* const COMMAND_EXIT="exit";

//Sending Server Commands
#define SEND_REGISTER	0
#define SEND_UPDATE		1
#define SEND_INITREC	2
#define SEND_RCVCAPTD	3
#define SEND_SENT		4
#define SEND_IRTIMEOUT	5

//Receive Server Commands
#define REC_INVALID		0
#define REC_REGISTERED	1
#define REC_UPDATED		2
#define REC_INITSEND	3
#define REC_RCVMODE		4
#define REC_SNDMODE		5

//Get Commands
#define GET_IP			0
#define GET_DEVID		1

using namespace std;

class WiFlyRNXV{

	public:
	WiFlyRNXV(byte pinReceive, byte pinSend);					//Constructor with Pins for UART
	SoftwareSerial uart;										//SoftwareSerial driver
	IRSystem irSystem;
	
	void start();
	void end();
	void RebootWiFly();
	void EnterAdHoc();
	//void FactoryRESET();
	void SetUDPMode();
	void SetHTTPMode();
	void SendUDP(char* value);
	void ForceConnect(); // for debug mode
	int CheckUART();
	int ProcessResponse(char* buffer);
	//boolean NetworkConnected();
	boolean AdHocEnded();
	boolean EnterCommandMode();
	boolean ExitCommandMode();
	boolean CheckWiFiStatus();
	boolean AdHocConnected();
	boolean getIPValueFromWiFly();
	boolean setHostIP();
	boolean updateServer(uint8_t command);
	
	
	void listenAndProcess();
	String responseBuffer;

	private:
	boolean inCommandMode;
	boolean wifiStatus;
	String ipValue;
	
	//void getBufferResponse(int timeout);
	uint8_t processResponse(bool removeOpen);
	String processActualResponse(uint8_t receivedCmd);
	uint8_t sendTCPString(String data,uint8_t command);
	boolean checkBufferResponse(String compareValue,int timeout);
	boolean getDataType(String& fillBuff,int action);
};



#endif /* WIFLYRNXV_H_ */