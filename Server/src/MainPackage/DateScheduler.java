package MainPackage;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class DateScheduler {
	ScheduledExecutorService execService = Executors.newScheduledThreadPool(3);
	
	public DateScheduler(){}
	
	public void taskToRun(){
		java.util.Date date= new java.util.Date();
		Timestamp timestamp=new Timestamp(date.getTime());
		String startTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:00").format(timestamp);
		String endTime=new SimpleDateFormat("yyyy-MM-dd HH:mm:59").format(timestamp);

		List<TimeMatchObject> timeMatchList=DatabaseHandler.getMatchingTimes(startTime, endTime);
		if(timeMatchList.size()!=0){
			for(int i=0;i<timeMatchList.size();i++){
				StringBuffer buffer = new StringBuffer();
				TimeMatchObject tObject=timeMatchList.get(i);
				System.out.println("(Sending data: "+tObject.username+")");
				
				if(tObject!=null){
					int devresp=Logic.sendToDevice(tObject.username, tObject.password, Logic.PHONESEND_IRSNDMODE, tObject.irdata,buffer);
					if(devresp==Logic.PHONERET_VERIFYSUCCESS)
						System.out.println("(IR Code Sent!)");
					else
						System.out.println("(DeviceError)");
				}
				
			}
		}else{
			System.out.println("Nothing to send for "+startTime);
		}
		
	}
	
	public void start(){
		execService.scheduleAtFixedRate(new Runnable() {
			  public void run() {
				  taskToRun();
			    //System.err.println("Hello, World");
			  }
			}, 0L, 60L, TimeUnit.SECONDS);
	}
	
	public void stop(){
		execService.shutdown();
	}
}
