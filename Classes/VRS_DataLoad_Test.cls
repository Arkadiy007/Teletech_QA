@isTest
private class VRS_DataLoad_Test {
    static String sQuery = 'Select Survey_Verbatim__c, ' +
                            'Survey_System_ID__c, ' +
                            'Survey_Return_Type__c, ' +
                            'Survey_Last_Name__c, ' +
                            'Survey_ID__c, ' +
                            'Survey_First_Name__c, ' +
                            'Survey_Date__c, ' +
                            'Spare3__c, ' +
                            'Spare2__c, ' +
                            'Spare1__c, ' +
                            'Sentiment_Band_Row__c, ' +
                            'Satisfied_with_Sales_Experience__c, ' +
                            'Satisfaction__c, ' +
                            'Name, ' +
                            'Internal_Ferret_Id__c, ' +
                            'Id, ' +
                            'Follow_Up_Status__c, ' +
                            'Follow_Up_Reason__c, ' +
                            'Follow_Up_Call__c, ' +
                            'FF_Score__c, ' +
                            'External_Vehicle_Identification_Number__c, ' +
                            'Excellent_Overall_Experience__c, ' +
                            'Dealer_Follow_Up_Status__c, ' +
                            'Customer_Phone__c, ' +
                            'Customer_Email__c, ' +
                            'Customer_Disposition__c, ' +
                            'Action_Plan__c ' +
                        'From Vehicle_Retail_Sale_Stage__c ' + 
                        'WHERE External_Vehicle_Identification_Number__c like ';
    
    static RecordType personType = [select id, name from recordtype where name = 'TMS' and sobjecttype = 'Account' limit 1];

    static void createTestData(List<Vehicle_Retail_Sale__c> vehicleRetailSales, List<Account> accounts, List<Vehicle__c> vehicles) {
    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;

        for (Integer i = 0; i < 100; i++) {
            Vehicle_Retail_Sale__c vehicleRetailSale = new Vehicle_Retail_Sale__c(External_Owner_Id__c = 'unique' + i, 
                External_Vehicle_Identification_Number__c = 'unique vin' + i, 
                Follow_Up_Status__c = 'Open');
            
            vehicleRetailSales.add(vehicleRetailSale);
        }

        for (Integer i = 0; i < 100; i++) {
            Account account = new Account(Customer_ID__c = 'unique' + i, 
                lastName = 'Account' + i, FirstName = 'firstname' + i,
                PersonMailingPostalCode = '21204', PersonMailingState = 'CO', PersonMailingStreet = 'New',
                RecordTypeId = personType.id,
                Preferred_Dealer_Code__c = 'Test');
            
            accounts.add(account);
        }

        for (Integer i = 0; i < 100; i++) {
            Vehicle__c vehicle = new Vehicle__c(Latest_Recorded_Mileage_Number__c = 30450, 
                Latest_Recorded_Mileage_Units__c = 'M', 
                Vehicle_Identification_Number__c  = 'unique vin' + i);

            vehicles.add(vehicle);
        }
    }

