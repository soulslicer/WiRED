package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import MainPackage.DatabaseHandler;

public class GetRegisteredStatus  extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	@Override
	public void doGet(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*GetRegisteredStatus*");
		String finalVal=null;
		PrintWriter out = response.getWriter();
		
		String username = request.getParameter("username");
		String devicekey= request.getParameter("devicekey");
		int status=DatabaseHandler.getRegisteredStatus(username, devicekey);
		
		finalVal="DB:";
		if(status==DatabaseHandler.USER_DEVICEREGISTERED){
			finalVal+=Integer.toString(status);
			System.out.println("(Device Registered)");
			out.println(finalVal);
		}else{
			System.out.println("(Device not registered yet)");
			finalVal+=Integer.toString(DatabaseHandler.ERROR_INVALID);
			out.println(finalVal);
		}
		
	}
}