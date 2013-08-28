package MainPackage;

import java.util.ArrayList;
import java.util.List;

public class BlockerCheck {
	
	List<String> blockerList;
	
	public BlockerCheck(){
		blockerList=new ArrayList<String>();
	}
	
	public synchronized void addBlock(String ip,int port){
		String finalString=ip+":"+Integer.toString(port);
		blockerList.add(finalString);
		System.out.println("BLOCKED: "+blockerList.size());
	}
	
	public synchronized void removeBlock(String ip,int port){
		String finalString=ip+":"+Integer.toString(port);
		blockerList.remove(finalString);
		System.out.println("UNBLOCKED: "+blockerList.size());
	}
	
	public synchronized boolean isAvailable(String ip,int port){
		//System.out.print("CHECKING");
		String finalString=ip+":"+Integer.toString(port);
		return !(blockerList.contains(finalString));
	}
}
