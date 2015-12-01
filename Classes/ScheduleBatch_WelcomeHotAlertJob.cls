/**********************************************************************
Name: ScheduleBatch_WelcomeHotAlertJob
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules ScheduleBatch_WelcomeHotAlertJob job to run.
String sch = '0 0 0,3,6,9,12,15,18,21 ? * *';
System.schedule('ScheduleBatch_WelcomeHotAlertJob', sch, new ScheduleBatch_WelcomeHotAlertJob ();
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Anna Koseikina      04/21/2015 Created
***********************************************************************/
global class ScheduleBatch_WelcomeHotAlertJob implements Schedulable{    
    global void execute(SchedulableContext SC) {       
		Batch_Welcome_HotAlert batchJob = new Batch_Welcome_HotAlert();
		Database.executeBatch(batchJob);
		
    }
}