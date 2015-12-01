@isTest
private class EmailMessage_After_Test { 
	static testmethod void testTriggerEmailMessageAfter() {
        String personType = System.Label.AccRTMaritz;
        RecordType personTypeRT = [select id, name from recordtype where name =: personType and sobjecttype = 'Account' limit 1];
        RecordType DPICTypeRT = [select id, name from recordtype where name = 'DPIC' and sobjecttype = 'Case' limit 1];
		
		List<Account> testAccounts = new List<Account>();
		for (Integer i = 0; i < 5; i ++) {
	        Account testAccount = new Account();
	        testAccount.RecordTypeId = personTypeRT.id;
	        testAccount.lastName = 'TestAccount';
	        testAccount.PersonEmail = 'test@abc.org';
	        
	        testAccounts.add(testAccount);
		}
        insert testAccounts;
        
        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 5; i ++) {
	        Case testCase = new Case();
	        testCase.ContactID = testAccounts[i].PersonContactId;
	        testCase.RecordTypeId = DPICTypeRT.Id;
	        testCase.Subject = 'email to case';
	        
	        testCases.add(testCase);
        }
        insert testCases; 
		
		List<Task> testTasks = new List<Task>();
        for (Integer i = 0; i < 5; i ++) {
        	Task testTask = new Task();
	        testTask.whatId = testCases[i].Id;
	        testTask.WhoId = testCases[i].ContactID;
	        testTask.ActivityDate = System.today();
	        testTask.Subject = 'Today Email Task';
	        
	        testTasks.add(testTask);
        } 
        insert testTasks; 

		Test.startTest();
		