    //Test case: Successful merge 
    static testmethod void testBatch_VRS_DataLoadDedup() {
        List<Account> accounts = new List<Account>();
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        List<Vehicle_Retail_Sale__c> vehicleRetailSales = new List<Vehicle_Retail_Sale__c>();
        createTestData(vehicleRetailSales, accounts, vehicles);
        insert accounts;
        insert vehicles;
        //insert VRS to have reatled owner_id and vin filled
        insert vehicleRetailSales;

        List<Vehicle_Retail_Sale_Stage__c> vehicleRetailSaleStages = new List<Vehicle_Retail_Sale_Stage__c>();
        //These will be successful:
        for (Integer i = 0; i < 50; i++) {
            Vehicle_Retail_Sale_Stage__c vehicleRetailSaleStage = new Vehicle_Retail_Sale_Stage__c();
            vehicleRetailSaleStage.Survey_Last_Name__c = 'ACCOUNT' + i;
            vehicleRetailSaleStage.Survey_First_Name__c = 'firstname' + i;
            vehicleRetailSaleStage.External_Vehicle_Identification_Number__c = 'unique vin' + i;
            vehicleRetailSaleStage.Survey_Verbatim__c = 'Great';
            vehicleRetailSaleStage.Survey_System_ID__c = '456789';
            vehicleRetailSaleStage.Survey_Return_Type__c = 'Phone';
            vehicleRetailSaleStage.Survey_Date__c = System.Today();
            vehicleRetailSaleStage.Survey_ID__c = '456789';
            vehicleRetailSaleStage.Spare3__c = 'Yes';
            vehicleRetailSaleStage.Spare2__c = 'No';
            vehicleRetailSaleStage.Spare1__c = 'Not sure';
            vehicleRetailSaleStage.Sentiment_Band_Row__c = 'Neutral';
            vehicleRetailSaleStage.Satisfied_with_Sales_Experience__c = 'Don\'t Know';
            vehicleRetailSaleStage.Satisfaction__c = 'Yes';
            vehicleRetailSaleStage.Internal_Ferret_Id__c = '4567879';
            vehicleRetailSaleStage.Follow_Up_Status__c = 'Dealer Contacted';
            vehicleRetailSaleStage.Follow_Up_Reason__c = 'Hot Alert';
            vehicleRetailSaleStage.Follow_Up_Call__c = 'Legal';
            vehicleRetailSaleStage.FF_Score__c = 'M';
            vehicleRetailSaleStage.Excellent_Overall_Experience__c = 'Yes_But';
            vehicleRetailSaleStage.Dealer_Follow_Up_Status__c = 'Action Taken';
            vehicleRetailSaleStage.Customer_Phone__c = '333-666-9999';
            vehicleRetailSaleStage.Customer_Email__c = 'myemail@myemail.com';
            vehicleRetailSaleStage.Customer_Disposition__c = 'Customer Now Satisfied';
            vehicleRetailSaleStage.Action_Plan__c = 'All filled';

            vehicleRetailSaleStages.add(vehicleRetailSaleStage);
        }
        
        //These duplicates will not be processed
        for (Integer i = 0; i < 25; i++) {
            Vehicle_Retail_Sale_Stage__c vehicleRetailSaleStage = new Vehicle_Retail_Sale_Stage__c();
            vehicleRetailSaleStage.Survey_Last_Name__c = 'ACCOUNT' + i;
            vehicleRetailSaleStage.Survey_First_Name__c = 'firstname' + i;
            vehicleRetailSaleStage.External_Vehicle_Identification_Number__c = 'unique vin' + i;
            
            vehicleRetailSaleStages.add(vehicleRetailSaleStage);
        }

        insert vehicleRetailSaleStages;
        system.debug('created test data ' + vehicleRetailSaleStages);

        Test.startTest();

        Batch_VRS_DataLoadDedup vrsDedup = new Batch_VRS_DataLoadDedup();
        vrsDedup.query = sQuery + '\'unique vin%\'';
        Database.executeBatch(vrsDedup);

        Test.stopTest();

        //check data of success merge stage record
        for (Vehicle_Retail_Sale__c v : [Select ID, Sentiment_Band_Row__c, Owner_ID__r.LastName From Vehicle_Retail_Sale__c where ID IN: vehicleRetailSales]) {
            if (v.Owner_ID__r.LastName == 'ACCOUNT0') {
                //System.assert(v.Sentiment_Band_Row__c == 'Neutral');
                break;
            }
        }

        //success merged stage record will be purged, the remaining one left is the duplicate
        System.assert([Select ID From Vehicle_Retail_Sale_Stage__c Where Survey_Last_Name__c = 'ACCOUNT25' and External_Vehicle_Identification_Number__c like 'unique vin%'].size() == 0);
    }

    //Test case: DML failure when merging
    static testmethod void testBatch_VRS_DataLoadDedupII() {
    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;

        Account account = new Account(Customer_ID__c = 'foundowner', 
            lastName = 'Account', FirstName = 'firstname',
            PersonMailingPostalCode = '21204', PersonMailingState = 'CO', PersonMailingStreet = 'New',
            RecordTypeId = personType.id,
            Preferred_Dealer_Code__c = 'Test');

        Vehicle__c vehicle = new Vehicle__c(Latest_Recorded_Mileage_Number__c = 30450, 
            Latest_Recorded_Mileage_Units__c = 'M', 
            Vehicle_Identification_Number__c  = 'foundvin');

        Vehicle_Retail_Sale__c vrs = new Vehicle_Retail_Sale__c(External_Owner_Id__c = 'foundowner', 
            External_Vehicle_Identification_Number__c = 'foundvin', 
            Follow_Up_Status__c = 'Open');

        //failed the validation rule
        Vehicle_Retail_Sale_Stage__c vrsCloseNoDisp = new Vehicle_Retail_Sale_Stage__c();
        vrsCloseNoDisp.Survey_Last_Name__c = 'ACCOUNT';
        vrsCloseNoDisp.Survey_First_Name__c = 'firstname';
        vrsCloseNoDisp.External_Vehicle_Identification_Number__c = 'foundvin';
        vrsCloseNoDisp.Follow_Up_Status__c = 'Closed';
        
        insert account;
        insert vehicle;
        insert vrs;
        insert vrsCloseNoDisp;

        Test.startTest();

        Batch_VRS_DataLoadDedup vrsDedup = new Batch_VRS_DataLoadDedup();
        vrsDedup.query = sQuery + '\'foundvin\'';
        Database.executeBatch(vrsDedup);

        Test.stopTest();

        //unsuccess merged should be logged
        //Vehicle_Retail_Sale_Stage__c s = [Select ID From Vehicle_Retail_Sale_Stage__c where Survey_Last_Name__c = 'ACCOUNT' and External_Vehicle_Identification_Number__c = 'foundvin'];
        //System.assert([Select Error_Message__c, TimeStamp__c, Source__c From Error_Log__c where Record_ID__c =: s.ID].size() == 1);
    }

