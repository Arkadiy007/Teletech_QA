/**********************************************************************
  Name:Stage_FF_Hot_Alert_Before
  Copyright ? notice: Nissan Motor Company.
  ======================================================
  Purpose:
  This trigger creates new Case, whenever new record created for Nissan_Daily_Welcome_Call__c object
  ======================================================
  History:
 
  VERSION AUTHOR DATE DETAIL 
  1.0 - Anna Koseikina 02/23/2015 Created
  1.1 - Arkadiy Sychev 03/17/2015 Add checking on fields with null values
 ***********************************************************************/
trigger NissanWelcomeCalls_Before on Nissan_Daily_Welcome_Call__c (before insert)  {
	List <Case > WelcomeCallsCases = new List <Case > ();
	List <String > customerIds = new List <String > ();
	List <String > vins = new List <String > ();
	List <String > dealerCodes = new List <String > ();

	for (Nissan_Daily_Welcome_Call__c call : Trigger.New) {
		// 1.1 - Arkadiy Sychev 03/17/2015 Add checking on fields with null values
		if (call.CustomerID__c != null && call.CustomerID__c != '') {
			customerIds.add(call.CustomerID__c);
		}

		if (call.VIN__c != null && call.VIN__c != '') {
			vins.add(call.VIN__c);
		}

		if (call.Retailing_Dealer_Number__c != null && call.Retailing_Dealer_Number__c != '') {
			dealerCodes.add(call.Retailing_Dealer_Number__c);
        }
	}

	List <Account > customers = [Select Id, PersonContactId, Customer_ID__c FROM Account WHERE Customer_ID__c in :customerIds];
	List <Account > dealers = [Select Id, Dealer_Code__c FROM Account WHERE Dealer_Code__c in :dealerCodes];
	List <Vehicle__c > vehicles = [Select Id, Vehicle_identification_Number__c FROM Vehicle__c WHERE Vehicle_identification_Number__c in :vins];
	List <Group> cccGroup = [select Id, Name from Group where Name = :'CCC Campaign Queue' and Type = 'Queue'];

	List <RecordType> salesRecordType = [Select Id, Name from RecordType WHERE Name = :'Sales & Service Record Type'];

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

	//map to store corresponding welcome calls and its number in list
	Map<Integer,Nissan_Daily_Welcome_Call__c> callsCasesMap = new Map<Integer,Nissan_Daily_Welcome_Call__c>();
	Integer counter = 0;
	//map to store corresponding Hot alerts number and case number in list
    Map<Integer,Integer> welcomeCallCasesMap = new Map<Integer,Integer>();
	Integer counterCases = 0;
	for (Nissan_Daily_Welcome_Call__c call : Trigger.New) {		
		Case callCase = new Case();
		if (call.CustomerID__c == null || call.CustomerID__c == '') {

			// If Customer Id is empty, then we log an error and skip to next record in trigger
			call.Successful__c = false;
			call.Error_Description__c = 'Customer ID is empty, cannot create a Case';
			counter++;	
			continue;
		}
		Account customer = customersMap.get(call.CustomerID__c);
		if (customer == null) {
			// If there is no customer account found by corresponding CustomerId__c, then we log an error and skip to next record in trigger
			call.Successful__c = false;
			call.Error_Description__c = String.format('There is no customer Account for CustomerId__c={0}', new String[] { call.CustomerID__c });	
			continue;
		}
		else {
			callCase.AccountId = customer.Id;
			callCase.ContactId = customer.PersonContactId;
		}

		Account dealer = dealersMap.get(call.Retailing_Dealer_Number__c);
		if (dealer != null) {
			callCase.Dealer__c = dealer.Id;
			callCase.Servicing_Dealer__c = dealer.Id;
		}

		Vehicle__c vehicle = vehiclesMap.get(call.VIN__c);
		if (vehicle != null) {
			callCase.Vehicle_Name__c = vehicle.Id;
		}
		callCase.VIN__c = call.VIN__c;

		callCase.Mailing_Street__c = call.Mailing_Street__c;
		callCase.Contact_ID__c = call.CustomerID__c;
		callCase.Work_Phone__c = call.Account_WorkPhone__c;
		callCase.Dealer_Number__c = call.Retailing_Dealer_Number__c;
		callCase.Dealer_Name__c = call.Retailing_Dealer_Name__c;
		callCase.Vehicle_Model__c = call.Model_Name__c;
		callCase.Vehicle_Year__c = call.Model_year__c;

		callCase.Email2__c = call.Account_Emailaddress__c;
		callCase.Home_Phone__c = call.Account_HomePhone__c;
		//callCase.First_Name__c = call.Account_First_Name__c;
		//callCase.Last_Name__c = call.Account_Last_name__c;
		callCase.Event_Date__c = call.Purchased_Date__c;
		callCase.Origin = 'Data Load';		
		callCase.Mailing_Zip_Code__c = call.Mailing_ZipCode__c;
		callCase.Priority = 'Low';
		callCase.Mailing_State__c = call.Mailing_State__c;
		callCase.Status = 'Item Created';
		callCase.Mailing_City__c = call.Mailing_City__c;
		callCase.Description = ' Welcome Call';

		callCase.RecordTypeId = salesRecordType.get(0).Id;			

		callCase.Subject = 'Revana SSI Welcome Call';

		if (cccGroup.size() > 0) {
				callCase.OwnerId = cccGroup.get(0).Id;	
		}
		
		WelcomeCallsCases.Add(callCase);
		// number + call
		welcomeCallCasesMap.put(counterCases,counter);
		counterCases++;
		callsCasesMap.put(counter,call);
		counter++;
	}

	// Insert new Cases
	if (!WelcomeCallsCases.isEmpty()) {
		// Insert rows
		Database.SaveResult[] dbResults = Database.insert(WelcomeCallsCases, false);
		// If there are any results, handle the errors
		if (!dbResults.isEmpty())
		{
			// Loop through results returned
			for (integer row = 0; row <WelcomeCallsCases.size(); row++)
			{
				// If the current row was not sucessful, handle the error.
				if (!dbResults[row].isSuccess())
				{
					// Get the error for this row and populate corresponding fields
					Database.Error err = dbResults[row].getErrors() [0];
					callsCasesMap.get(welcomeCallCasesMap.get(row)).Successful__c = false;
					callsCasesMap.get(welcomeCallCasesMap.get(row)).Error_Description__c = err.getMessage();			
				}else{					
					callsCasesMap.get(welcomeCallCasesMap.get(row)).Successful__c = true;
					callsCasesMap.get(welcomeCallCasesMap.get(row)).Error_Description__c = '';
					callsCasesMap.get(welcomeCallCasesMap.get(row)).Case_ID__c = dbResults[row].getId();
				}
			}
		}
	}

}