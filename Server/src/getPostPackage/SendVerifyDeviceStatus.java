package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import MainPackage.DatabaseHandler;
import MainPackage.Logic;

public class SendVerifyDeviceStatus extends HttpServlet{
private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*SendVerifyDeviceStatus*");
		PrintWriter out = response.getWriter();
		String finalVal = null;
		
		StringBuffer getData = new StringBuffer();
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		
		finalVal="DV:";
		int resp=Logic.sendToDevice(username, password, Logic.PHONESEND_VERIFYSEND, "Verify", getData);

		if(resp==Logic.PHONERET_VERIFYSUCCESS){
			System.out.println("(Device send verified)");
			finalVal+=Integer.toString(resp);
		}else{
			System.out.println("(DeviceError)");
			finalVal+=Integer.toString(resp);
		}
	
		out.println(finalVal);
	}
}