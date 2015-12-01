/**********************************************************************
Name: Task_Before_Test
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of "Task_Before" Trigger

Related to: TaskClass
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Mohd Afraz Siddiqi 01/19/2011 Created
2.0 - Mohd Afraz Siddiqi 01/20/2011 Upadted class to increase Test Coverage
3.0 - Mohd Afraz Siddiqi 01/24/2011 Upadted class to increase Test Coverage
4.0 - Mohd Afraz Siddiqi 01/25/2011 Upadted class to increase Test Coverage
5.0 - Vlad Martynenko    03/13/2015 Added User_Role_Check_Enabled__c instead of System.Label.USER_ROLE_CHECK_ENABLED
***********************************************************************/
@isTest
private Class Task_Before_Test {

	private static void InsertUserRoleCheckSetting(){
		User_Role_Check_Enabled__c userRoleCusomSetting = new User_Role_Check_Enabled__c();
		userRoleCusomSetting.Is_User_Validation_Enabled__c = false;
		insert userRoleCusomSetting;
	}

    static testMethod void testTriggerUpdatefromAccount() {
     InsertUserRoleCheckSetting();
     String personType = System.Label.AccRTMaritz;
     RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];

        /* 
            Create a Contact,Account & Task to test the functionality
        */
                        
        Account accRec = new Account();
        accrec.RecordTypeId = personTypeRT.id;
        accrec.lastName = 'TestAccount';
        insert accRec;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        insert con;
        

             
        Task TaskRec = new Task();
        TaskRec.First_Name__c = 'Temp';
        TaskRec.whatid = accRec.PersonContactId;
        TaskRec.WhoId = accRec.PersonContactId;
        TaskRec.Call_End_Time__c = system.now();
        TaskRec.Subject = 'Test123';
        TaskRec.FailedCall__c = true;
        insert TaskRec;
      
        /*
            Switch to the runtime context
        */
       
        Test.startTest();
        
        TaskRec.Postal_Code__c= accRec.PersonMailingPostalCode;
        TaskRec.Subject='TestSubject';
        TaskRec.WhoId = accRec.PersonContactId;
        TaskRec.whatid = accRec.id;
        TaskRec.Call_End_Time__c = System.now();
        update TaskRec;       
         
        /*
            Switch back to the original context
        */        
            
        Test.StopTest();
    
        /*
          Query the database for the updated records
          
        */
            
        List<Task> UpdateTaskList = [select Salutation__c,Dealer_Code__c,Phone__c,Work_Phone__c,Country__c,First_Name__c,
                                   City__c,Last_Name__c,Street__c,Middle_Name__c,Mobile_Phone__c,Mobile_Phone_Consent__c,
                                   Phone_Consent__c,State__c,Work_Email_Consent__c,Email_Consent__c,Work_Email__c,
                                   Work_Phone_Consent__c from Task where whatId=:accRec.Id];
        system.assert(UpdateTaskList.size() == 1);
    }
      
    static testMethod void testTriggerUpdatefromDisposition() {
        InsertUserRoleCheckSetting();
         /* 
            Create a Disposition__c & Task to test the functionality
        */
        
        Disposition__c disPos = new Disposition__c();
        disPos.Name ='Test';
        insert disPos;
         
        Task TaskRec = new Task();
        TaskRec.CallDisposition__c = disPos.Name;
        TaskRec.Call_End_Time__c = System.now();
        insert TaskRec;
        /*
            Start the test, this changes governor limit context to
           that of trigger rather than test.
        */
        
        Test.startTest();
       
        update TaskRec;
        
        /*
           Stop the test, this changes limit context back to test from trigger. 
        */        
        Test.StopTest();
        
        
        /*
          Query the database for the updated records  
        */
        
        List<Task> UpdateTaskList = [select TMS_Disposition__c,Dialer_Disposition__c from Task where CallDisposition__c =: disPos.Name];
        system.assert(UpdateTaskList.size() == 1);
    }
   
    static testMethod void testTriggerUpdatefromCampaign() {
		InsertUserRoleCheckSetting();
        /* 
            Create a Contact,Campaign,CampaignMember & Task to test the functionality
        */
        
        Contact con = new Contact();
        con.LastName = 'Test';
        insert con;
     
        Campaign camp = new Campaign();
        camp.Name = 'Test';
        camp.IsActive = true;
        insert camp;
     
        CampaignMember campMember = new CampaignMember();
        campMember.CampaignId = camp.Id;
        campMember.ContactId = con.Id;
        campMember.Service_Marketing_Call_ID__c = Integer.valueOf('122');
        campMember.Phone_1__c ='1233';
        campMember.Preferred_Phone_Type__c = 'TestType';
        campMember.Preferred_Mail_Type__c = 'Test';
        campMember.Preferred_Call_Time__c = '123';
        insert campMember;
         
        Task TaskRec = new Task();
        TaskRec.Description = 'Initial Description';
        TaskRec.WhoId = con.Id;
        TaskRec.Call_End_Time__c = System.now();
       
        insert TaskRec;
        TaskRec.CallDisposition__c  = 'test';
        /*
            Start the test, this changes governor limit context to
           that of trigger rather than test.
        */
          
        Test.startTest();
        TaskRec.WhoId = con.Id;
        TaskRec.Language__c = campMember.Language__c;
        update TaskRec;   
        
        /*
           Stop the test, this changes limit context back to test from trigger. 
        */        
        Test.StopTest();
        
        /*
           Query the database for the updated records
        */
        //Service_Marketing_Call_Id__c
      
        List<Task> UpdateTaskList = [select Call_Phone__c,Language__c,
                                   Preferred_Phone_Type__c,Preferred_Mail_Type__c,Preferred_Call_time__c from Task where WhoId =:con.Id];
        system.assert(UpdateTaskList.size() == 1);
    
    }
    
    static testMethod void testTriggerUpdatefromUsers() {
		InsertUserRoleCheckSetting();
        /* 
            Create a User,Case & Task to test the functionality
        */
        User useRec = [Select id,CallcenterId,Agent_Id__c from user where id=:userinfo.getUserId() ];    
        
        Case CaseRec = new Case();
        //CaseRec.Call_Start_Time__c = datetime.now();
        insert CaseRec; 
        
        String personType = System.Label.AccRTMaritz;
        RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        
        Account accRec = new Account();
        accrec.RecordTypeId = personTypeRT.id;
        accRec.lastName = 'TestAccount';
        insert accRec;
         
        Task TaskRec = new Task();
        TaskRec.Description = 'Initial Description';
        TaskRec.whatId = CaseRec.Id;
        TaskRec.WhoId = accRec.PersonContactId;
        TaskRec.OwnerId = useRec.Id;
        TaskRec.Call_End_Time__c = System.now();
        insert TaskRec; 
         
        /*
           Start the test, this changes governor limit context to
           that of trigger rather than test.
        */
         
        Test.startTest();
        TaskRec.whatId = CaseRec.Id;
        //TaskRec.WhoId = accRec.PersonContactId;
        update TaskRec;   
    
        /*
           Stop the test, this changes limit context back to test from trigger. 
        */        
              
        Test.StopTest();
        
        /*
             Query the database for the updated records  
        */
              
        List<Task> UpdateTaskList = [select Agent_Id__c from Task where whatId=:CaseRec.Id];
        system.assert(UpdateTaskList.size() == 1);        
   }
   
   static testMethod void testTriggerUpdatefromVehicle() {
		InsertUserRoleCheckSetting();
        /* 
            Create a Vehicle,Campaign,Contact,CampaignMember & Task to test the functionality
        */
        
        Vehicle__c vehic = new Vehicle__c();
        vehic.Latest_Recorded_Mileage_Units__c = '1';
        vehic.Latest_Recorded_Mileage_Number__c = Integer.valueOf('1');
        vehic.PMG_Type__c='Test';
        vehic.vehicle_Identification_Number__c = '123$#$';
        insert vehic;
     
        Campaign camp = new Campaign();
        camp.Name = 'Test';
        camp.IsActive = true;
        insert camp;
     
        Contact con = new Contact();
        con.LastName ='Test';
        insert con;
     
        CampaignMember campMember = new CampaignMember();
        campMember.CampaignId = camp.Id;
        campMember.ContactId = con.Id;
        //campMember.Service_Marketing_Call_ID__c = Integer.valueOf('122');
        campMember.Phone_1__c ='1233';
        campMember.Preferred_Phone_Type__c = 'Test1';
        campMember.Preferred_Mail_Type__c = 'Test';
        campMember.Preferred_Call_Time__c = '123';
        campMember.Vehicle__c = vehic.Id;
        insert campMember;
    
        Task TaskRec = new Task();
        TaskRec.Description = 'Initial Description';
        TaskRec.WhoId = con.Id;
        TaskRec.Call_End_Time__c = System.now();
        insert TaskRec;
        
        /*
           Start the test, this changes governor limit context to
           that of trigger rather than test.
        */
        
        Test.startTest();
        TaskRec.Call_End_Time__c = system.now();
        update TaskRec;   
        /*
            Stop the test, this changes limit context back to test from trigger. 
        */        
          
        Test.StopTest();
     
        List<Task> UpdateTaskList = [select Odometer_Units__c, Odometer_Reading__c, PMG_Type__c from Task where WhoId = :con.Id];
        system.assert(UpdateTaskList.size() == 1);
    }
    
    static testMethod void testMethods() {
       
        Task task = new Task();
        //Service_Marketing_Call_Id__c = 22
        CampaignMember mem = new CampaignMember ( Phone_1__c = '11', 
                        Language__c = 'test', Preferred_Phone_Type__c = 'test',
                        Preferred_Mail_Type__c = 'test', Preferred_Call_time__c = 'test');
        //TaskClass.updateCampaignMemberFields(task, mem) ;
        Vehicle__c vehicle = new Vehicle__c(Latest_Recorded_Mileage_Units__c = '1',
                            Latest_Recorded_Mileage_Number__c = 11, PMG_Type__c = '');
        TaskClass.updateVehicleFields(task, vehicle);
        
        Account account = new Account (Salutation = '',FirstName = '', PersonDoNotCall=false,
                                    Other_Phone_Do_Not_Call_In__c = 'YES',Mobile_Phone_Do_Not_Call_Indicator__c = 'YES'
                                    ,Do_Not_Email_In__c  = 'YES');
                                   
        TaskClass.updateAccountFields(task, account);   
         
    }

    static testMethod void testInsertDealerCallBack() {
		InsertUserRoleCheckSetting();
        RecordType taskGeneralRT = [select id, name from recordtype where name = 'General' and sobjecttype = 'Task' limit 1];       	
        List<Task> tasks = new List<Task>();
        //24hr Dealer Call Back
        for (Integer i = 0; i < 2; i ++) {
        	tasks.add(new Task(RecordTypeID = taskGeneralRT.ID, Subject=System.Label.Task_Subject_24hr_Dealer_Call_Back));
        }
        
        //48hr Dealer Call Back
        for (Integer i = 0; i < 2; i ++) {
        	tasks.add(new Task(RecordTypeID = taskGeneralRT.ID, Subject=System.Label.Task_Subject_48hr_Dealer_Call_Back));
        }
        
        /*//Holidays
        DateTime testDate = System.now();
        Set<Date> holidayDates = HolidayCalculator.AllHolidaysOfLastCurrentAndNextYearOfDay(testDate.date());
        
        List<Holiday> holidays = new List<Holiday>();
        
        //make today holiday
		if (!HolidayCalculator.isDayOff(testDate, holidayDates))
			holidays.add(new Holiday(Name='HHHHHHHHHHH1',ISALLDAY=true,ACTIVITYDATE=testDate.date(), ISRECURRENCE=false));
		System.Debug('make today holiday ' + testDate);
		
		//get the very next work day, this is the time 23 or 47 hours counting begins
		testDate = testDate.addDays(1);
		while (HolidayCalculator.isDayOff(testDate, holidayDates))
			testDate = testDate.addDays(1);
		System.Debug('get the very next work day ' + testDate);
		
		//make the next day holiday
		testDate = testDate.addDays(1);
		if (!HolidayCalculator.isDayOff(testDate, holidayDates))
			holidays.add(new Holiday(Name='HHHHHHHHHHH2',ISALLDAY=true,ACTIVITYDATE=testDate.date(), ISRECURRENCE=false));
		System.Debug('make the next day holiday ' + testDate);
		
		//get the very next work day, this is where 23hour lands and 24 hour of 47hour counting begins
		testDate = testDate.addDays(1);
		System.Debug('&&&&& ' + testDate);
		while (HolidayCalculator.isDayOff(testDate, holidayDates)) {
			testDate = testDate.addDays(1);
			System.Debug('&&&&& ' + testDate);
		}
		System.Debug('get the very next work day ' + testDate);
		
		//make the next day holiday
		testDate = testDate.addDays(1);
		if (!HolidayCalculator.isDayOff(testDate, holidayDates))
        	holidays.add(new Holiday(Name='HHHHHHHHHHH3',ISALLDAY=true,ACTIVITYDATE=testDate.date(), ISRECURRENCE=false));
        System.Debug('make the next day holiday ' + testDate);
        
 		insert holidays;*/
		
		test.startTest();
		insert tasks;
		test.stopTest();
		
		for (Task t : [Select X24hr_Due_Date_Time__c, X48hr_Due_Date_Time__c From Task where ID in: tasks])
        	System.Debug('*** X24hr_Due_Date_Time__c: ' + t.X24hr_Due_Date_Time__c + ', X48hr_Due_Date_Time__c: ' +  t.X48hr_Due_Date_Time__c);
    }
}