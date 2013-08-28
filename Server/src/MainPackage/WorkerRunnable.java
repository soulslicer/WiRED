package MainPackage;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.IOException;
import java.net.Socket;


public class WorkerRunnable implements Runnable{

    protected Socket clientSocket = null;
    protected String serverText   = null;
    
    public static String convertStreamToString(java.io.InputStream is) {
    	InputStreamReader i=new InputStreamReader(is);
    	BufferedReader str=new BufferedReader(i);
    	String msg = null;
		try {
			msg = str.readLine();
		} catch (IOException e) {
			e.printStackTrace();
		}
    	return msg;
    }

    public WorkerRunnable(Socket clientSocket, String serverText) {
        this.clientSocket = clientSocket;
        this.serverText   = serverText;
    }

    public void run() {
        try {
            InputStream input  = clientSocket.getInputStream();
            OutputStream output = clientSocket.getOutputStream();
            
            String inputString=convertStreamToString(input);
            String ipString=clientSocket.getRemoteSocketAddress().toString();
            System.out.println(ipString);
            System.out.println(inputString);
            
            String sendString=Logic.processFromDevice(inputString, ipString);
            System.out.println(sendString);
            output.write((sendString).getBytes());
            //output.write(("You typed: "+inputString+"\n").getBytes());
            
            /*
            long time = System.currentTimeMillis();
            output.write(("HTTP/1.1 200 OK\n\nWorkerRunnable: " +
                    this.serverText + " - " +
                    time +
                    "").getBytes());
            */
            output.close();
            
            input.close();
            System.out.println("Request processed");
        } catch (IOException e) {
            //report exception somewhere.
            e.printStackTrace();
        }
    }
}