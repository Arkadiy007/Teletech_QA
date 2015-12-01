/**********************************************************************
  Name:OCP_File_Before
  Copyright � notice: Nissan Motor Company.
  ======================================================
  Purpose:
  This trigger creates new Case, whenever new record created for OCP_File__c object
  ======================================================
  History:
 
  VERSION AUTHOR DATE DETAIL 
  1.0 - Vlad Martynenko 01/15/2015 Created
 ***********************************************************************/
trigger OCP_File_Before on OCP_File__c(before insert) {
    List <Error_Log__c > errors = new List <Error_Log__c > ();
    List <Account > newAccounts = new List <Account > ();
    List <Case > OCPFileCases = new List <Case > ();
    List <Case > OCPFileCasesWithoutAccounts = new List <Case > ();
    List <String > customerIds = new List <String > ();
    List <String > vins = new List <String > ();
    List <String > dealerCodes = new List <String > ();

    for (OCP_File__c fileRecord : Trigger.New) {
		if(fileRecord.Contactid__c != null && fileRecord.Contactid__c != ''){
			customerIds.add(fileRecord.Contactid__c);
		}

		if(fileRecord.VINCurrent__c != null && fileRecord.VINCurrent__c != ''){
			vins.add(fileRecord.VINCurrent__c);
		}

        if (fileRecord.dealer__c != null && fileRecord.dealer__c != '') {
            dealerCodes.add(fileRecord.dealer__c);
        }
    }
    // Record types
    List <RecordType > accountRecordType = [Select Id, Name from RecordType WHERE Name = :'Maritz' AND sObjectType = :'Account'];
    List <RecordType > caseRecordType = [Select Id, Name from RecordType WHERE Name = :'Lease Loyalty' AND sObjectType = :'Case'];
    List <RecordType > dealerRecordType = [Select Id, Name from RecordType WHERE Name = :'Dealer' AND sObjectType = :'Account'];

    Id dealerRtId = dealerRecordType.get(0).Id;
    Id accountRtId = accountRecordType.get(0).Id;

    List <Account > customers = [Select Id, PersonContactId, Customer_ID__c FROM Account WHERE RecordTypeId = :accountRtId and Customer_ID__c in :customerIds];
    List <Account > dealers = [Select Id, Dealer_Code__c FROM Account WHERE Dealer_Code__c in :dealerCodes and RecordTypeId=:dealerRtId ];
    List <Vehicle__c > vehicles = [Select Id, Vehicle_identification_Number__c FROM Vehicle__c WHERE Vehicle_identification_Number__c in :vins];


    // Case owner queue
    List <Group > cccGroup = [select Id, Name from Group where Name = :'CCC Campaign Queue' and Type = 'Queue'];

    Map <String, Account > customersMap = new Map <String, Account > ();
    for (Account customer : customers) {
        customersMap.put(customer.Customer_ID__c, customer);
    }

    Map <String, Account > dealersMap = new Map <String, Account > ();
    for (Account dealer : dealers) {
        dealersMap.put(dealer.Dealer_Code__c, dealer);
    }

    Map <String, Vehicle__c > vehiclesMap = new Map <String, Vehicle__c > ();
    for (Vehicle__c vehicle : vehicles) {
        vehiclesMap.put(vehicle.Vehicle_identification_Number__c, vehicle);
    }

    //map to store corresponding OCP files and its number in list
    Map<Integer,OCP_File__c> ocpFilesMap = new Map<Integer,OCP_File__c>();
    //map to store corresponding OCP files and its number in list
    Map<Integer,Integer> ocpFilesAccountsMap = new Map<Integer,Integer>();
	//map to store corresponding OCP files and its number in list
    Map<Integer,Integer> ocpCasesMap = new Map<Integer,Integer>();
	Integer casesCounter = 0;
	//map to store corresponding OCP files and its number in list
    Map<Integer,Integer> ocpCasesWithoutAccMap = new Map<Integer,Integer>();
	Integer casesWithoutAccCounter = 0;
    Integer counter = 0;
    Integer counterAccounts = 0;
    for (OCP_File__c fileRecord : Trigger.New) {
        Case ocpCase = new Case();

        Vehicle__c vehicle = vehiclesMap.get(fileRecord.VINCurrent__c);
        if (vehicle != null) {
            ocpCase.Vehicle_Name__c = vehicle.Id;
        }

        Account dealer = dealersMap.get(fileRecord.dealer__c);
        if (dealer != null) {
            ocpCase.Dealer__c = dealer.Id;
            ocpCase.Preferred_Dealer__c = dealer.Id;
        }

        if (caseRecordType.size() > 0) {
            ocpCase.RecordTypeId = caseRecordType.get(0).Id;
        }

		OCP_File_Data_Load__c OcpFileSettings = OCP_File_Data_Load__c.getOrgDefaults();
        if(OcpFileSettings.DefectorMonthlyExtract_Description__c == null || OcpFileSettings.DefectorMonthlyExtract_Subject__c==null || OcpFileSettings.OCP_Description__c == null || OcpFileSettings.OCP_Subject__c == null){
            OcpFileSettings = getOcpFileSettings();
        }
		if(fileRecord.SegmentMailed__c != null && fileRecord.SegmentMailed__c.contains('Pilot Loyalty')){
			ocpCase.Description = OcpFileSettings.DefectorMonthlyExtract_Description__c;
			ocpCase.Subject = OcpFileSettings.DefectorMonthlyExtract_Subject__c;			
		}else{
			ocpCase.Description = OcpFileSettings.OCP_Description__c;
			ocpCase.Subject = OcpFileSettings.OCP_Subject__c;
		}
        ocpCase.Priority = 'Low';
        ocpCase.Origin = 'Data Load';

        if (cccGroup.size() > 0) {
            ocpCase.OwnerId = cccGroup.get(0).Id;
        }

        ocpCase.DQR_Number__c = fileRecord.leadid__c;
        if (fileRecord.MonthlyPayment__c != null && fileRecord.MonthlyPayment__c != '') {
            ocpCase.Lease_Monthly_Payment__c = decimal.valueof(fileRecord.MonthlyPayment__c);
        }
        ocpCase.First_Name__c = fileRecord.FirstName__c;
        ocpCase.Alternate_Email__c = fileRecord.EmailAddress2__c;
        ocpCase.Dealer_Number__c = fileRecord.dealer__c;
        ocpCase.Co_Leasee_Co_Buyer_Last_Name__c = fileRecord.CoLastName__c;
        ocpCase.Mailing_City__c = fileRecord.City__c;
        if (fileRecord.LeaseStartDate__c != null && fileRecord.LeaseStartDate__c != '') {
			ocpCase.Lease_Start_Date__c = DataImportTriggersHelper.GetDateFromOCPDate(fileRecord.LeaseStartDate__c);			
        }
        ocpCase.Work_Phone__c = (fileRecord.WorkPhone__c == 'DoNotCall') ? '' : fileRecord.WorkPhone__c;
        ocpCase.Considered_Vehicle_Make__c = fileRecord.HRModelofInterest__c;
        ocpCase.Equity__c = fileRecord.result__c;
        ocpCase.Co_Leasee_Co_Buyer_First_Name__c = fileRecord.CoFirstName__c;
        ocpCase.Vehicle_Make__c = fileRecord.Make__c;
        ocpCase.VIN__c = fileRecord.VINCurrent__c;
        ocpCase.Vehicle_Year__c = fileRecord.MdlyrCurrent__c;
        if (fileRecord.LeadDt__c != null && fileRecord.LeadDt__c != '') {
			ocpCase.Lead_Date__c = DataImportTriggersHelper.GetDateFromOCPDate(fileRecord.LeadDt__c).format();
        }
        ocpCase.Mobile_Phone__c = (fileRecord.CellPhone__c == 'DoNotCall') ? '' : fileRecord.CellPhone__c;
        if (fileRecord.MaturityDate__c != null && fileRecord.MaturityDate__c != '') {
			ocpCase.Lease_Maturity_Date__c = DataImportTriggersHelper.GetDateFromOCPDate(fileRecord.MaturityDate__c);
        }
        if (fileRecord.VehicleEverOwned__c != null && fileRecord.VehicleEverOwned__c != '') {
            ocpCase.Vehicles_Owned__c = decimal.valueof(fileRecord.VehicleEverOwned__c);
        }
        if (fileRecord.ContractMiles__c != null && fileRecord.ContractMiles__c != '') {
            ocpCase.Mileage_Allowance__c = decimal.valueof(fileRecord.ContractMiles__c);
        }
        if (fileRecord.ServiceMileage__c != null && fileRecord.ServiceMileage__c != '') {
            ocpCase.Current_Mileage__c = decimal.valueof(fileRecord.ServiceMileage__c);
        }
        ocpCase.NMAC_Account__c = fileRecord.CustomerAccountNumber__c;
        ocpCase.Phone_TMID__c = fileRecord.PhoneTMID__c;

        if (fileRecord.MonthMailed__c != null && fileRecord.MonthMailed__c != '') {
            ocpCase.Month_Mailed__c = DataImportTriggersHelper.GetMonthNameUsingNumber(fileRecord.MonthMailed__c);
        }

        ocpCase.Mailing_Zip_Plus4__c = fileRecord.Zip4__c;
        ocpCase.Vehicle_Model__c = fileRecord.ModelNameCurrent__c;
        ocpCase.Mailing_Zip_Code__c = fileRecord.ZipCode__c;
        ocpCase.Contact_ID__c = fileRecord.Contactid__c;
        ocpCase.Bonus_Cash_Code__c = fileRecord.BonusCashCode__c;
        ocpCase.Home_Phone__c = (fileRecord.HomePhone__c == 'DoNotCall') ? '' : fileRecord.HomePhone__c;
        ocpCase.Mailing_State__c = fileRecord.State__c;
        ocpCase.Middle_Initial__c = fileRecord.MiddleInitial__c;
        ocpCase.Vehicle_DQR_Information__c = fileRecord.LeadMOdel__c;
        ocpCase.Mailing_Street_2__c = fileRecord.Address2__c;
        ocpCase.Mailing_Street__c = fileRecord.Address1__c;
        ocpCase.Email2__c = fileRecord.EmailAddress__c;
        ocpCase.Dealer_Name__c = fileRecord.dealername__c;
        ocpCase.Segment_Mailed__c = fileRecord.SegmentMailed__c;
        ocpCase.Control_Group_Check_Box__c = (fileRecord.ControlGroup__c == 'TRUE') ? true : false;
		ocpCase.Incentive_Expiration__c = fileRecord.Incentive_Expiration__c;
        if(fileRecord.Home_Phone_Do_not_Call__c != null && fileRecord.Home_Phone_Do_not_Call__c == 'TRUE'){
			ocpCase.Home_Phone_Do_Not_Call__c = true;
		}
		if(fileRecord.Work_Phone_Do_not_Call__c != null && fileRecord.Work_Phone_Do_not_Call__c == 'TRUE'){
			ocpCase.Work_Phone_Do_Not_Call__c = true;
		}
		if(fileRecord.Work_Phone_Do_not_Call_Cell__c != null && fileRecord.Work_Phone_Do_not_Call_Cell__c == 'TRUE'){
			ocpCase.Mobile_Phone_Do_Not_Call__c = true;
		}
		if(fileRecord.BankruptcyFL__c != null && fileRecord.BankruptcyFL__c == 'TRUE'){
			ocpCase.Status = 'Closed';
			ocpCase.Closed_by_Suppression__c = true;
		}else if(fileRecord.DelinquentFL__c != null && fileRecord.DelinquentFL__c == 'TRUE'){
			ocpCase.Status = 'Closed';
			ocpCase.Closed_by_Suppression__c = true;
		}else if(fileRecord.RepoFl__c != null && fileRecord.RepoFl__c == 'TRUE'){
			ocpCase.Status = 'Closed';
			ocpCase.Closed_by_Suppression__c = true;
		}else{
			ocpCase.Status = (fileRecord.ControlGroup__c == 'TRUE') ? 'Closed' : 'Item Created';
		}
        ocpCase.Last_Name__c = (fileRecord.LastName__c == '' || 
                                fileRecord.LastName__c == null || 
                                fileRecord.LastName__c == 'X') ? fileRecord.FirstName__c : fileRecord.LastName__c;

		if (fileRecord.ContactId__c == null || fileRecord.ContactId__c == '') {

			// If Contact Id is empty, then we log an error and skip to next record in trigger
			fileRecord.Successful__c = false;
			fileRecord.Error_Description__c = 'Contact ID is empty, cannot create a Case';	
			counter++;
			continue;
		}
        Account customer = customersMap.get(fileRecord.ContactId__c);
        if (customer == null) {
            // Create new customer account record
            Account acc = new Account();
            acc.LastName = (fileRecord.LastName__c == '' || 
                            fileRecord.LastName__c == null || 
                            fileRecord.LastName__c == 'X') ? fileRecord.FirstName__c : fileRecord.LastName__c;
            acc.FirstName = fileRecord.FirstName__c;
            acc.Customer_ID__c = fileRecord.Contactid__c;
            //acc.PersonMailingState = fileRecord.State__c;
            acc.PersonHomePhone = (fileRecord.HomePhone__c == 'DoNotCall') ? '' : fileRecord.HomePhone__c;
            acc.PersonMobilePhone = (fileRecord.CellPhone__c == 'DoNotCall') ? '' : fileRecord.CellPhone__c;
            acc.PersonOtherPhone = (fileRecord.WorkPhone__c == 'DoNotCall') ? '' : fileRecord.WorkPhone__c;
            acc.PersonMailingStreet = fileRecord.Address1__c;
            acc.PersonMailingPostalCode = fileRecord.ZipCode__c;
            acc.PersonMailingCity = fileRecord.City__c;
            acc.PersonEmail = fileRecord.EmailAddress__c;
            acc.Alternate_Email__c = fileRecord.EmailAddress2__c;

            if (accountRecordType.size() > 0) {
                acc.RecordTypeId = accountRecordType.get(0).Id;
            }

            newAccounts.Add(acc);
            OCPFileCasesWithoutAccounts.Add(ocpCase);
			ocpCasesWithoutAccMap.put(casesWithoutAccCounter, counter);
			casesWithoutAccCounter++;
            ocpFilesAccountsMap.put(counterAccounts, counter);
            counterAccounts++;
        }
        else {
            ocpCase.AccountId = customer.Id;
            ocpCase.ContactId = customer.PersonContactId;
            OCPFileCases.Add(ocpCase);
			ocpCasesMap.put(casesCounter, counter);
			casesCounter++;
            fileRecord.Successful__c = true;
        }
        ocpFilesMap.put(counter,fileRecord);
        counter++;
        
    }
    List<Account> accountsInserted = new List<Account>();
    // Insert new Accounts
    if (!newAccounts.isEmpty()) {
        // Insert rows
        Database.SaveResult[] dbResults = Database.insert(newAccounts, false);

        // If there are any results, handle the errors
        if (!dbResults.isEmpty())
        {
            // Loop through results returned
            for (integer row = 0; row <newAccounts.size(); row++)
            {
                // If the current row was not sucessful, handle the error.
                if (!dbResults[row].isSuccess())
                {
                    // Get the error for this row and populate corresponding fields
                    Database.Error err = dbResults[row].getErrors() [0];
                    ocpFilesMap.get(ocpFilesAccountsMap.get(row)).Successful__c = false;
                    ocpFilesMap.get(ocpFilesAccountsMap.get(row)).Error_Description__c = 'Account error: ' + err.getMessage();
                }
                else
                {
                    accountsInserted.Add(newAccounts[row]);
                    ocpFilesMap.get(ocpFilesAccountsMap.get(row)).Successful__c = true;
                    ocpFilesMap.get(ocpFilesAccountsMap.get(row)).Error_Description__c = '';
                }
            }
        }
    }
    // map new account records Ids to new cases records Ids

	Set<Id> accIds = (new Map <Id, Account > (accountsInserted)).keySet();

	List <Account > updatedAccounts = [Select Id, PersonContactId, Customer_ID__c from Account where Id IN :accIds];

	Map <String, Account > accountsMap = new Map <String, Account > ();
	for (Account customer : updatedAccounts) {
		accountsMap.put(customer.Customer_ID__c, customer);
	}
	Integer caseRow = 0;
	for (Case c : OCPFileCasesWithoutAccounts) {
		if (accountsMap.containsKey(c.Contact_ID__c)) {
			Account customer = accountsMap.get(c.Contact_ID__c);
			c.AccountId = customer.Id;
			c.ContactId = customer.PersonContactId;
			OCPFileCases.add(c);
			ocpCasesMap.put(casesCounter, ocpCasesWithoutAccMap.get(caseRow));
			casesCounter++;
				
		}
		caseRow++;
	}

    // Insert new Cases
    if (!OCPFileCases.isEmpty()) {
        // Insert rows
        Database.SaveResult[] dbResults = Database.insert(OCPFileCases, false);

        // If there are any results, handle the errors
        if (!dbResults.isEmpty())
        {
            // Loop through results returned
            for (integer row = 0; row <OCPFileCases.size(); row++)
            {
                // If the current row was not sucessful, handle the error.
                if (!dbResults[row].isSuccess())
                {
                    // Get the error for this row and populate corresponding fields
                    Database.Error err = dbResults[row].getErrors() [0];
                    ocpFilesMap.get(ocpCasesMap.get(row)).Successful__c = false;
                    ocpFilesMap.get(ocpCasesMap.get(row)).Error_Description__c = 'Case error: ' + err.getMessage();         
                }else {                         
                    ocpFilesMap.get(ocpCasesMap.get(row)).Successful__c = true;
                    ocpFilesMap.get(ocpCasesMap.get(row)).Error_Description__c = '';
                    ocpFilesMap.get(ocpCasesMap.get(row)).Case_ID__c = dbResults[row].getId();
                }               
            }
        }
    }

    insert errors;

	private static OCP_File_Data_Load__c getOcpFileSettings(){
        OCP_File_Data_Load__c OcpFileSetting = new OCP_File_Data_Load__c();
        OcpFileSetting.DefectorMonthlyExtract_Description__c = 'Reach out to current Nissan Lessees about employee pricing incentive.';
		OcpFileSetting.DefectorMonthlyExtract_Subject__c = 'Pilot Loyalty';
		OcpFileSetting.OCP_Description__c = 'Existing Owner';
		OcpFileSetting.OCP_Subject__c = 'Owner Loyalty';
        insert OcpFileSetting;
        OcpFileSetting = OCP_File_Data_Load__c.getOrgDefaults();
        return OcpFileSetting;
    }
}