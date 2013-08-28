package MainPackage;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketAddress;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.concurrent.TimeUnit;

import org.h2.jdbcx.JdbcDataSource;



public class Logic {

	public static final String NULL="NULL";
	public static final String SPLITTER=":";
	public static final String COMMAND="CMD";
	public static final String SQL="SQL";
	public static final String TCP="TCP";
	public static final String DB="DB";

	public static final String ADDUSER="ADD";
	public static final String UNTIEUSER="UNTIE";
	public static final String TIEUSER="TIE";
	public static final String CHECKUSER="CHECK";
	public static final String UPDATEUSER="UPDATE";
	public static final String CHECKTIED="CHECKTIED";

	public static final int EXIT = 1;
	public static final int OTHER = 2;
	public static final int INVALID = 3;

	//(to return to phone)
	public static final int PHONERET_WRONGUSERPASS=0;
	public static final int PHONERET_IPNOTFOUND=1;
	public static final int PHONERET_TIMEOUT=2;
	public static final int PHONERET_DATAERROR=3;
	public static final int PHONERET_VERIFYSUCCESS=4;
	public static final int PHONERET_IRTIMEOUT=5;

	public static final int PHONESEND_VERIFYSEND=0;
	public static final int PHONESEND_IRRECEIVE=1;
	public static final int PHONESEND_IRSNDMODE=2;

	//(device to server)
	public static final int SEND_REGISTER = 0;
	public static final int SEND_UPDATE = 1;
	public static final int SEND_INITREC = 2;
	public static final int SEND_RCVCAPTD = 3;
	public static final int SEND_SENT = 4;
	public static final int SEND_IRTIMEOUT = 5;

	public static final int REC_INVALID = 0;
	public static final int REC_REGISTERED = 1;
	public static final int REC_UPDATED = 2;
	public static final int REC_INITSEND=3;
	public static final int REC_RCVMODE=4;
	public static final int REC_SNDMODE=5;
	
	public static BlockerCheck blockerCheck=new BlockerCheck();
	
	public static int nthOccurrence(String str, char c, int n) {
	    int pos = str.indexOf(c, 0);
	    while (n-- > 0 && pos != -1)
	        pos = str.indexOf(c, pos+1);
	    return pos;
	}

	public static int sendToDevice(String username,String password,int command,String data,StringBuffer getData){

		//check if valid user pass
		if(!DatabaseHandler.checkValidUser(username, password))
			return PHONERET_WRONGUSERPASS;

		//get the public ip
		String publicIP=DatabaseHandler.getPublicIP(username);
		if(publicIP.equals(NULL))
			return PHONERET_IPNOTFOUND;

		//send to device - response as 1:data
		String deviceResponse; String deviceData;
		int deviceCommand;
		switch(command){
		case PHONESEND_VERIFYSEND:{

			//Send Message
			deviceResponse=sendMessage(REC_INITSEND, data, 2000, publicIP);
			if(deviceResponse.equals(NULL))
				return PHONERET_TIMEOUT;

			//Split it
			try{
				String[] parts = deviceResponse.split(SPLITTER);
				deviceCommand = Integer.parseInt(parts[3]);
				deviceData=parts[4];
				//getData.append(deviceData);
			}catch(ArrayIndexOutOfBoundsException e){
				e.printStackTrace();
				return PHONERET_DATAERROR;
			}

			//Check if correct response
			if(deviceCommand==SEND_INITREC)
				return PHONERET_VERIFYSUCCESS;
			else
				return PHONERET_DATAERROR;
		}

		case PHONESEND_IRRECEIVE:{

			//Send Message
			deviceResponse=sendMessage(REC_RCVMODE, data, 2000, publicIP);
			if(deviceResponse.equals(NULL))
				return PHONERET_TIMEOUT;

			//Split it
			try{
				int occurResp=nthOccurrence(deviceResponse, ':', 2);
				deviceCommand=Integer.parseInt(deviceResponse.substring(occurResp+1, occurResp+2));
				deviceData=deviceResponse.substring(occurResp+3, deviceResponse.length());
				getData.append(deviceData);
				if(deviceCommand==SEND_IRTIMEOUT)
					return PHONERET_IRTIMEOUT;
				
			}catch(ArrayIndexOutOfBoundsException e){
				e.printStackTrace();
				return PHONERET_DATAERROR;
			}

			//Check if correct response
			if(deviceCommand==SEND_RCVCAPTD)
				return PHONERET_VERIFYSUCCESS;
			else
				return PHONERET_DATAERROR;

		}

		case PHONESEND_IRSNDMODE:{

			//Send Message
			deviceResponse=sendMessage(REC_SNDMODE, data, 2000, publicIP);
			if(deviceResponse.equals(NULL))
				return PHONERET_TIMEOUT;

			//Split it
			try{
				//user:pass:device:data
				String[] parts = deviceResponse.split(SPLITTER);
				deviceCommand = Integer.parseInt(parts[3]);
				deviceData=parts[4];
				//getData.append(deviceData);
			}catch(ArrayIndexOutOfBoundsException e){
				e.printStackTrace();
				return PHONERET_DATAERROR;
			}

			//Check if correct response
			if(deviceCommand==SEND_SENT)
				return PHONERET_VERIFYSUCCESS;
			else
				return PHONERET_DATAERROR;

		}
		}




		return 0;
	}

