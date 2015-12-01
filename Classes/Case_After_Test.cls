/**********************************************************************
Name: Case_After_Test 
Copyright © notice: Nissan Motor Company . 
======================================================
Purpose: 
This class contains unit tests for validating the behavior of "Case_After" Apex Trigger.

Related to: Case_After
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Biswa Ray 01/02/2011 Created
1.2 - Biswa Ray 01/11/2011 Incorporated Code Comments and Headers.
1.3 - Sonali Bhardwaj 02/16/2011 Added more test cases for negative testing.
1.4 - Yuli Fintescu 05/30/2011 Added test method for Case_Before
1.5 - Yuli Fintescu 09/22/2011 Added test method for updating vehicle last mileage when case has current mileage
1.6 - Yuli Fintescu 11/22/2011 Added test method for email to case
1.7 - Yuli Fintescu 01/25/2012 Added test method for new logic of 1.5
1.8 - Will Taylor    9/12/2014 Added test coverage for VCS/LEAF and DTS
1.9 - Arkadiy Sychev 12/16/2014 Added test method for new logic of 1.18
1.10 - Anna Koseykina 12/19/2014 Added test method for new logic of 1.20 
1.11 - Arkadiy Sychev 03/29/2015 Added test method for new logic of 1.24
1.12 - Arkadiy Sychev 03/30/2015 Added test method for Tech Line RecordType logic and task creation

***********************************************************************/

