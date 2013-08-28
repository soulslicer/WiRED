package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import MainPackage.DatabaseHandler;
import MainPackage.Logic;

public class PostRawLoopCount extends HttpServlet{
private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*PostRawLoopCount*");
		PrintWriter out = response.getWriter();
		String finalVal = null;
		
		StringBuffer buffer = new StringBuffer();
		String username = request.getParameter("username");
		String irdevice = request.getParameter("irdevice");
		String ircommand = request.getParameter("ircommand");
		int loopcount=Integer.parseInt(request.getParameter("loopcount"));
		
		finalVal="DB:";
		int resp=DatabaseHandler.setIRLoopAmount(username, irdevice, ircommand, loopcount);
		if(resp==DatabaseHandler.USER_LOOPUPDATED){
			System.out.println("(Loop updated)");
			finalVal+=Integer.toString(resp);
		}else{
			System.out.println("(DBError)");
			finalVal+=Integer.toString(resp);
		}
	
		out.println(finalVal);
	}
}
