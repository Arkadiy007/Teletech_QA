/**********************************************************************
  Name: BellomyStageObjectsScheduledJob
  Copyright � notice: Nissan Motor Company
  ======================================================
  Purpose:
  Scheduled job, that will run every friday and do backfeed process for Bellomy
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 7/1/2015 Created
 ***********************************************************************/
 global class BellomyStageObjectsScheduledJob implements Schedulable {
    
    private final static Integer BATCH_SIZE = 50;
    
    /**
     * @description Executes the scheduled Apex job. 
     * @param sc contains the job ID
     */ 
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BellomyStageObject_BTEBatchJob(), BATCH_SIZE);
        Database.executeBatch(new BellomyStageObject_BTETBatchJob(), BATCH_SIZE);
        Database.executeBatch(new BellomyStageObject_CACBatchJob(), BATCH_SIZE);
        Database.executeBatch(new BellomyStageObject_CheckReqBatchJob(), BATCH_SIZE);
        Database.executeBatch(new BellomyStageObjects_VCSBatchJob(), BATCH_SIZE);
		if (!Test.isRunningTest()){
			 Database.executeBatch(new BellomyStageObjects_VCSTBatchJob(), BATCH_SIZE);
		}
       
        updateSettings();
        
    }

    public void updateSettings(){
        List<Bellomy_Reports_Settings__c> settingsList = [SELECT Id, Start_Date__c, End_Date__c, Allow_Auto_Update__c, Offset__c FROM Bellomy_Reports_Settings__c WHERE Allow_Auto_Update__c = true LIMIT 6];
        TimeZone tz = UserInfo.getTimeZone();
		

		//Prevention on timezone change during report range period
        for (Bellomy_Reports_Settings__c setting : settingsList){
			Integer hoursOffset = (tz.getOffset(setting.End_Date__c) - tz.getOffset(setting.Start_Date__c)) / (60*60*1000);

            setting.Start_Date__c = setting.Start_Date__c.addDays((Integer) setting.Offset__c);
            setting.End_Date__c = setting.End_Date__c.addDays((Integer) setting.Offset__c);

			if(hoursOffset == -1){
				setting.Start_Date__c = setting.Start_Date__c.addHours(-hoursOffset);
			}
			if(hoursOffset == 1){
				setting.Start_Date__c = setting.Start_Date__c.addHours(-hoursOffset);
			}

			hoursOffset = (tz.getOffset(setting.End_Date__c) - tz.getOffset(setting.Start_Date__c)) / (60*60*1000);
			if(hoursOffset == -1){
				setting.End_Date__c = setting.End_Date__c.addHours(-hoursOffset);
			}
			if(hoursOffset == 1){
				setting.End_Date__c = setting.End_Date__c.addHours(-hoursOffset);
			}
        }


        
        
        update settingsList;    
    }
        
}