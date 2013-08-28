package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.simple.JSONArray;
import MainPackage.DatabaseHandler;

public class GetIRCodeList  extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	@Override
	public void doGet(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*GetIRCodesList*");
		String finalVal=null;
		PrintWriter out = response.getWriter();
		
		JSONArray list=null;
		String username = request.getParameter("username");
		String irdevice=request.getParameter("irdevice");
		list=DatabaseHandler.getIRCodesList(username, irdevice);
		
		if(list!=null){
			System.out.println("(IRCodes found)");
			out.println(list.toJSONString());
		}else{
			System.out.println("(Nothing Found for IRCodes)");
			finalVal="DB:";
			finalVal+=Integer.toString(DatabaseHandler.ERROR_INVALID);
			out.println(finalVal);
		}
		
	}
}
