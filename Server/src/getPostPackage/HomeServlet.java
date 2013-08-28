package getPostPackage;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class HomeServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	@Override
	public void doGet(HttpServletRequest request,
			HttpServletResponse response)
					throws ServletException, IOException {
		response.setContentType("text/html");
		String param = request.getParameter("param");
		System.out.println(param);
		PrintWriter out = response.getWriter();

		String docType =
				"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 " +
						"Transitional//EN\">\n";
		out.println(docType +
				"<HTML>\n" +
				"<HEAD><TITLE>Hello World</TITLE></HEAD>\n" +
				"<BODY BGCOLOR=\"#FDF5E6\">\n" +
				"<H1>Welcome to WiRED Server</H1>\n" +
				"<a href=\"#\" onclick=\"javascript:window.location.port=8082\">SQL Database</a>" +
				"</BODY></HTML>");
	}
}
