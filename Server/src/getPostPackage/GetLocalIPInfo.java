package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONArray;
import MainPackage.DatabaseHandler;

public class GetLocalIPInfo  extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	@Override
	public void doGet(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*GetLocalIPInfo*");
		String finalVal=null;
		PrintWriter out = response.getWriter();
		
		String username = request.getParameter("username");
		String ip=DatabaseHandler.getLocalIP(username);
		
		finalVal="DB:";
		if(ip!=null){
			finalVal+=ip;
			System.out.println("(LocalIP found)");
			out.println(finalVal);
		}else{
			System.out.println("(No LocalIP Found)");
			finalVal+=Integer.toString(DatabaseHandler.ERROR_INVALID);
			out.println(finalVal);
		}
		
	}
}
