package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import MainPackage.DatabaseHandler;
import MainPackage.Logic;

public class SendIRData extends HttpServlet{
private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*SendIRData*");
		PrintWriter out = response.getWriter();
		String finalVal = null;
		
		StringBuffer buffer = new StringBuffer();
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String irdevice = request.getParameter("irdevice");
		String ircommand = request.getParameter("ircommand");
		
		String irdata=DatabaseHandler.getIRCode(username, irdevice, ircommand);
		if(irdata!=null){
			finalVal="DV:";
			int devresp=Logic.sendToDevice(username, password, Logic.PHONESEND_IRSNDMODE, irdata,buffer);
			if(devresp==Logic.PHONERET_VERIFYSUCCESS){
				System.out.println("(IR Code Sent!)");
				finalVal+=Integer.toString(devresp);
				finalVal+=":";
				finalVal+=ircommand;
			}else{
				System.out.println("(DeviceError)");
				finalVal+=Integer.toString(devresp);
			}
		}else{
			System.out.println("(DBError)");
			finalVal="DB:";
			finalVal+=Integer.toString(DatabaseHandler.ERROR_INVALID);
		}

		out.println(finalVal);
	}
}
