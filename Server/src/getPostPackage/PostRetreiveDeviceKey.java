package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import MainPackage.DatabaseHandler;

public class PostRetreiveDeviceKey extends HttpServlet{
private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*PostRetreiveDeviceKey*");
		PrintWriter out = response.getWriter();
		String finalVal = null;
		
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		
		String resp=DatabaseHandler.getDeviceKey(username, password);
		if(resp!=null){
			System.out.println("(DeviceKey Retreived)");
			finalVal=resp;
		}else{
			System.out.println("(DBError)");
			finalVal="null";
		}
	
		out.println(finalVal);
	}
}