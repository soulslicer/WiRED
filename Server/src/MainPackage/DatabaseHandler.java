package MainPackage;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import org.h2.jdbcx.JdbcDataSource;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
//import java.util.List;


public class DatabaseHandler {

	public static final String SQLDATABASE="jdbc:h2:wiredDB";
	public static final String SQLUSER="user";
	public static final String SQLPASS="pass";

	public static final String NULL="NULL";
	public static final int ERROR_NODEVICE = 1;
	public static final int ERROR_DEVICETIED = 2;
	public static final int ERROR_USEREXISTS = 3;
	public static final int ERROR_USERPASSWRONG = 4;
	public static final int ERROR_INVALID = 5;
	public static final int ERROR_IRCODEEXISTS=6;

	public static final int USER_ADDED = 7;
	public static final int USER_UNTIED = 8;
	public static final int USER_TIED = 9;
	public static final int USER_UPDATED = 10;

	public static final int USER_IRTABLEUPDATED = 11;
	public static final int USER_IRTABLEADDED = 12;
	public static final int USER_IRTABLEREMOVED=13;
	public static final int USER_IRCODEADDED=14;
	public static final int USER_IRCODEREMOVED=15;
	public static final int USER_LOOPUPDATED=16;
	public static final int USER_LOGINCORRECT=17;
	public static final int USER_DEVICEREGISTERED=18;
	public static final int USER_RUNDATESET=19;

	public static JdbcDataSource ds;

	public static void loginDB(){
		ds = new JdbcDataSource();
		ds.setURL(DatabaseHandler.SQLDATABASE);
		ds.setUser(DatabaseHandler.SQLUSER);
		ds.setPassword(DatabaseHandler.SQLPASS);
	}

