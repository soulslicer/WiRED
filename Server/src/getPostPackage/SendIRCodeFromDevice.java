package getPostPackage;


import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import MainPackage.DatabaseHandler;
import MainPackage.Logic;

public class SendIRCodeFromDevice extends HttpServlet {
	
	private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*SendIRCodeFromDevice*");
		PrintWriter out = response.getWriter();
		String finalVal = null;
		
		StringBuffer irdata = new StringBuffer();
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String irdevice = request.getParameter("irdevice");
		String ircommand = request.getParameter("ircommand");
		String desc = request.getParameter("desc");
		
		int resp=Logic.sendToDevice(username, password, Logic.PHONESEND_IRRECEIVE, "Send",irdata);
		if(resp==Logic.PHONERET_VERIFYSUCCESS){
			finalVal="DB:";
			int dbresp=DatabaseHandler.addIRCode(username, irdevice, ircommand, desc, irdata.toString());
			if(dbresp==DatabaseHandler.USER_IRCODEADDED){
				System.out.println("(IR Code Added!)");
				finalVal+=Integer.toString(dbresp);
			}else{
				System.out.println("(DBError)");
				finalVal+=Integer.toString(dbresp);
			}
		}else{
			System.out.println("(DeviceError)");
			finalVal="DV:";
			finalVal+=Integer.toString(resp);
		}

		out.println(finalVal);

	}
}