@isTest
private Class Case_After_Test {
    
    
   static testMethod void testVCSLeaf() {
         
        String VCSrt = '012F0000000yFNiIAM';
        String LEAFrt = '012A0000000xeksIAA';
        List<Case> testCases = new List<Case>();
        
        Case caseRec = new Case();
        caseRec.Status = 'New';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        caseRec.RecordTypeId = VCSrt;
        caseRec.Stage_Status__c = System.Label.Stage_Status_Done;
        
        Case caseRec2 = new Case();
        caseRec2.Status = 'New';
        caseRec2.Origin = 'Phone';
        caseRec2.Description = 'Initial Description';
        caseRec2.RecordTypeId = LEAFrt;
        caseRec2.Stage_Status__c = System.Label.Stage_Status_Done;
        
        testCases.add(caseRec);
        testCases.add(caseRec2);
        insert(testCases);
        
        Test.startTest();
        

        
        caseRec.Description = 'Changed Description';
        caseRec2.Description = 'Changed Description';

        update(testCases);
        
        Test.stopTest();
     }
     
     static testMethod void testDTS_CATech() {
        String Techlinert = '012F0000000yFmQ';
        String CArt = '012F0000000y9y7';
        List<Case> testCases = new List<Case>();
        
        Case caseRec3 = new Case();
        caseRec3.Status = 'New';
        caseRec3.Origin = 'Phone';
        caseRec3.Description = 'Initial Description';
        caseRec3.RecordTypeId = Techlinert;
        caseRec3.DTS_Inspection_Date_Confirmed__c = false;
        caseRec3.Field_Inspection_Indicator__c = true;
        caseRec3.DTS_Inspection_Task_Assigned__c = system.now();
        caseRec3.DTS_Notification__c = true;
        caseRec3.Stage_Status__c = System.Label.Stage_Status_Done;
        caseRec3.Issue_Type__c = 'FULL';
		caseRec3.Task_Field_Inspection_Owner__c = UserInfo.getUserId();
		        
       Case caseRec4 = new Case();
        caseRec4.Status = 'New';
        caseRec4.Origin = 'Phone';
        caseRec4.Description = 'Initial Description';
        caseRec4.RecordTypeId = CArt;
        caseRec4.DTS_Inspection_Date_Confirmed__c = false;
        caseRec4.Field_Inspection_Indicator__c = true;
        caseRec4.DTS_Inspection_Task_Assigned__c = system.now();
        caseRec4.DTS_Notification__c = true;
        caseRec4.Stage_Status__c = System.Label.Stage_Status_Done;
		caseRec4.Task_Field_Inspection_Owner__c = UserInfo.getUserId();
        testCases.add(caseRec3);
        testCases.add(caseRec4);

         Test.startTest();
         
        insert(testCases);

         caseRec3.DTS_Field_Inspection__c = system.now();
         caseRec4.DTS_Field_Inspection__c = system.now();
         
       caseRec3.DTS_Inspection_Date_Confirmed__c = true; // needs to go from false to true.
       caseRec4.DTS_Inspection_Date_Confirmed__c = true; // needs to go from false to true.
       update(testCases);
       
        Test.stopTest();
     }

	 static testMethod void testDTSandCaseFollowup() {
        String Techlinert = '012F0000000yFmQ';
        String CArt = '012F0000000y9y7';
        RecordType vehicleNissanRT = [select id, name from recordtype where name = 'Nissan' and sobjecttype = 'Vehicle__c' limit 1];
        RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
        RecordType maritz = [select id, name from recordtype where name = 'Maritz' and sobjecttype = 'Account' limit 1];
        Vehicle__c v = new Vehicle__c(RecordTypeId = vehicleNissanRT.Id, 
                                            Name = 'VIN1NJ2T345678901', 
                                            Latest_Recorded_Mileage_Units__c = 'M', 
                                            Latest_Recorded_Mileage_Number__c = 10000,
                                            Make_Name__c = 'Infiniti');
        insert v;
        
        Account c = new Account();
        c.RecordTypeId = maritz.Id;
        c.FirstName='Will';
        c.LastName='Taylor';        
        insert c;        
        
        Vehicle_Ownership_History__c voh = new Vehicle_Ownership_History__c();
        voh.Vehicle__c = v.id;
        voh.Owner__c = c.Id;
        insert voh;
        
        List<Case> testCases = new List<Case>();
        
        Case caseRec3 = new Case();
        caseRec3.Status = 'New';
        caseRec3.Origin = 'Phone';
        caseRec3.Description = 'Initial Description';
        caseRec3.RecordTypeId = Techlinert;
        caseRec3.DTS_Inspection_Date_Confirmed__c = false;
        caseRec3.Field_Inspection_Indicator__c = true;
        caseRec3.DTS_Inspection_Task_Assigned__c = system.now();
        caseRec3.DTS_Notification__c = true;
        caseRec3.Stage_Status__c = System.Label.Stage_Status_Done;
        caseRec3.Issue_Type__c = 'FULL';
        caseRec3.Vehicle_Name__c = v.Id;
        caseRec3.Supervisor_Review__c = true;
        caseRec3.Follow_Up_Date__c = DateTime.now().date();
        //caseRec3.Assignment_Level__c = 'Blahblah|1';
        caseRec3.Critical_Status_Flag__c = true;
        caseRec3.DTS_Notification__c = true;
		caseRec3.Task_Field_Inspection_Owner__c = UserInfo.getUserId();
        
       Case caseRec4 = new Case();
        caseRec4.Status = 'New';
        caseRec4.Origin = 'Phone';
        String commentBody = 'A';
        for(integer i=0;i<5000;i++)
        {
            commentBody += ' ';
        }
        commentBody += 'B';
        caseRec4.Description = commentBody;
        caseRec4.RecordTypeId = CArt;
        caseRec4.DTS_Inspection_Date_Confirmed__c = false;
        caseRec4.Field_Inspection_Indicator__c = true;
        caseRec4.DTS_Inspection_Task_Assigned__c = system.now();
        caseRec4.DTS_Notification__c = true;
        caseRec4.Stage_Status__c = System.Label.Stage_Status_Done;
		caseRec4.Task_Field_Inspection_Owner__c = UserInfo.getUserId();
        testCases.add(caseRec3);
        testCases.add(caseRec4);

        
         
        insert(testCases);
        
        CaseComment cc = new CaseComment();
        cc.CommentBody='1234567654';
        cc.ParentId = testCases[0].Id;
        insert cc;

         Test.startTest();
         caseRec3.DTS_Field_Inspection__c = system.now();
         
       caseRec3.DTS_Inspection_Date_Confirmed__c = true; // needs to go from false to true.
       update(testCases);
       
        Test.stopTest();
     }

    static testMethod void testTriggerTwo() {
        RecordType caseDIPCRT = [select id, name from recordtype where name = 'DPIC' and sobjecttype = 'Case' limit 1];
         
        /* 
           create a case to test the functionality
        */
        
        Case caseRec = new Case();
        caseRec.Status = 'New';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        caseRec.RecordTypeId = caseDIPCRT.ID;
        caseRec.Stage_Status__c = System.Label.Stage_Status_Done;
        
        /*
           Switch to the runtime context
        */

        
        insert caseRec;

		Test.startTest();
        caseRec.Description = 'Changed Description';
       
        update caseRec;
      
        
        /*
           Switch back to the original context
        */
       
        Test.stopTest();
        
        /*
           Query the database for the newly inserted records. 
        */
        
        List<CaseComment> cCommentList= [select CommentBody from CaseComment where ParentId = :caseRec.id];
        system.assert(cCommentList.size() == 2);
    }
    
    static testMethod void testTriggerTechline() {
        RecordType caseTechLineRT = [select id, name from recordtype where name = 'TECH Line Cases' and sobjecttype = 'Case' limit 1];
         
        /* 
           create a case to test the functionality
        */
        
        Case caseRec = new Case();
        caseRec.Status = 'New';
        caseRec.Origin = 'Phone';
        caseRec.Description = 'Initial Description';
        caseRec.RecordTypeId = caseTechLineRT.ID;
        caseRec.Stage_Status__c = System.Label.Stage_Status_Done;
        
        /*
           Switch to the runtime context
        */
        
        insert caseRec;
        
        Test.startTest();
      
        caseRec.Description = 'Changed Description';
       
        update caseRec;
      
        
        /*
           Switch back to the original context
        */
       
        Test.stopTest();
        
        /*
           Query the database for the newly inserted records. 
        */
        

    }
    
    static testMethod void testTriggerVehicleMileage() {
        System.Debug('***** testTriggerVehicleMileage *****'); 
        
        RecordType vehicleNissanRT = [select id, name from recordtype where name = 'Nissan' and sobjecttype = 'Vehicle__c' limit 1];
        RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
        
        //create 100 Test Vehicles
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        for (Integer i = 0; i < 10; i++) {
            Vehicle__c v = new Vehicle__c(RecordTypeId = vehicleNissanRT.Id, 
                                            Name = 'VIN1NJ2T34567890' + i, 
                                            Latest_Recorded_Mileage_Units__c = 'M', 
											Make_Name__c = 'NISSAN', 
                                            Latest_Recorded_Mileage_Number__c = 10000);
            testVehicles.add(v);
        }
        insert testVehicles;
        
        List<Case> testCases = new List<Case>();
        //test no mileage in case
        for (Integer i = 0; i < 5; i++) {
            Case v = new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', 
                                Vehicle_Name__c = testVehicles[i].ID);
            testCases.add(v);
        }
        
        //test mileage > 0 in case
        for (Integer i = 5; i < 10; i++) {
            Case v = new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone',
                                Current_Mileage__c = 5000, 
                                Vehicle_Name__c = testVehicles[i].ID);
            testCases.add(v);
        }
        
        //test no mileage in case
        for (Integer i = 5; i < 10; i++) {
            Case v = new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', 
                                Current_Mileage__c = 15000, 
                                Vehicle_Name__c = testVehicles[i].ID);
            testCases.add(v);
        }

        /*1.5 //create 2 cases for each of the first 50 Vehicles. once case 5000 miles, the other 9999, less than the mileage in the vehicle.
        //create 2 cases for each of the last 50 Vehicles. once case 5000 miles, the other 15000, greater than the mileage in the vehicle.
        for (Integer i = 0; i < 50; i++) {
            Case v = new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone',
                                Current_Mileage__c = 5000, 
                                Vehicle_Name__c = testVehicles[i].ID);
            testCases.add(v);
        }
        
        for (Integer i = 0; i < 50; i++) {
            Case v = new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone',
                                Current_Mileage__c = 9999, 
                                Vehicle_Name__c = testVehicles[i].ID);
            testCases.add(v);
        }
        for (Integer i = 50; i < 100; i++) {
            Case v = new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone',
                                Current_Mileage__c = 15000, 
                                Vehicle_Name__c = testVehicles[i].ID);
            testCases.add(v);
        }
        for (Integer i = 50; i < 100; i++) {
            Case v = new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone',
                                Current_Mileage__c = 5000, 
                                Vehicle_Name__c = testVehicles[i].ID);
            testCases.add(v);
        }*/
        
        test.startTest();
        insert testCases;
        test.stopTest();
        
        //expeting the first 50 vehicles still remain 10000 miles
        Vehicle__c v = [Select v.Latest_Recorded_Mileage_Units__c, v.Latest_Recorded_Mileage_Number__c From Vehicle__c v WHERE ID =: testVehicles[2].ID];
        System.assert(v.Latest_Recorded_Mileage_Number__c == 10000 && v.Latest_Recorded_Mileage_Units__c == 'M');
        //expeting the last 50 vehicles's mileage is updated to 15000
        Vehicle__c vv = [Select v.Latest_Recorded_Mileage_Units__c, v.Latest_Recorded_Mileage_Number__c From Vehicle__c v WHERE ID =: testVehicles[7].ID];
        System.assert(vv.Latest_Recorded_Mileage_Number__c == 15000 && vv.Latest_Recorded_Mileage_Units__c == 'M');
    }

    static testMethod void testTriggerCompleteDCBTasks() {
        System.Debug('***** testTriggerCompleteDCBTasks *****'); 
        
        RecordType caseDIPCRT = [select id, name from recordtype where name = 'DPIC' and sobjecttype = 'Case' limit 1];
        
        Account usDealer = new Account(Name = 'Non-CA Dealer');
        insert usDealer;
        Account caDealer = new Account(Name = 'CA Dealer', BillingCountry = 'CA');
        insert caDealer;
        
        List<Case> testCases = new List<Case>();
        Case usCase = new Case(RecordTypeId = caseDIPCRT.Id, Status = 'New', AccountID = usDealer.ID, Who_called__c = 'P - Parts Department', What_Department__c = 'P - Parts Department');
        testCases.add(USCase);
        
        Case caCase = new Case(RecordTypeId = caseDIPCRT.Id, Status = 'New', AccountID = caDealer.ID, Who_called__c = 'P - Parts Department', What_Department__c = 'P - Parts Department');
        testCases.add(caCase);

        Case justCase = new Case(Status = 'New', Who_called__c = 'P - Parts Department', What_Department__c = 'P - Parts Department');
        testCases.add(justCase);
        insert testCases;
        
        List<Task> testTasks = new List<Task>();
        for (Integer i = 0; i < 3; i++) {
            Task v = new Task(WhatId = testCases[i].Id, Status = 'Not Started', Subject = System.Label.Task_Subject_24hr_Dealer_Call_Back);
            testTasks.add(v);
        }
        for (Integer i = 0; i < 3; i++) {
            Task v = new Task(WhatId = testCases[i].Id, Status = 'Not Started', Subject = System.Label.Task_Subject_48hr_Dealer_Call_Back);
            testTasks.add(v);
        }
        insert testTasks;
        
        for (Case v : testCases) {
            v.Status = 'Closed';
        }
        
        test.startTest();
        update testCases;
        System.Debug('**** testCases ' + testCases); 
        test.stopTest();
        
        for (Task t: [Select WhatID, Subject, Status From Task Where ID IN: testTasks]) {
            System.Debug('**** t ' + t);
            if (t.WhatID == usCase.ID) {
                if (t.Subject == System.Label.Task_Subject_24hr_Dealer_Call_Back)
                    system.assert(t.Status == 'Not Started');
                else if (t.Subject == System.Label.Task_Subject_48hr_Dealer_Call_Back)
                    system.assert(t.Status == 'Complete');
            } else if (t.WhatID == caCase.ID) {
                if (t.Subject == System.Label.Task_Subject_48hr_Dealer_Call_Back)
                    system.assert(t.Status == 'Not Started');
                else if (t.Subject == System.Label.Task_Subject_24hr_Dealer_Call_Back)
                    system.assert(t.Status == 'Complete');
            } else
                system.assert(t.Status == 'Not Started');
        }
        
    }
    
    //conditions that cause no account is created
    static testmethod void testTriggerNotCreateAccountFromEmail() {
        System.Debug('***** testTriggerNotCreateAccountFromEmail *****');
        
        List<Case> testCases = new List<Case>();
        testCases.add(new Case(Origin = 'Email To Case', RecordTypeID = CaseClass.CA_EMAIL_NISSAN_RT, Description = '0'));
        testCases.add(new Case(Origin = 'Email To Case', RecordTypeID = CaseClass.CA_EMAIL_INFINITI_RT, Description = '1'));        
        testCases.add(new Case(Origin = 'Email To Case', RecordTypeID = CaseClass.DPIC_RT, Description = '2'));  
        insert testCases; 
        
        List<EmailMessage> newEmail = new List<EmailMessage>();
        //EmailMessages with any Subject
        //the case id of one EmailMessage is the Nissan case
        //CA_E2C_TYPE.NON_NISSAN_INFINITI
        newEmail.add(new EmailMessage(FromAddress = 'testnissan@BuCunZaideJiaEmailDiZhi.com', 
            Incoming = True, 
            Subject = 'Test Nissan email', 
            ParentId = testCases[0].Id,
            FromName = 'Name Name'));
        
        //EmailMessages with any Subject
        //the case id of another EmailMessage is the Infiniti case
        //CA_E2C_TYPE.NON_NISSAN_INFINITI
        newEmail.add(new EmailMessage(FromAddress = 'testinfiniti@BuCunZaideJiaEmailDiZhi.com', 
            Incoming = True, 
            Subject = 'Test Infiniti email', 
            ParentId = testCases[1].Id,
            FromName = 'Name, Name'));
        
        //the case id of 3rd EmailMessage is dpic case - CA_E2C_TYPE.UNKNOWN
        newEmail.add(new EmailMessage(FromAddress = 'somebody@BuCunZaideJiaEmailDiZhi.com', 
            Incoming = True, 
            Subject = 'Test Nissan email', 
            ParentId = testCases[2].Id,
            FromName = 'Name Name'));
        
        //has no subject - CA_E2C_TYPE.UNKNOWN
        newEmail.add(new EmailMessage(FromAddress = 'somebody@BuCunZaideJiaEmailDiZhi.com', 
            Incoming = True, 
            ParentId = testCases[2].Id,
            FromName = 'Name Name'));
        
        //Nissan EmailMessage, but TextBody do not match with the pattern
        newEmail.add(new EmailMessage(Incoming = True, 
            Subject = 'A Nissan Dealer',        
            ParentId = testCases[0].Id,
            TextBody = 'greeting : \r\n' +
                'firstname : somebodyfirstname\r\n' +
                'lastname : somebodylastname\r\n' +
                'email : somebody@BuCunZaideJiaEmailDiZhi.com\r\n' + 
                'comments : not recognized'));
        
        //Infiniti EmailMessage, but lastName and firstName is empty
        newEmail.add(new EmailMessage(Incoming = True, 
            Subject = 'Infiniti Retailers',         
            ParentId = testCases[1].Id,
            TextBody = 'greeting : \r\n' +
                'firstname : \r\n' +
                'lastname : \r\n' +
                'email : somebody@BuCunZaideJiaEmailDiZhi.com\r\n' + 
                'homephone : \r\n' +
                'comments : not recognized'));

        //Infiniti EmailMessage, but email is empty
        newEmail.add(new EmailMessage(Incoming = True, 
            Subject = 'Infiniti Corporate',         
            ParentId = testCases[1].Id,
            TextBody = 'greeting : \r\n' +
                'firstname : \r\n' +
                'lastname : \r\n' +
                'email : \r\n' + 
                'homephone : \r\n' +
                'comments : not recognized'));

        Test.startTest();
        insert newEmail;
        Test.stopTest();
        
        system.assert([Select ID, PersonEmail, PersonContactID, LastName, FirstName From Account Where PersonEmail like '%bucunzaidejiaemaildizhi.com'].size() == 0);
    }
	
    static testMethod void Case_SyncVehicleVINTest() {
        System.Debug('***** Case_SyncVehicleVINTest *****');
        
        RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
        
        List<Vehicle__c> testVehicles = new List<Vehicle__c> {
            new Vehicle__c(Name = '**VehicleName**',  Make_Name__c = 'NISSAN'),
            new Vehicle__c(Name = '**VehicleVIN**', Vehicle_Identification_Number__c = '**VehicleVIN**',  Make_Name__c = 'NISSAN'),
            new Vehicle__c(Name = '**VehicleDiffName', Vehicle_Identification_Number__c = '**VehicleDiffName',  Make_Name__c = 'NISSAN'),
            new Vehicle__c(Name = '**VehicleDiffVIN', Vehicle_Identification_Number__c = '**VehicleDiffVIN',  Make_Name__c = 'NISSAN')
        };
        insert testVehicles;
        
        List<Case> testCases = new List<Case> {
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Vehicle_Name__c = testVehicles[0].Id),
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', VIN__c = testVehicles[1].Vehicle_Identification_Number__c),
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', VIN__c = '**NEWIN1**')
        };
        
        test.startTest();
        //sync when insert
        insert testCases;
        for (Case b : [Select Vehicle_Name__c, Vehicle_Name__r.Name, VIN__c From Case Where ID in: testCases]){
            System.debug('b.VIN__c::'+b.VIN__c+'--b.Vehicle_Name__r.Name--'+b.Vehicle_Name__r.Name);
            System.assert(b.VIN__c == b.Vehicle_Name__r.Name);
        }
        
        //sync when update
        testCases[0].Vehicle_Name__c = testVehicles[2].Id;  //change vehicle to VehicleDiffName
        testCases[1].VIN__c = '**VehicleDiffVIN';           //change vehicle to VehicleDiffVIN
        testCases[2].VIN__c = '**VehicleDiffNEW';           //change vehicle to VehicleDiffNEW
        update testCases;
        for (Case b : [Select Vehicle_Name__c, Vehicle_Name__r.Name, VIN__c From Case Where ID in: testCases]) {
            System.assert(b.VIN__c.contains('**VehicleDiff'));
            System.assert(b.VIN__c == b.Vehicle_Name__r.Name);
        }
        
        //behavior when update null values
        testCases[0].Vehicle_Name__c = null; 
        testCases[1].VIN__c = null;
        testCases[2].Accident_Indicator__c = false;
        update testCases;
        List<Case> bbs = [Select Vehicle_Name__c, Vehicle_Name__r.Name, VIN__c From Case Where ID in: testCases];
        System.assert(bbs[0].VIN__c == null && bbs[0].Vehicle_Name__r.Name == null && bbs[1].VIN__c == null && bbs[1].Vehicle_Name__r.Name == null);
        System.assert(bbs[2].VIN__c == '**VehicleDiffNEW');
        
        test.stopTest();
    }
    
    static testMethod void Case_ModifyBuybackTest() {
        System.Debug('***** Case_ModifyBuybackTest *****');
        
        RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
        
        List<Vehicle__c> testVehicles = new List<Vehicle__c> {
            new Vehicle__c(Name = '**VehicleName**', Make_Name__c = 'NISSAN'),
            new Vehicle__c(Name = '**VehicleNameII**', Make_Name__c = 'NISSAN')
        };
        insert testVehicles;
        
        List<Case> testCases = new List<Case> {
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Vehicle_Name__c = testVehicles[0].Id),
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone', Vehicle_Name__c = testVehicles[1].Id),
            new Case(RecordTypeId = caseCART.Id, Status = 'New', Origin = 'Phone')
        };
        insert testCases;
        
        test.startTest();       
        List<Buyback__c> testBuybacks = new List<Buyback__c> {
            new Buyback__c(Case__c = testCases[0].ID, Vehicle__c = testVehicles[0].Id), //Buyback_After trigger fills up buyback__c in case0
            new Buyback__c(Case__c = testCases[1].ID, Vehicle__c = testVehicles[1].Id), //Buyback_After trigger fills up buyback__c in case1
            new Buyback__c(Case__c = testCases[2].ID, Vehicle__c = testVehicles[1].Id)  //Buyback_After trigger will not fill up buyback__c in case, because case2 has no vehicle
        };
        insert testBuybacks;
        
        try {
            testCases[0].Buyback__c = testBuybacks[1].Id;       //modify case0 buyback field - not allowed if buyback__c != null
            update testCases[0];
        } catch (Exception e) {
            System.Debug(e.getMessage());
        }
        try {
            testCases[1].Vehicle_Name__c = testVehicles[0].Id;  //modify case1 vehicle field - not allowed if buyback__c != null
            update testCases[1];
        } catch (Exception e) {
            System.Debug(e.getMessage());
        }
        try {
            testCases[2].Vehicle_Name__c = testVehicles[1].Id;  //fill case2 vehicle filed - fill buyback__c field when vehicle is not empty
            update testCases[2];
        } catch (Exception e) {
            System.Debug(e.getMessage());
        }
        
        List<Case> cases = [Select Vehicle_Name__c, Buyback__c From Case Where ID in: testCases];
        System.assert(cases[0].Buyback__c == testBuybacks[0].Id);
        System.assert(cases[1].Vehicle_Name__c == testVehicles[1].Id);
        System.assert(cases[2].Buyback__c == testBuybacks[2].Id);
        
        test.stopTest();
    }

    static testMethod void testTreadLogic() {
        
        /*
           create a case to test the functionality
        */
        Test.startTest();
		RecordType caseCART = [select id, name from recordtype where name = 'CA' and sobjecttype = 'Case' limit 1];
        Case testCase = new Case(Status = 'New', Origin = 'Phone', Description = 'Initial Description', recordTypeId = caseCART.id, Who_called__c = 'P - Parts Department', What_Department__c = 'P - Parts Department');
        
        List<Code__c> testCodes;
        CaseCategory_Dependency__c testCCD;
        Case_Categorization__c testCC;
        testCodes = new List<Code__c>();
        testCodes.add(new Code__c(Type__c = 'Concern', Code__c = 'CN', Description__c = 'Concern', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Category', Code__c = 'CT', Description__c = 'Category', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Subcategory', Code__c = '9IIII9', Description__c = 'Subcategory', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Symptom', Code__c = 'SM', Description__c = 'Symptom', Active__c = TRUE));
        testCodes.add(new Code__c(Type__c = 'Major Component Code', Code__c = 'MJ', Description__c = 'Symptom', Active__c = TRUE));
		testCodes.add(new Code__c(Type__c = 'Root_Cause_Code', Code__c = 'test', Description__c = 'Symptom', Active__c = TRUE));
        insert testCodes;
        //testCase.Special_Root_Cause_Closing_Code__c = testCodes[5].Id;
		insert testCase;
		
        testCCD = new CaseCategory_Dependency__c();
        testCCD.Concern__c = testCodes[0].ID;
        testCCD.Category__c = testCodes[1].ID;
        testCCD.Subcategory__c = testCodes[2].ID;
        testCCD.Symptom__c = testCodes[3].ID;
		testCCD.Major_Component_Code__c = 'MJ';
        insert testCCD;

        testCC = new Case_Categorization__c();
        testCC.Case__c = testCase.ID;
        
        testCC.Concern__c = testCodes[0].ID;
        testCC.Concern_Code__c = 'CN';
        
        testCC.Category__c = testCodes[1].ID;
        testCC.Category_Code__c = 'CT';
        
        testCC.Subcategory__c = testCodes[2].ID;
        testCC.Subcategory_Code__c = '9IIII9';
        
        testCC.Symptom__c = testCodes[3].ID;
        testCC.Symptom_Code__c = 'SM';
        
        insert testCC;
        
        testCC = [SELECT Id, Major_Component_Code__c FROM Case_Categorization__c WHERE Case__c=:testCase.Id LIMIT 1];
        System.assertEquals(testCC.Major_Component_Code__c, testCCD.Major_Component_Code__c);
        test.stopTest();
    }   

	// 1.11 Test method for new logic of 1.24
	/*static testMethod void testCaseNotificationLogic(){
		String recTypeName = 'CA';

		// !!! BEFORE DEPLOYING MAKE SURE THAT THESE USERS EXIST ON NEW ORG !!! //
		String ownerName = (UserInfo.getName() == 'Aaron Bessey') ? 'arkadiy sychev' : 'Aaron Bessey';

		// Case creation
		// Retrieve 'CA' case recordType
		List<RecordType> caseRecType = [SELECT Id FROM RecordType WHERE Name =: recTypeName];
		Case testCase = new Case();
		testCase.RecordTypeId = caseRecType[0].Id;
		testCase.Status = 'Open';
		insert testCase;

		// Retrieve Id of new owner
		List<User> newOwner = [SELECT Id FROM User WHERE Name =: ownerName];

		// Change owner
		testCase.OwnerId = newOwner[0].Id;
		update testCase;

		// Updating testCase
		testCase.Status = 'Pending';
		update testCase;

		List<Notification__c> notifications = [SELECT Id FROM Notification__c];

		System.assertEquals(2, notifications.size());

	}*/

	

}