	public static String processFromDevice(String input,String publicIPVal){

		//Variables
		int command=0;
		int returnVal=REC_INVALID;
		String dataString=null;

		//Get the public IPVal
		try{
			String[] parts = publicIPVal.split(SPLITTER);
			publicIPVal = parts[0];
			publicIPVal=publicIPVal.replace("/", "");
			System.out.println("Data received from PublicIP: "+publicIPVal);
		}catch(ArrayIndexOutOfBoundsException e){
			e.printStackTrace();
		}

		//Get required data
		String username = null;String password = null;String deviceKey = null;String strCommand;String data = null;
		try{
			String[] parts = input.split(SPLITTER);
			username = parts[0];
			password = parts[1];
			deviceKey = parts[2];
			strCommand = parts[3];
			data=parts[4];
			command=Integer.parseInt(strCommand);
		}catch(ArrayIndexOutOfBoundsException e){
			e.printStackTrace();
		}

		//Check command type
		switch(command){
		case SEND_REGISTER:{
			returnVal=DatabaseHandler.addUser(username, password, deviceKey, data, publicIPVal, "0");
			if(returnVal==DatabaseHandler.USER_ADDED){ dataString="Registered"; returnVal=REC_REGISTERED; }
			else { System.out.println("ERROR:"+returnVal); dataString="Failed to Register"; returnVal=REC_INVALID; }
			break;
		}

		case SEND_UPDATE:{
			returnVal=DatabaseHandler.updateUser(username, password, deviceKey, data, publicIPVal, "0");
			System.out.println("RETURN:"+returnVal);
			if(returnVal==DatabaseHandler.USER_UPDATED) { dataString="Updated"; returnVal=REC_UPDATED; }
			else { System.out.println("ERROR:"+returnVal); dataString="Failed to Update"; returnVal=REC_INVALID; }
			break;
		}

		}


		//Return modified Command Value
		String returnString=null;
		returnString=returnVal+":"+dataString+"\n";
		return returnString;
	}

	public static int processInputCommand(String input){

		String type; String value;
		try{
			String[] parts = input.split(SPLITTER);
			type = parts[0];
			value = parts[1];
		}catch(ArrayIndexOutOfBoundsException e){
			return INVALID;
		}

		if(type.equals(COMMAND)){
			return processCMD(value);
		}else if(type.equals(SQL)){
			return processSQL(value);
		}else if(type.equals(TCP)){
			return processTCP(value);
		}else if(type.equals(DB)){
			return processDB(value);
		}else{
			return INVALID;
		}
	}

	private static int processDB(String value){
		String Command; String Value1; String Value2; String Value3;
		try{
			String[] parts = value.split("-");
			Command = parts[0];
			Value1 = parts[1];
			Value2 = parts[2];
			Value3 = parts[3];
		}catch(ArrayIndexOutOfBoundsException e){
			return INVALID;
		}

		if(Command.equals(ADDUSER)){
			DatabaseHandler.addUser(Value1, Value2, Value3,"192.168.1.1","45.45.45.45","0");
		}else if(Command.equals(UNTIEUSER)){
			DatabaseHandler.untieUser(Value1, Value2, Value3);
		}else if(Command.equals(CHECKUSER)){
			DatabaseHandler.checkValidUser(Value1, Value2);
		}else if(Command.equals(TIEUSER)){
			DatabaseHandler.tieUser(Value1, Value2, Value3,"192.168.1.1","45.45.45.45","0");
		}else if(Command.equals(UPDATEUSER)){
			DatabaseHandler.updateUser(Value1, Value2, Value3,"192.168.1.1","45.45.45.45","1");
		}else if(Command.equals(CHECKTIED)){
			DatabaseHandler.checkDeviceTied(Value1,Value3);
		}

		return INVALID;
	}

