/**********************************************************************
Name: ScheduleBatch_WelcomeHotAlertJob_Tests 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
Test coverage class for ScheduleBatch_WelcomeHotAlertJob Apex Class 

Related to:ScheduleBatch_WelcomeHotAlertJob
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Koseikina Anna 05/06/2015 created 
***********************************************************************/
@istest
public class ScheduleBatch_WelcomeHotAlertJob_Tests {

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   static testmethod void test() {
   Account acc = new Account();
        acc.Name = 'Test Account1234';
        Insert acc;
        
        Account acc2 = new Account();
        acc2.Name = 'Test Account2345';
        Insert acc2;         
           
       	Account acc3 = new Account();
        acc3.Name = 'Test Account3456';
        Insert acc3;
        
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Name='Test Vehicle1234';
		vehicle.Make_Name__c = 'Nissan';
		vehicle.Model_Year__c = '2015';
		vehicle.Model_Line_Name__c = 'Altima';
        Insert vehicle;
                      	 	              
        /*
           Switch to the runtime context
        */
       Test.startTest();
        
        /* 
           Create a vehicleRetailSale to test the functionality
        */
        List<Vehicle_Retail_Sale__c> vrsIns= new List<Vehicle_Retail_Sale__c>();
		String vrsRecordTypeId = RecordtypeUtil.getObjectRecordTypeId(Vehicle_Retail_Sale__c.SObjectType, 'RDR');
        
		
        Vehicle_Retail_Sale__c vehicleRetailSale = new Vehicle_Retail_Sale__c();
          
            vehicleRetailSale.Owner_Id__c = acc.id;
            vehicleRetailSale.Vehicle_Identification_Number__c = vehicle.id;
            vehicleRetailSale.Rewind_Indicator__c = true;
			vehicleRetailSale.recordTypeId = vrsRecordTypeId;
			vehicleRetailSale.Purchase_Date__c = Date.newInstance(2015, 4, 27);
            vrsIns.add(vehicleRetailSale);
            
            insert vrsIns;

      // Schedule the test job
	  DateTime nextSchedule = DateTime.now().addSeconds(5);

      String jobId = System.schedule('ScheduleWelcomeTest', nextSchedule.format('ss mm HH dd MM ? yyyy'), new ScheduleBatch_WelcomeHotAlertJob ());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];


      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);
      
      Test.stopTest();


   }
}