		EmailMessage[] newEmail = new EmailMessage[0];
		for (Integer i = 0; i < 5; i ++) {
			newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', 
				Incoming = True, 
				ToAddress= 'hello@emailservice.myorg.com', 
				Subject = 'Test email', 
				TextBody = '23456 ', 
				ParentId = testTasks[i].WhatId,
				ActivityId = testTasks[i].Id)); 
			newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', 
				Incoming = True, 
				ToAddress= 'hello@emailservice.myorg.com', 
				Subject = 'Test email', 
				TextBody = '23456 ', 
				ParentId = testTasks[i].WhatId)); 
		}
		insert newEmail;
		system.debug('*** newEmail ' + newEmail);
		
		for (Task t : [Select Subject, ActivityDate From Task Where ID in: testTasks]) {
			system.debug('*** ActivityDate ' + t.ActivityDate);
			system.assert(System.today().daysbetween(t.ActivityDate) >= 1);
		}
	    Test.stopTest();
	}
	static testmethod void testTriggerEmailMessageForClosedCaseWithin30days() {
        
        String personTypeRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(System.Label.AccRTMaritz).getRecordTypeId();
        String infinityRtypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(Label.CA_Email_Infiniti).getRecordTypeId();
                
        Account testAccount = new Account();
        testAccount.RecordTypeId = personTypeRTId;
        testAccount.lastName = 'TestAccount';
        testAccount.PersonEmail = 'test@abc.org';
        
        insert testAccount;       
       
       
        Case testCase = new Case();
        testCase.ContactID = testAccount.PersonContactId;
        testCase.RecordTypeId = infinityRtypeId;
        testCase.Subject = 'email to case';
        insert testCase; 
        
        List<Code__c> codeList = new List<Code__c>();
        Code__c concern = new Code__c(Type__c = 'Concern', Code__c = 'OA', Description__c = 'VEHICLE CONCERNS');
        codeList.add(concern);
        Code__c category = new Code__c(Type__c = 'Category', Code__c = 'AA', Description__c = 'AUDIO/VIDEO/NAVI');
        codeList.add(category);
        Code__c subcategory = new Code__c(Type__c = 'Subcategory', Code__c = '136500', Description__c = 'STARTER');
        codeList.add(subcategory);
        Code__c symptom = new Code__c(Type__c = 'Symptom', Code__c = 'ZA', Description__c = 'ACCESSORIES DISCREPANCY');   
        codeList.add(symptom);     
        Code__c rootcause = new Code__c(Type__c = 'Root_Cause_Code', Code__c = 'RootCause', Description__c = 'RootCause');
        codeList.add(rootcause);  
        Code__c majComponent = new Code__c(Type__c = 'Major Component Code', Code__c = 'MC', Description__c = 'ACCESSORIES DISCREPANCY');
        codeList.add(majComponent);  
        
        insert codeList;
        
        List<Case_Categorization__c> caseCats = new List<Case_Categorization__c>();
        Case_Categorization__c caseCat = new Case_Categorization__c();
        caseCat.Concern__c = concern.Id;
        caseCat.Category__c = category.Id;
        caseCat.Subcategory__c = subcategory.Id;
        caseCat.Symptom__c = symptom.Id;
        caseCat.Case__c = testCase.Id;
        caseCats.add(caseCat);
        insert caseCats;
        
        CaseCategory_Dependency__c catDependency = new CaseCategory_Dependency__c(Major_Component_Code__c = 'MC', Subcategory__c = subcategory.Id, Symptom__c = symptom.Id);
    insert catDependency;       
        
        testCase.Status = 'Closed';
        testCase.Special_Root_Cause_Closing_Code__c = rootcause.Id;
        update testCase;
        
        Test.startTest();
        Task testTask = new Task();
        testTask.whatId = testCase.Id;
        testTask.WhoId = testCase.ContactID;
        testTask.ActivityDate = System.today();
        testTask.Subject = 'Today Email Task';
 
        insert testTask; 
        
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', 
            Incoming = True, 
            ToAddress= 'hello@emailservice.myorg.com', 
            Subject = 'Test email', 
            TextBody = '23456 ', 
            ParentId = testTask.WhatId,
            ActivityId = testTask.Id)); 
       
        insert newEmail;
        Test.stopTest();
        
       // System.assert([Select Status from Case where Id =:testCase.Id].Status == 'Open', true);
        System.assertequals([Select CA_CaseReopenCount__c from Case where Id =:testCase.Id].CA_CaseReopenCount__c, 1);
        
    }
    
     static testmethod void testTriggerEmailMessageForClosedCaseNissan() {
        
        String personTypeRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(System.Label.AccRTMaritz).getRecordTypeId();
        String nissanRtypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(Label.CA_Email_Nissan).getRecordTypeId();
                
        Account testAccount = new Account();
        testAccount.RecordTypeId = personTypeRTId;
        testAccount.lastName = 'TestAccount';
        testAccount.PersonEmail = 'test@abc.org';
        
        insert testAccount;       
       
       
        Case testCase = new Case();
        testCase.ContactID = testAccount.PersonContactId;
        testCase.RecordTypeId = nissanRtypeId;
        testCase.Subject = 'email to case';
        testCase.CreatedDate =  Datetime.now() - 31;       
        insert testCase; 
        
        List<Code__c> codeList = new List<Code__c>();
        Code__c concern = new Code__c(Type__c = 'Concern', Code__c = 'OA', Description__c = 'VEHICLE CONCERNS');
        codeList.add(concern);
        Code__c category = new Code__c(Type__c = 'Category', Code__c = 'AA', Description__c = 'AUDIO/VIDEO/NAVI');
        codeList.add(category);
        Code__c subcategory = new Code__c(Type__c = 'Subcategory', Code__c = '136500', Description__c = 'STARTER');
        codeList.add(subcategory);
        Code__c symptom = new Code__c(Type__c = 'Symptom', Code__c = 'ZA', Description__c = 'ACCESSORIES DISCREPANCY');   
        codeList.add(symptom);     
        Code__c rootcause = new Code__c(Type__c = 'Root_Cause_Code', Code__c = 'RootCause', Description__c = 'RootCause');
        codeList.add(rootcause);  
        Code__c majComponent = new Code__c(Type__c = 'Major Component Code', Code__c = 'MC', Description__c = 'ACCESSORIES DISCREPANCY');
        codeList.add(majComponent);  
        
        insert codeList;
        
        List<Case_Categorization__c> caseCats = new List<Case_Categorization__c>();
        Case_Categorization__c caseCat = new Case_Categorization__c();
        caseCat.Concern__c = concern.Id;
        caseCat.Category__c = category.Id;
        caseCat.Subcategory__c = subcategory.Id;
        caseCat.Symptom__c = symptom.Id;
        caseCat.Case__c = testCase.Id;
        caseCats.add(caseCat);
        insert caseCats;
        
        CaseCategory_Dependency__c catDependency = new CaseCategory_Dependency__c(Major_Component_Code__c = 'MC', Subcategory__c = subcategory.Id, Symptom__c = symptom.Id);
    insert catDependency;       
        
        testCase.Status = 'Closed';
        testCase.Special_Root_Cause_Closing_Code__c = rootcause.Id;
        update testCase;
        
        Test.startTest();
        Task testTask = new Task();
        testTask.whatId = testCase.Id;
        testTask.WhoId = testCase.ContactID;
        testTask.ActivityDate = System.today();
        testTask.Subject = 'Today Email Task';
 
        insert testTask; 
        
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', 
            Incoming = True, 
            ToAddress= 'hello@emailservice.myorg.com', 
            Subject = 'Test email', 
            TextBody = '23456 ', 
            ParentId = testTask.WhatId,
            ActivityId = testTask.Id)); 
    
        insert newEmail;

        Test.stopTest();
        
    //System.assert([Select Status from Case where Id =:testCase.Id].Status == 'Open', true);
    System.assertequals([Select CA_CaseReopenCount__c from Case where Id =:testCase.Id].CA_CaseReopenCount__c, 1);    
        
    }
}