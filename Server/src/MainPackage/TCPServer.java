package MainPackage;

public class TCPServer {
	
	private static Thread tcpThread;
	private static ThreadPooledServer serverTCP;
	
	public TCPServer(){
		
	}
	
	public void start(){
		serverTCP = new ThreadPooledServer(9000);
		new Thread(serverTCP).start();
		//tcpThread=Thread(serverTCP).start();
		//tcpThread=new Thread(serverTCP);
		//tcpThread.start();
	}
	
	public void stop(){
		serverTCP.stop();
	}
}