	/*Function:
	 * 1. Adds a user to database with these params
	 * 2. Checks if the DeviceKey is valid only then proceeds
	 * 3. If a device is already tied to another user, it unties it and ties with added new one
	 */
	public static int addUser(String username, String password, String deviceKey, String localAddress, String publicAddress,String schedule){

		//Variables
		int returnValue=ERROR_INVALID;
		boolean deviceMatch=false;
		boolean userAvailable=false;
		boolean deviceUpdated=false;
		boolean userUpdated=false;
		boolean existingUser=false;
		String deviceName=NULL;
		String oldName=NULL;

		//Check if deviceKey exists and check if TIED to user
		try {
			String queryDevice="SELECT * FROM DEVICES WHERE DEVICEKEY = '" + deviceKey + "'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			ResultSetMetaData rsmd = set.getMetaData();
			if(set.next()){
				if(set.getString(4).equals(NULL)){
					deviceName=set.getString(2);
					System.out.println("Device Exists: "+deviceName);
					deviceMatch=true;
				}else{
					deviceName=set.getString(2);
					oldName=set.getString(4);
					System.out.println("Device Already Tied: "+deviceName);
					deviceMatch=true;
					returnValue=ERROR_DEVICETIED;
				}
			}else{
				System.out.println("No Such Device");
				deviceMatch=false;
				returnValue=ERROR_NODEVICE;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			deviceMatch=false;
			returnValue=ERROR_INVALID;
		}

		if(!deviceMatch) return returnValue;

		//Device was matched, check if all match
		if(returnValue==ERROR_DEVICETIED){
			try {
				String queryDevice="SELECT * FROM USERS WHERE USERNAME = '" + username + "' AND PASSWORD = '"+password+"'"+ " AND DEVICENAME = '"+deviceName+"'";
				Connection conn = ds.getConnection();
				ResultSet set=conn.createStatement().executeQuery(queryDevice);
				if(set.next()){
					System.out.println("Existing user..update new wifi");
					existingUser=true;
				}else{
					existingUser=false;
					System.out.println("Skipping existing user step");
				}
				set.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
				existingUser=false;
			}
		}

		//User exists, perform update of details
		if(existingUser){
			try {
				String queryDevice="UPDATE USERS SET "
						+"PUBLICADDRESS="
						+"'"+publicAddress+"',"
						+"LOCALADDRESS="
						+"'"+localAddress+"',"
						+"SCHEDULE='0' "
						+"WHERE USERNAME = " 
						+"'"+oldName+"'";
				Connection conn = ds.getConnection();
				conn.createStatement().execute(queryDevice);
				conn.close();
				System.out.println("User's wifi info updated");
				userUpdated=true;
				return USER_ADDED;
			} catch (SQLException e) {
				e.printStackTrace();
				userUpdated=false;
				return ERROR_INVALID;
			}		
		}

		//Check if user exists already
		try {
			String queryDevice="SELECT * FROM USERS WHERE USERNAME = '" + username + "'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			ResultSetMetaData rsmd = set.getMetaData();
			if(set.next()){
				System.out.println("User already exists");
				userAvailable=false;
				returnValue=ERROR_USEREXISTS;
			}else{
				System.out.println("Username available");
				userAvailable=true;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			returnValue=ERROR_INVALID;
		}

		if(!userAvailable) return returnValue;

		if(returnValue==ERROR_DEVICETIED){
			//UPDATE WITH NEW NAME
			try {
				String queryDevice="UPDATE DEVICES SET USER = "
						+"'"+username+"'"
						+" WHERE DEVICENAME = "
						+"'"+deviceName+"'";
				Connection conn = ds.getConnection();
				conn.createStatement().execute(queryDevice);
				conn.close();
				deviceUpdated=true;
				System.out.println("Device matched to NEW user");
			} catch (SQLException e) {
				deviceUpdated=false;
				e.printStackTrace();
				returnValue=ERROR_INVALID;
			}
		}else{
			//UPDATE USER TO DEVICE DB
			try {
				String queryDevice="UPDATE DEVICES SET USER = "
						+"'"+username+"'"
						+" WHERE DEVICENAME = "
						+"'"+deviceName+"'";
				Connection conn = ds.getConnection();
				conn.createStatement().execute(queryDevice);
				conn.close();
				System.out.println("Device matched to user");
				deviceUpdated=true;
			} catch (SQLException e) {
				e.printStackTrace();
				deviceUpdated=false;
				returnValue=ERROR_INVALID;
			}
		}

		if(!deviceUpdated) return returnValue;

		//UNTIE ON USER
		if(returnValue==ERROR_DEVICETIED){
			try {
				String queryDevice="UPDATE USERS SET "
						+"DEVICENAME='NULL',"
						+"PUBLICADDRESS='NULL',"
						+"LOCALADDRESS='NULL',"
						+"SCHEDULE='0' "
						+"WHERE USERNAME = " 
						+"'"+oldName+"'";
				Connection conn = ds.getConnection();
				conn.createStatement().execute(queryDevice);
				conn.close();
				System.out.println("Old user untied");
				userUpdated=true;
			} catch (SQLException e) {
				e.printStackTrace();
				userUpdated=false;
				returnValue=ERROR_INVALID;
			}
		}else{
			userUpdated=true;
		}

		if(!userUpdated) return returnValue;

		//ADD USER TO USER DATABASE
		try {
			String queryDevice="INSERT INTO USERS "
					+"(USERNAME,PASSWORD,DEVICENAME,PUBLICADDRESS,LOCALADDRESS,SCHEDULE) "
					+"values(" 
					+"'"+username+"',"
					+"'"+password+"',"
					+"'"+deviceName+"',"
					+"'"+publicAddress+"',"
					+"'"+localAddress+"',"
					+"'"+schedule+"')";
			Connection conn = ds.getConnection();
			conn.createStatement().execute(queryDevice);
			conn.close();
			System.out.println("User database updated");
			userUpdated=true;
		} catch (SQLException e) {
			e.printStackTrace();
			userUpdated=false;
			returnValue=ERROR_INVALID;
		}

		if(!userUpdated) return returnValue;

		return USER_ADDED;
	}

	public static int updateUser(String username, String password, String deviceKey, String localAddress, String publicAddress,String schedule){

		//Variables
		int returnValue=ERROR_INVALID;
		boolean deviceMatch=false;
		boolean userAvailable=false;
		boolean deviceUpdated=false;
		boolean userUpdated=false;
		String deviceName=NULL;
		String oldName=NULL;

		//Check if deviceKey exists and check if TIED to user
		try {
			String queryDevice="SELECT * FROM DEVICES WHERE DEVICEKEY = '" + deviceKey + "'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			if(set.next()){
				if(set.getString(4).equals(NULL)){
					deviceName=set.getString(2);
					System.out.println("Device Not Tied: "+deviceName);
					deviceMatch=false;
				}else{
					deviceName=set.getString(2);
					oldName=set.getString(4);
					System.out.println("Device Already Tied: "+deviceName);
					deviceMatch=true;
					returnValue=ERROR_DEVICETIED;
				}
			}else{
				System.out.println("No Such Device");
				deviceMatch=false;
				returnValue=ERROR_NODEVICE;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			returnValue=ERROR_INVALID;
		}

		if(!deviceMatch) return returnValue;	

		//CHECK USER/PASS VALID
		if(!checkValidUser(username, password)){
			returnValue=ERROR_USERPASSWRONG;
			return returnValue;
		}

		//TIE IN USERS
		try {
			String queryDevice="UPDATE USERS SET "
					+"PUBLICADDRESS= "
					+"'"+publicAddress+"',"
					+"LOCALADDRESS= "
					+"'"+localAddress+"',"
					+"SCHEDULE= "
					+"'"+schedule+"'"
					+"WHERE USERNAME = " 
					+"'"+username+"'";
			Connection conn = ds.getConnection();
			conn.createStatement().execute(queryDevice);
			conn.close();
			System.out.println("User info updated");
			userUpdated=true;
		} catch (SQLException e) {
			e.printStackTrace();
			userUpdated=false;
			returnValue=ERROR_INVALID;
		}

		if(!userUpdated) return returnValue;
		

		return USER_UPDATED;
	}

	public static int untieUser(String username, String password, String deviceKey){

		//Variables
		int returnValue=ERROR_INVALID;
		boolean deviceMatch=false;
		boolean userAvailable=false;
		boolean deviceUpdated=false;
		boolean userUpdated=false;
		String deviceName=NULL;
		String oldName=NULL;

		//CHECK VALID DEVICEKEY
		try {
			String queryDevice="SELECT * FROM DEVICES WHERE DEVICEKEY = '" + deviceKey + "'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			ResultSetMetaData rsmd = set.getMetaData();
			if(set.next()){
				if(set.getString(4).equals(NULL)){
					deviceName=set.getString(2);
					System.out.println("Device Not Tied Anyway");
					deviceMatch=false;
				}else{
					deviceName=set.getString(2);
					oldName=set.getString(4);
					System.out.println("Device Tied: "+deviceName);
					deviceMatch=true;
					returnValue=ERROR_DEVICETIED;
				}
			}else{
				System.out.println("No Such Device");
				deviceMatch=false;
				returnValue=ERROR_NODEVICE;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			returnValue=ERROR_INVALID;
		}

		if(!deviceMatch) return returnValue;

		//CHECK VALID USER
		if(!checkValidUser(username, password)){
			returnValue=ERROR_USERPASSWRONG;
			return returnValue;
		}

		//UNTIE IN DEVICES
		try {
			String queryDevice="UPDATE DEVICES SET USER = "
					+"'"+"NULL"+"'"
					+" WHERE DEVICENAME = "
					+"'"+deviceName+"'";
			Connection conn = ds.getConnection();
			conn.createStatement().execute(queryDevice);
			conn.close();
			deviceUpdated=true;
			System.out.println("Device matched to NEW user");
		} catch (SQLException e) {
			deviceUpdated=false;
			e.printStackTrace();
			returnValue=ERROR_INVALID;
		}

		if(!deviceUpdated) return returnValue;

		//UNTIE IN USERS
		try {
			String queryDevice="UPDATE USERS SET "
					+"DEVICENAME='NULL',"
					+"PUBLICADDRESS='NULL',"
					+"LOCALADDRESS='NULL',"
					+"SCHEDULE='0' "
					+"WHERE USERNAME = " 
					+"'"+username+"'";
			Connection conn = ds.getConnection();
			conn.createStatement().execute(queryDevice);
			conn.close();
			System.out.println("User untied");
			userUpdated=true;
		} catch (SQLException e) {
			e.printStackTrace();
			userUpdated=false;
			returnValue=ERROR_INVALID;
		}

		if(!userUpdated) return returnValue;

		return USER_UNTIED;
	}

	public static int tieUser(String username, String password, String deviceKey, String localAddress, String publicAddress,String schedule){

		//Variables
		int returnValue=ERROR_INVALID;
		boolean deviceMatch=false;
		boolean userAvailable=false;
		boolean deviceUpdated=false;
		boolean userUpdated=false;
		String deviceName=NULL;
		String oldName=NULL;

		//CHECK IF DEVICE TIED
		try {
			String queryDevice="SELECT * FROM DEVICES WHERE DEVICEKEY = '" + deviceKey + "'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			ResultSetMetaData rsmd = set.getMetaData();
			if(set.next()){
				if(set.getString(4).equals(NULL)){
					deviceName=set.getString(2);
					System.out.println("Device Exists: "+deviceName);
					deviceMatch=true;
				}else{
					deviceName=set.getString(2);
					oldName=set.getString(4);
					System.out.println("Device Already Tied: "+deviceName);
					deviceMatch=false;
					returnValue=ERROR_DEVICETIED;
				}
			}else{
				System.out.println("No Such Device");
				deviceMatch=false;
				returnValue=ERROR_NODEVICE;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			returnValue=ERROR_INVALID;
		}		

		if(!deviceMatch) return returnValue;

		//CHECK USER/PASS VALID
		if(!checkValidUser(username, password)){
			returnValue=ERROR_USERPASSWRONG;
			return returnValue;
		}

		//TIE IN DEVICES
		try {
			String queryDevice="UPDATE DEVICES SET USER = "
					+"'"+username+"'"
					+" WHERE DEVICENAME = "
					+"'"+deviceName+"'";
			Connection conn = ds.getConnection();
			conn.createStatement().execute(queryDevice);
			conn.close();
			deviceUpdated=true;
			System.out.println("Device matched to user");
		} catch (SQLException e) {
			deviceUpdated=false;
			e.printStackTrace();
			returnValue=ERROR_INVALID;
		}

		if(!deviceUpdated) return returnValue;

		//TIE IN USERS
		try {
			String queryDevice="UPDATE USERS SET "
					+"DEVICENAME= "
					+"'"+deviceName+"',"
					+"PUBLICADDRESS= "
					+"'"+publicAddress+"',"
					+"LOCALADDRESS= "
					+"'"+localAddress+"',"
					+"SCHEDULE= "
					+"'"+schedule+"'"
					+"WHERE USERNAME = " 
					+"'"+username+"'";
			Connection conn = ds.getConnection();
			conn.createStatement().execute(queryDevice);
			conn.close();
			System.out.println("User tied");
			userUpdated=true;
		} catch (SQLException e) {
			e.printStackTrace();
			userUpdated=false;
			returnValue=ERROR_INVALID;
		}

		if(!userUpdated) return returnValue;

		return USER_TIED;
	}

	public static boolean checkValidUser(String username, String password){

		//Variables
		boolean returnValue=false;

		//Check if user exists already
		try {
			String queryDevice="SELECT * FROM USERS WHERE USERNAME = '" + username + "' AND PASSWORD = '"+password+"'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			if(set.next()){
				System.out.println("User/pass correct");
				returnValue=true;
			}else{
				returnValue=false;
				System.out.println("User/pass wrong");
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			returnValue=false;
		}		

		return returnValue;
	}

	public static boolean checkDeviceTied(String username,String deviceKey){

		//Variables
		boolean deviceMatch=false;

		//Check if deviceKey exists and check if TIED to user
		try {
			String queryDevice="SELECT * FROM DEVICES WHERE USER = '" + username + "' AND DEVICEKEY = '"+deviceKey+"'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			if(set.next()){
				System.out.println("User has been tied");
				deviceMatch=true;
			}else{
				System.out.println("User not tied yet");
				deviceMatch=false;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			deviceMatch=false;
		}

		return deviceMatch;
	}

	public static String getPublicIP(String username){

		//Variables
		String publicIP=NULL;

		//Check for public ip
		try {
			String queryDevice="SELECT * FROM USERS WHERE USERNAME = '" + username + "'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			ResultSetMetaData rsmd = set.getMetaData();
			if(set.next()){
				System.out.println("Public IP Found");
				publicIP = set.getString(5);
			}else{
				System.out.println("Not Found");
				return NULL;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			return NULL;
		}

		return publicIP;
	}

	public static String getLocalIP(String username){

		//Variables
		String localIP=null;

		//Check for public ip
		try {
			String queryDevice="SELECT * FROM USERS WHERE USERNAME = '" + username + "'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			ResultSetMetaData rsmd = set.getMetaData();
			if(set.next()){
				System.out.println("Local IP Found");
				localIP = set.getString(6);
			}else{
				System.out.println("Not Found");
				return null;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}

		return localIP;
	}

	public static int addUpdateIRDevice(String username,String IRDevice,String Desc){

		boolean irDeviceExists=false;

		//Check if IRDevice exists for that user
		try {
			String queryDevice="SELECT * FROM IRDEVICES WHERE USERNAME = '" + username + "' AND IRDEVICE = '"+IRDevice+"'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			if(set.next()){
				System.out.println("Device Exists already..updating desc");
				irDeviceExists=true;
			}else{
				irDeviceExists=false;
				System.out.println("Device doesn't exist, adding");
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			return ERROR_INVALID;
		}	

		if(irDeviceExists){
			try {
				String queryDevice="UPDATE IRDEVICES SET "
						+"DESC= "
						+"'"+Desc+"' "
						+"WHERE USERNAME = " 
						+"'"+username+"'"
						+" AND IRDEVICE= "
						+"'"+IRDevice+"'";
				System.out.println(queryDevice);
				Connection conn = ds.getConnection();
				conn.createStatement().execute(queryDevice);
				conn.close();
				System.out.println("IRDevices table updated");
			} catch (SQLException e) {
				e.printStackTrace();
				return ERROR_INVALID;
			}
			return USER_IRTABLEUPDATED;
		}else{
			//Add to IRDevices Table
			try {
				String queryDevice="INSERT INTO IRDEVICES "
						+"(USERNAME,IRDEVICE,IMAGENAME,DESC) "
						+"values(" 
						+"'"+username+"',"
						+"'"+IRDevice+"',"
						+"'"+"NULL"+"',"
						+"'"+Desc+"')";
				Connection conn = ds.getConnection();
				conn.createStatement().execute(queryDevice);
				conn.close();
				System.out.println("IRDevice added");
				//userUpdated=true;
			} catch (SQLException e) {
				e.printStackTrace();
				return ERROR_INVALID;
			}
			return USER_IRTABLEADDED;
		}
	}

	public static int removeIRDevice(String username,String IRDevice){

		boolean irDeviceExists=false;
		int indexer;

		//Check if IRDevice exists for that user
		try {
			String queryDevice="SELECT * FROM IRDEVICES WHERE USERNAME = '" + username + "' AND IRDEVICE = '"+IRDevice+"'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			ResultSetMetaData rsmd = set.getMetaData();
			if(set.next()){
				irDeviceExists=true;
				indexer = Integer.parseInt(set.getString(1));
				System.out.println("IRDevice index at "+indexer);
			}else{
				irDeviceExists=false;
				System.out.println("IRDevice doesn't exist");
				return ERROR_INVALID;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			return ERROR_INVALID;
		}	

		if(irDeviceExists){

			//Remove from IRCodes
			try {
				String queryDevice="DELETE FROM IRCODES WHERE USERNAME="+"'"+username+"'"+" AND IRDEVICE="+"'"+IRDevice+"'";
				Connection conn = ds.getConnection();
				conn.createStatement().execute(queryDevice);
				conn.close();
				System.out.println("IRCodes removed");
			} catch (SQLException e) {
				return ERROR_INVALID;
			}	

			//Remove from IRDevices
			try {
				String queryDevice="DELETE FROM IRDEVICES WHERE ID="+indexer;
				Connection conn = ds.getConnection();
				conn.createStatement().execute(queryDevice);
				conn.close();
				System.out.println("IRDevice removed");
				return USER_IRTABLEREMOVED;
			} catch (SQLException e) {
				return ERROR_INVALID;
			}			
		}

		return ERROR_INVALID;

	}
	//remove device+get device?

	public static int addIRCode(String username,String IRDevice,String IRCommand,String desc,String data){
		//ircommand is the on/off type
		//user taps on phone (phone already has username,irdevice,ircommand,desc
		//it is sent into the servlet..
		//servlet calls the receiver..get the data above
		//servlet call sendtodevice/receive..sends string back via buffer
		//servlet calls add ir code with everything, add to db

		//Check if IRDevice+Command exists for that user
		try {
			String queryDevice="SELECT * FROM IRCODES WHERE USERNAME = '" + username + "' AND IRDEVICE = '"+IRDevice+"'"+ " AND IRCOMMAND = '"+IRCommand+"'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			if(set.next()){
				System.out.println("This IRCommand exists already");
				return ERROR_IRCODEEXISTS;
			}else{
				System.out.println("IRCommand doesn't exist..adding");
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			return ERROR_INVALID;
		}	

		data=data.replaceAll("'", "~");
		
		//If it doesn't then add
		try {
			String queryDevice="INSERT INTO IRCODES "
					+"(USERNAME,IRDEVICE,IRCOMMAND,DESC,DATASTRING) "
					+"values(" 
					+"'"+username+"',"
					+"'"+IRDevice+"',"
					+"'"+IRCommand+"',"
					+"'"+desc+"',"
					+"'"+data+"')";
			Connection conn = ds.getConnection();
			conn.createStatement().execute(queryDevice);
			conn.close();
			System.out.println("IRCode added");
		} catch (SQLException e) {
			e.printStackTrace();
			return ERROR_INVALID;
		}

		return USER_IRCODEADDED;
	}

	public static int removeIRCode(String username,String IRDevice,String IRCommand){

		int indexer=0;

		//Get the index for that set
		try {
			String queryDevice="SELECT * FROM IRCODES WHERE USERNAME = '" + username + "' AND IRDEVICE = '"+IRDevice+"'"+ " AND IRCOMMAND = '"+IRCommand+"'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			ResultSetMetaData rsmd = set.getMetaData();
			if(set.next()){
				indexer = Integer.parseInt(set.getString(1));
				System.out.println("IRCode index at "+indexer);
			}else{
				System.out.println("IRCode doesn't exist");
				return ERROR_INVALID;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			return ERROR_INVALID;
		}	

		//Remove it
		try {
			String queryDevice="DELETE FROM IRCODES WHERE ID="+indexer;
			Connection conn = ds.getConnection();
			conn.createStatement().execute(queryDevice);
			conn.close();
			System.out.println("IRCode removed");
			return USER_IRCODEREMOVED;
		} catch (SQLException e) {
			return ERROR_INVALID;
		}
	}

	public static String getIRCode(String username,String IRDevice,String IRCommand){

		String irdata;

		try {
			String queryDevice="SELECT * FROM IRCODES WHERE USERNAME = '" + username + "' AND IRDEVICE = '"+IRDevice+"'"+ " AND IRCOMMAND = '"+IRCommand+"'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			ResultSetMetaData rsmd = set.getMetaData();
			if(set.next()){
				System.out.println("Got IRCode from database");
				irdata=set.getString(6);
			}else{
				System.out.println("IRCode doesn't exist");
				return null;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}	

		irdata=irdata.replaceAll("~", "'");
		return irdata;
	}
	//code to modify loop for raw database modify

	public static int setIRLoopAmount(String username,String IRDevice,String IRCommand,int loopAmt){

		String irCode=getIRCode(username, IRDevice, IRCommand);
		if(irCode==null) return ERROR_INVALID;

		int firstDig=Character.getNumericValue(irCode.charAt(0));
		if(firstDig!=0) return ERROR_INVALID;

		if(loopAmt<1){
			return ERROR_INVALID;
		}else if(loopAmt==3){
			StringBuilder modIR = new StringBuilder(irCode);
			modIR.setCharAt(1, '-');
			irCode=modIR.toString();
		}else{
			loopAmt+=33;
			char loopChar = (char) loopAmt;
			StringBuilder modIR = new StringBuilder(irCode);
			modIR.setCharAt(1, loopChar);
			irCode=modIR.toString();
		}

		try {
			String queryDevice="UPDATE IRCODES SET "
					+"DATASTRING= "
					+"'"+irCode+"' "
					+"WHERE USERNAME = " 
					+"'"+username+"'"
					+" AND IRDEVICE= "
					+"'"+IRDevice+"'"
					+" AND IRCOMMAND= "
					+"'"+IRCommand+"'";
			System.out.println(queryDevice);
			Connection conn = ds.getConnection();
			conn.createStatement().execute(queryDevice);
			conn.close();
			System.out.println("IRLoop updated");
		} catch (SQLException e) {
			e.printStackTrace();
			return ERROR_INVALID;
		}

		return USER_LOOPUPDATED;
	}

	public static JSONArray getIRDevicesList(String username){
		JSONArray list = new JSONArray();
		boolean listFound=false;

		//Check if IRDevice exists for that user
		try {
			String queryDevice="SELECT * FROM IRDEVICES WHERE USERNAME = '" + username + "'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			if(set.next()){
				JSONObject obj = new JSONObject();
				obj.put("IRDevice", set.getString(3));
				obj.put("Image", set.getString(4));
				obj.put("Description", set.getString(5));
				list.add(obj);
				while(set.next()){
					JSONObject obj1 = new JSONObject();
					obj1.put("IRDevice", set.getString(3));
					obj1.put("Image", set.getString(4));
					obj1.put("Description", set.getString(5));
					list.add(obj1);
				}
				System.out.println("IRDevices selected for user");
				listFound=true;
			}else{
				listFound=false;
				System.out.println("No IRDevices found");
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}	
		
		if(listFound){
			return list;
		}else return null;

	}

	public static JSONArray getIRCodesList(String username,String IRDevice){
		JSONArray list = new JSONArray();
		boolean listFound=false;

		//Check if IRDevice exists for that user
		try {
			String queryDevice="SELECT * FROM IRCODES WHERE USERNAME = '" + username + "' AND IRDEVICE = '"+IRDevice+"'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			if(set.next()){
				JSONObject obj = new JSONObject();
				obj.put("IRCommand", set.getString(4));
				obj.put("Description", set.getString(5));
				obj.put("Datastring", set.getString(6));
				obj.put("Rundate", set.getString(7));
				list.add(obj);
				while(set.next()){
					JSONObject obj1 = new JSONObject();
					obj1.put("IRCommand", set.getString(4));
					obj1.put("Description", set.getString(5));
					obj1.put("Datastring", set.getString(6));
					obj1.put("Rundate", set.getString(7));
					list.add(obj1);
				}
				System.out.println("IRCodes selected for user");
				listFound=true;
			}else{
				listFound=false;
				System.out.println("No IRCodes found");
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}	
		
		if(listFound){
			return list;
		}else return null;		
		
	}

	public static int getRegisteredStatus(String username,String deviceKey){
		boolean deviceMatch=false;

		//Check if deviceKey exists and check if TIED to user
		try {
			String queryDevice="SELECT * FROM DEVICES WHERE USER = '" + username + "' AND DEVICEKEY = '"+deviceKey+"'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			if(set.next()){
				System.out.println("User has been tied");
				deviceMatch=true;
			}else{
				System.out.println("User not tied yet");
				deviceMatch=false;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			deviceMatch=false;
		}

		if(deviceMatch){
			return USER_DEVICEREGISTERED;
		}else{
			return ERROR_INVALID;
		}
	}

	public static String getPassword(String username){
		String password=null;
		try {
			String queryDevice="SELECT * FROM USERS WHERE USERNAME = '" + username + "'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			if(set.next()){
				password = set.getString(3);
			}else{
				return null;
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}
		return password;
	}
	
	public static String getDeviceKey(String username,String password){
		if(checkValidUser(username, password)){
			String devKey=null;
			try {
				String queryDevice="SELECT * FROM DEVICES WHERE USER = '" + username + "'";
				Connection conn = ds.getConnection();
				ResultSet set=conn.createStatement().executeQuery(queryDevice);
				if(set.next()){
					devKey = set.getString(3);
				}
				set.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
				return null;
			}
			return devKey;
		}else{
			return null;
		}
	}
	
	public static int setRunDate(String username,String IRDevice,String IRCommand,String runDate){
		try {
			String queryDevice=null;
			if(runDate.equals("null")){
				queryDevice="UPDATE IRCODES SET "
						+"RUNDATE= "
						+"null "
						+"WHERE USERNAME = " 
						+"'"+username+"'"
						+" AND IRDEVICE= "
						+"'"+IRDevice+"'"
						+" AND IRCOMMAND= "
						+"'"+IRCommand+"'";
			}else{
				queryDevice="UPDATE IRCODES SET "
						+"RUNDATE= "
						+"'"+runDate+"' "
						+"WHERE USERNAME = " 
						+"'"+username+"'"
						+" AND IRDEVICE= "
						+"'"+IRDevice+"'"
						+" AND IRCOMMAND= "
						+"'"+IRCommand+"'";
			}
			Connection conn = ds.getConnection();
			conn.createStatement().execute(queryDevice);
			conn.close();
			System.out.println("Rundate updated");
			return USER_RUNDATESET;
		} catch (SQLException e) {
			e.printStackTrace();
			return ERROR_INVALID;
		}
	}
	
	public static List<TimeMatchObject> getMatchingTimes(String startTime,String endTime){
		
		//SELECT * FROM IRCODES WHERE RUNDATE between '2013-07-05 13:00:00' and '2013-07-05 13:01:00' 
		
		List<TimeMatchObject> timeMatchList=new ArrayList<TimeMatchObject>();
		
		//Get the date range
		try {
			String queryDevice="SELECT * FROM IRCODES WHERE RUNDATE between '" + startTime + "' AND '"+endTime+"'";
			Connection conn = ds.getConnection();
			ResultSet set=conn.createStatement().executeQuery(queryDevice);
			ResultSetMetaData rsmd = set.getMetaData();
			while(set.next()){
				String password=getPassword(set.getString(2));
				TimeMatchObject tObject=new TimeMatchObject(set.getString(2), password, set.getString(6));
				timeMatchList.add(tObject);
			}
			set.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}	
		
		return timeMatchList;
	}
}



/*
 String queryDevice="UPDATE USERS SET DEVICENAME = "
					+"'"+deviceName+"',"
					+"PUBLICADDRESS = "
					+"'"+publicAddress+"',"
					+"LOCALADDRESS = "
					+"'"+localAddress+"'"
					+" WHERE USERNAME = "
					+"'"+username+"'";
 */
