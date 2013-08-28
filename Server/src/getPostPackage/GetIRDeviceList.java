package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import MainPackage.DatabaseHandler;

public class GetIRDeviceList  extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	@Override
	public void doGet(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
		System.out.println("*GetIRDeviceList*");
		String finalVal=null;
		PrintWriter out = response.getWriter();
		
		JSONArray list=null;
		String username = request.getParameter("username");
		list=DatabaseHandler.getIRDevicesList(username);
		
		if(list!=null){
			System.out.println("(IRDevices found)");
			out.println(list.toJSONString());
		}else{
			System.out.println("(Nothing Found for IRDevices)");
			finalVal="DB:";
			finalVal+=Integer.toString(DatabaseHandler.ERROR_INVALID);
			out.println(finalVal);
		}
		
	}
}
