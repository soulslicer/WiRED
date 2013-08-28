package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import MainPackage.DatabaseHandler;

public class PostLoginInfo extends HttpServlet{
private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*PostLoginInfo*");
		PrintWriter out = response.getWriter();
		String finalVal = null;
		
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		
		finalVal="DB:";
		boolean resp=DatabaseHandler.checkValidUser(username, password);
		if(resp){
			System.out.println("(Login Info Valid)");
			finalVal+=Integer.toString(DatabaseHandler.USER_LOGINCORRECT);
		}else{
			System.out.println("(DBError)");
			finalVal+=Integer.toString(DatabaseHandler.ERROR_INVALID);
		}
	
		out.println(finalVal);
	}
}
