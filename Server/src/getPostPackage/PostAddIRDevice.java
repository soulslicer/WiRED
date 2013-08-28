package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import MainPackage.DatabaseHandler;

public class PostAddIRDevice extends HttpServlet{
private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*PostAddIRDevice*");
		PrintWriter out = response.getWriter();
		String finalVal = null;
		
		String username = request.getParameter("username");
		String irdevice = request.getParameter("irdevice");
		String desc = request.getParameter("desc");
		
		finalVal="DB:";
		int resp=DatabaseHandler.addUpdateIRDevice(username, irdevice, desc);
		if(resp==DatabaseHandler.USER_IRTABLEADDED){
			System.out.println("(IRDevice added)");
			finalVal+=Integer.toString(resp);
		}else if(resp==DatabaseHandler.USER_IRTABLEUPDATED){
			System.out.println("(IRDevice updated)");
			finalVal+=Integer.toString(resp);
		}else{
			System.out.println("(DBError)");
			finalVal+=Integer.toString(DatabaseHandler.ERROR_INVALID);
		}
	
		out.println(finalVal);
	}
}
