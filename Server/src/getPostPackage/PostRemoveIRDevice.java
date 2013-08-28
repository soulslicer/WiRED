package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import MainPackage.DatabaseHandler;

public class PostRemoveIRDevice extends HttpServlet{
private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*PostRemoveIRDevice*");
		PrintWriter out = response.getWriter();
		String finalVal = null;
		
		String username = request.getParameter("username");
		String irdevice = request.getParameter("irdevice");
		
		finalVal="DB:";
		int resp=DatabaseHandler.removeIRDevice(username, irdevice);
		if(resp==DatabaseHandler.USER_IRTABLEREMOVED){
			System.out.println("(IRCode removed)");
			finalVal+=Integer.toString(resp);
		}else{
			System.out.println("(DBError)");
			finalVal+=Integer.toString(DatabaseHandler.ERROR_INVALID);
		}
	
		out.println(finalVal);
	}
}