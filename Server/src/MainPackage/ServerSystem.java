package MainPackage;
import getPostPackage.GetIRCodeList;
import getPostPackage.GetIRDeviceList;
import getPostPackage.GetLocalIPInfo;
import getPostPackage.GetRegisteredStatus;
import getPostPackage.HomeServlet;
import getPostPackage.PostAddIRDevice;
import getPostPackage.PostLoginInfo;
import getPostPackage.PostRawLoopCount;
import getPostPackage.PostRemoveIRCode;
import getPostPackage.PostRemoveIRDevice;
import getPostPackage.PostRetreiveDeviceKey;
import getPostPackage.PostRunDate;
import getPostPackage.SendIRCodeFromDevice;
import getPostPackage.SendIRData;
import getPostPackage.SendVerifyDeviceStatus;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import org.eclipse.jetty.server.Connector;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.nio.SelectChannelConnector;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;




public class ServerSystem {

	private static org.eclipse.jetty.server.Server serverHTTP;
	private static org.h2.tools.Server serverDB;
	private static TCPServer serverTCP;
	private static DateScheduler dateScheduler;
	
	public ServerSystem(){
		
	}
	
	public void startServer(){
		try{
			System.out.println("*** servers starting..");
			
			//Start DB Server (8082)
			String params="-webAllowOthers";
			serverDB=org.h2.tools.Server.createWebServer(params).start();
			DatabaseHandler.loginDB();
			
			//Start TCP Server
			serverTCP=new TCPServer();
			serverTCP.start();
			
			//Start Date Scheduler
			dateScheduler=new DateScheduler();
			dateScheduler.start();
			
			//Configure HTTP Server (8080)
			serverHTTP = new Server();
			Connector connector = new SelectChannelConnector();
			connector.setPort(8080);
			serverHTTP.addConnector(connector);
			
			//Add HTTP URLS
			ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
			context.setContextPath("/");
			serverHTTP.setHandler(context);
			context.addServlet(new ServletHolder(new HomeServlet()),"/*");
			context.addServlet(new ServletHolder(new SendIRCodeFromDevice()),"/SendIRCodeFromDevice");
			context.addServlet(new ServletHolder(new SendIRData()),"/SendIRData");
			context.addServlet(new ServletHolder(new PostRawLoopCount()),"/PostRawLoopCount");
			context.addServlet(new ServletHolder(new GetIRDeviceList()),"/GetIRDeviceList");
			context.addServlet(new ServletHolder(new GetIRCodeList()),"/GetIRCodeList");
			context.addServlet(new ServletHolder(new GetLocalIPInfo()),"/GetLocalIPInfo");
			context.addServlet(new ServletHolder(new PostLoginInfo()),"/PostLoginInfo");
			context.addServlet(new ServletHolder(new GetRegisteredStatus()),"/GetRegisteredStatus");
			context.addServlet(new ServletHolder(new SendVerifyDeviceStatus()),"/SendVerifyDeviceStatus");
			context.addServlet(new ServletHolder(new PostRemoveIRCode()),"/PostRemoveIRCode");
			context.addServlet(new ServletHolder(new PostRemoveIRDevice()),"/PostRemoveIRDevice");
			context.addServlet(new ServletHolder(new PostAddIRDevice()),"/PostAddIRDevice");
			context.addServlet(new ServletHolder(new PostRunDate()),"/PostRunDate");
			context.addServlet(new ServletHolder(new PostRetreiveDeviceKey()),"/PostRetreiveDeviceKey");

			//Start HTTP Server
			serverHTTP.start();
			serverHTTP.join();
			
			
			

			
		}catch(Exception e){
			System.err.println(e.getMessage());
		}
	}
	
	public void stopServer(){
		try{
			
			//Stop all Server
			serverHTTP.stop();
			serverDB.stop();
			serverTCP.stop();
			dateScheduler.stop();
			System.out.println("*** server stopped");
			
		}catch(Exception e){
			System.err.println(e.getMessage());
		}
	}
}
