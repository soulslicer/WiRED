package MainPackage;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Scanner;


public class Main{

	static ServerSystem serverSystem;
	static Thread userInputThread;
	static Thread tcpInputThread;

	/* Main Thread */
	public static void main(String[] args) throws Exception {
		System.out.println("** WiRED Server starting..");

		//Start Command Threads
		userInputThread = new UserInputThread();
		userInputThread.start();
		tcpInputThread = new TCPInputThread();
		tcpInputThread.start();

		//Start Servers
		serverSystem=new ServerSystem();
		serverSystem.startServer();

	}

	/* User Input Thread */
	private static class UserInputThread extends Thread {

		private Boolean running=true;

		public UserInputThread() {
			setDaemon(true);
			setName("UserInputThread");
		}

		@Override
		public void run() {
			System.out.println("*** UserInputThread active");
			try {
				while(running){
					Scanner s = new Scanner(System.in);
					String input=s.nextLine();
					int response=Logic.processInputCommand(input);
					running=handleResponse(response,input);
				}
			} catch(Exception e) {
				throw new RuntimeException(e);
			}
		}
	}

	/* TCP Input Thread */
	private static class TCPInputThread extends Thread {

		private Boolean running=true;
		private ServerSocket socket;

		public TCPInputThread() {
			setDaemon(true);
			setName("TCPInputThread");
			try {
				socket = new ServerSocket(8079, 1, InetAddress.getByName("0.0.0.0"));
			} catch(Exception e) {
				throw new RuntimeException(e);
			}
		}

		@Override
		public void run() {
			System.out.println("*** TCPInputThread active");
			Socket accept;
			try {
				while(running){
					accept = socket.accept();
					BufferedReader reader = new BufferedReader(new InputStreamReader(accept.getInputStream()));
					String input=reader.readLine();
					accept.close();
					int response=Logic.processInputCommand(input);
					running=handleResponse(response,input);
				}
			} catch(Exception e) {
				throw new RuntimeException(e);
			}
		}
	}
	
	public static Boolean handleResponse(int response,String input){
		switch(response){
		case Logic.EXIT:
			serverSystem.stopServer();
			return false;
		case Logic.OTHER:
			break;
		case Logic.INVALID:
			System.err.println("Invalid response received "+ input);
			break;
		}
		return true;
	}


}