	private static String sendMessage(int command,String data,int port,String ip){
		if(blockerCheck.isAvailable(ip, port)) blockerCheck.addBlock(ip, port);
		else{
			long startTime=TimeUnit.SECONDS.convert(System.nanoTime(), TimeUnit.NANOSECONDS);
			while(!(blockerCheck.isAvailable(ip, port))){
				long currTime=TimeUnit.SECONDS.convert(System.nanoTime(), TimeUnit.NANOSECONDS);
				if((currTime-startTime)>10) return NULL;
			}
			
			blockerCheck.addBlock(ip, port);
			startTime=TimeUnit.SECONDS.convert(System.nanoTime(), TimeUnit.NANOSECONDS);
			while(true){
				long currTime=TimeUnit.SECONDS.convert(System.nanoTime(), TimeUnit.NANOSECONDS);
				if((currTime-startTime)>1) break;
			}
		}
		try{
			String sendString=Integer.toString(command)+":"+data+'$'+'\n';
			BufferedReader inFromUser = new BufferedReader( new InputStreamReader(System.in));
			Socket clientSocket = new Socket();
			InetAddress addr = InetAddress.getByName(ip);
			SocketAddress sockaddr = new InetSocketAddress(addr, port);
			clientSocket.connect(sockaddr, 20000);
			
			DataOutputStream outToServer = new DataOutputStream(clientSocket.getOutputStream());
			BufferedReader inFromServer = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
			outToServer.writeBytes(sendString);
			String rcvString = inFromServer.readLine();
			System.out.println("FROM DEVICE: " + rcvString);
			clientSocket.close();
			blockerCheck.removeBlock(ip, port);
			return rcvString;
		}catch(Exception e){
			System.err.println(e.getMessage());
			blockerCheck.removeBlock(ip, port);
		}

		return NULL;
	}

	private static int processTCP(String value){
		String commandStr;String data;String portStr;String ip;
		int command;int port;
		try{
			String[] parts = value.split("-");
			commandStr = parts[0];
			data = parts[1];
			portStr=parts[2];
			ip=parts[3];
			command=Integer.parseInt(commandStr);
			port=Integer.parseInt(portStr);
		}catch(ArrayIndexOutOfBoundsException e){
			return INVALID;
		}

		sendMessage(command,data,port,ip);
		return INVALID;
	}

	private static int processCMD(String value){
		StringBuffer getData = new StringBuffer();
		if(value.equals("exit"))
			return EXIT;
		return INVALID;
	}

	private static int processSQL(String value){

		try{
			//Determine query type
			String[] parts = value.split(" ");
			String qType = parts[0];

			//Connect
			JdbcDataSource ds = new JdbcDataSource();
			ds.setURL(DatabaseHandler.SQLDATABASE);
			ds.setUser(DatabaseHandler.SQLUSER);
			ds.setPassword(DatabaseHandler.SQLPASS);
			Connection conn = ds.getConnection();

			//Print for select type
			if(qType.equals("SELECT")){
				ResultSet set=conn.createStatement().executeQuery(value);
				ResultSetMetaData rsmd = set.getMetaData();
				int columnsNumber = rsmd.getColumnCount();
				for(int i=1;i<=columnsNumber;i++){
					if(i==1) System.out.printf("%s",rsmd.getColumnName(i));
					else System.out.printf("%20s",rsmd.getColumnName(i));
				}
				System.out.println("");
				while (set.next()) {
					for(int i=1;i<=columnsNumber;i++){
						if(i==1) System.out.printf("%s",set.getString(i));
						else System.out.printf("%20s",set.getString(i));
					}
					System.out.println("");
				}
				return OTHER;
			}

			//Print for modify command type
			else{
				conn.createStatement().execute(value);
				System.out.println("Executed successfully");
			}


			return OTHER;
		}catch(SQLException e){
			System.err.println(e.getMessage());
			return INVALID;
		}catch(Exception e){
			System.err.println(e.getMessage());
			return INVALID;
		}

	}
}