    //Test case: failure caused by missing data 
    static testmethod void testBatch_VRS_DataLoadDedupIII() {
    	State__c state = new State__c(Name = 'CO', Name__c = 'Colorado', Order__c = 1);
    	insert state;

        Account account = new Account(Customer_ID__c = 'foundowner', 
            lastName = 'Account', FirstName = 'firstname',
            PersonMailingPostalCode = '21204', PersonMailingState = 'CO', PersonMailingStreet = 'New',
            RecordTypeId = personType.id,
            Preferred_Dealer_Code__c = 'Test');

        Vehicle__c vehicle = new Vehicle__c(Latest_Recorded_Mileage_Number__c = 30450, 
            Latest_Recorded_Mileage_Units__c = 'M', 
            Vehicle_Identification_Number__c  = 'foundvin');
            
        Vehicle_Retail_Sale__c vrsNoOwner = new Vehicle_Retail_Sale__c(External_Owner_Id__c = 'not found owner', 
            External_Vehicle_Identification_Number__c = 'foundvin', 
            Follow_Up_Status__c = 'Open');

        insert account;
        insert vehicle;
        insert vrsNoOwner;
        
        //vehicle is not found
        Vehicle_Retail_Sale_Stage__c vrsSNoVin = new Vehicle_Retail_Sale_Stage__c();
        vrsSNoVin.Survey_Last_Name__c = 'foundowner';
        vrsSNoVin.Survey_First_Name__c = 'firstname';
        vrsSNoVin.External_Vehicle_Identification_Number__c = 'not foundvin';

        //owner is not found
        Vehicle_Retail_Sale_Stage__c vrsSNoOwner = new Vehicle_Retail_Sale_Stage__c();
        vrsSNoOwner.Survey_Last_Name__c = 'not found owner';
        vrsSNoOwner.Survey_First_Name__c = 'firstname';
        vrsSNoOwner.External_Vehicle_Identification_Number__c = 'foundvin';

        insert vrsSNoVin;
        insert vrsSNoOwner;

        Test.startTest();

        Batch_VRS_DataLoadDedup vrsDedup = new Batch_VRS_DataLoadDedup();
        vrsDedup.query = sQuery + '\'%foundvin\'';
        Database.executeBatch(vrsDedup);

        Test.stopTest();

        //unsuccess merged should be logged
        Vehicle_Retail_Sale_Stage__c s = [Select ID From Vehicle_Retail_Sale_Stage__c where External_Vehicle_Identification_Number__c like 'not foundvin'];
        //System.assert([Select Error_Message__c, TimeStamp__c, Source__c From Error_Log__c where Record_ID__c =: s.ID].size() == 1);
        
        s = [Select ID From Vehicle_Retail_Sale_Stage__c where Survey_Last_Name__c = 'not found owner' and External_Vehicle_Identification_Number__c like 'foundvin'];
        //System.assert([Select Error_Message__c, TimeStamp__c, Source__c From Error_Log__c where Record_ID__c =: s.ID].size() == 1);
    }

    static testmethod void testBatch_VRS_DataLoadCleanUp() {
        List<Account> accounts = new List<Account>();
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        List<Vehicle_Retail_Sale__c> vehicleRetailSales = new List<Vehicle_Retail_Sale__c>();
        createTestData(vehicleRetailSales, accounts, vehicles);
        //insert VRS before reatled owner_id and vin created
        insert vehicleRetailSales;
        insert accounts;
        insert vehicles;

        Test.startTest();

        Batch_VRS_DataLoadCleanUp vrsCleanUp = new Batch_VRS_DataLoadCleanUp();
        vrsCleanUp.query = 'Select ID From Vehicle_Retail_Sale__c WHERE External_Vehicle_Identification_Number__c like \'unique vin%\'';
        Database.executeBatch(vrsCleanUp);

        Test.stopTest();
        
        Vehicle_Retail_Sale__c result = [Select ID, External_Owner_Id__c, Owner_ID__c, External_Vehicle_Identification_Number__c, Vehicle_Identification_Number__c From Vehicle_Retail_Sale__c where ID =: vehicleRetailSales[0].ID];
        for (Integer i = 0; i < 100; i++) {
            if (result.External_Owner_Id__c == accounts[i].Customer_ID__c || result.External_Vehicle_Identification_Number__c == vehicles[i].Vehicle_Identification_Number__c) {
                system.assert(result.Owner_Id__c == accounts[i].ID);
                system.assert(result.Vehicle_Identification_Number__c == vehicles[i].ID);
                break;
            }
        }
    }

    static testmethod void testSchedule_VRS_DataLoadCleanUp() {
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('testSchedule_VRS_DataLoadCleanUp', '0 0 0 ? * * *', new Schedule_VRS_DataLoadCleanUp());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.debug(ct.NextFireTime);
        
        Test.stopTest();
    }

    static testmethod void testSchedule_VRS_DataLoadDedup() {
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('testSchedule_VRS_DataLoadDedup', '0 0 0 ? * * *', new Schedule_VRS_DataLoadDedup());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.debug(ct.NextFireTime);
        
        Test.stopTest();
    }
}