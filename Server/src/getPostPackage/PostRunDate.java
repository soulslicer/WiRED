package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import MainPackage.DatabaseHandler;
import MainPackage.Logic;

public class PostRunDate extends HttpServlet{
private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*PostRunDate*");
		PrintWriter out = response.getWriter();
		String finalVal = null;
		
		StringBuffer buffer = new StringBuffer();
		String username = request.getParameter("username");
		String rundate = request.getParameter("rundate");
		String irdevice = request.getParameter("irdevice");
		String ircommand = request.getParameter("ircommand");
		
		finalVal="DB:";
		
		int resp=DatabaseHandler.setRunDate(username, irdevice, ircommand, rundate);
		if(resp==DatabaseHandler.USER_RUNDATESET){
			System.out.println("(Rundate set!)");
			finalVal+=Integer.toString(resp);
		}else{
			finalVal+=Integer.toString(DatabaseHandler.ERROR_INVALID);
		}

		out.println(finalVal);
	}
}