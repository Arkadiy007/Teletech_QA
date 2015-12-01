public class MCEditExtension {
	public ApexPages.StandardController mcController { get; Set; }

	public Boolean isIncidentClaimRecordType { get; set; }
	public Boolean isSortingReportRecordType { get; set; }

	public Boolean isCustomerLayout { get; set; }
	public Boolean isSupplierLayout { get; set; }
	public Boolean isMasterLayout { get; set; }
    public Boolean isGoldPartner {get; set;}


	public String selectedPlant { get; set; }
	public List<SelectOption> plantsToSelect { get; set; }

	public String customerId {get; Set;}
	public List<SelectOption> customersToSelect {get; set;}

	public Map<String, Boolean> profileSettings { get; set; }
	public Boolean showRestrictedMessage { get; set; }

	public MCEditExtension(ApexPages.StandardController sc) {
		mcController = sc;
		isIncidentClaimRecordType = false;
		isSortingReportRecordType = false;

		isCustomerLayout = false;
		isSupplierLayout = false;
		isMasterLayout = true;
		isGoldPartner = false;

		if (mcController.getId() != null) {
			selectedPlant = [SELECT Plant__c FROM Monetary_Claim__c WHERE ID = :mcController.getId() LIMIT 1].Plant__c;
		}


		getProfileInfo();

		showRestrictedMessage = false;
		profileSettings = new Map<String, Boolean> ();
		getCustomSettingsMap();
		restrictAccess();
		populateDefaultFields();

		Monetary_Claim__c draftRecord = (Monetary_Claim__c) sc.getRecord();

		if (draftRecord.RecordTypeId == RecordtypeUtil.getObjectRecordTypeId(Monetary_Claim__c.sObjectType, 'Incident Claim')) {
			isIncidentClaimRecordType = true;
		}
		else if (draftRecord.RecordTypeId == RecordtypeUtil.getObjectRecordTypeId(Monetary_Claim__c.sObjectType, 'Sorting Report')) {
			isSortingReportRecordType = true;
		}

 
		if (!isCustomerLayout && !isSupplierLayout){
			populateCustomersToSelect();
		}
	}

	public PageReference repopulatePlantsForCustomer(){
		if(customerId != null){
			List<Account> customerAcc = [SELECT Plant__c FROM Account WHERE Id = :customerId LIMIT 1];
			plantsToSelect = new List<SelectOption>();
			if (customerAcc.size() > 0 && String.isNotBlank(customerAcc[0].Plant__c)){
				plantsToSelect.add(new SelectOption('None', 'None'));
				List<String> allPlants = customerAcc[0].Plant__c.split(';');
				
				for(String plant : allPlants){
					plantsToSelect.add(new SelectOption(plant, plant));
				}
			}

			 Monetary_Claim__c mc = (Monetary_Claim__c) mcController.getRecord();
			 mc.Customer__c = Id.valueOf(customerId);
		}
		return null;
	}

	public Pagereference save() {
		if (!checkPlantPopulated()){
            return null;
		}

		Monetary_Claim__c mc = (Monetary_Claim__c) mcController.getRecord();
		mc.Plant__c = selectedPlant;
		Pagereference pageRef = mcController.save();

		if (String.isEmpty(mcController.getRecord().Id)) {
			try {
				insert mc;

			}
			catch(Exception e) {
				if (!ApexPages.hasMessages(ApexPages.Severity.Error)) {
					String errorMessage = prepareErrorMessage(e.getMessage());
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
					return null;
				}
			}
		}

		return pageRef;
	}

	public Pagereference saveAndNew() {
		if (!checkPlantPopulated()){
            return null;
		}

		Monetary_Claim__c mc = (Monetary_Claim__c) mcController.getRecord();
		mc.Plant__c = selectedPlant;
		mcController.save();

		PageReference newPagePR = new PageReference('/apex/MCEdit');
		newPagePR.setRedirect(true);

		return newPagePR;
	}

	public Pagereference saveAndSend() {
		if (!checkPlantPopulated()){
            return null;
		}

    Monetary_Claim__c mc = (Monetary_Claim__c) mcController.getRecord();
    mc.Plant__c = selectedPlant;
		PageReference pageRef = mcController.save();
    if (null == pageRef) {
      // record not saved, in this case show error messages
      return null;
    }

		Boolean isInsert = false;
		mc = (Monetary_Claim__c) mcController.getRecord();
		if (!ApexPages.currentpage().getparameters().containsKey('id')) {
      EmailNotificationHelper.disabledAutoSharing(mc);
			EmailNotificationHelper.sendNotification(mc, 'Monetary Claim Notification For Supplier', 'Supplier');
			EmailNotificationHelper.sendEmails();
			mc.Last_Modified_By_Customer__c = System.now();
			mc.Current_Owner__c = 'Supplier';
			if (EmailNotificationHelper.currentOwnerId != null) {
				mc.OwnerId = EmailNotificationHelper.currentOwnerId;
			}
			isInsert = true;
		} else {
      mc.Save_And_Send_Flag__c = true;
    }

		try {
			upsert mc;

			ShareHelper.share(mc);
		}
		catch(Exception e) {
			if (!ApexPages.hasMessages(ApexPages.Severity.Error)) {
				String errorMessage = prepareErrorMessage(e.getMessage());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
				return null;
			}
		}

		return pageRef;
	}

	public Pagereference saveSendAndNew() {
		saveAndSend();

		if (!ApexPages.hasMessages(ApexPages.Severity.Error)) {
			PageReference newPagePR = new PageReference('/apex/MCEdit');
			newPagePR.setRedirect(true);

			return newPagePR;
		}
		return null;
	}

	public void restrictAccess() {
		String currentOwner = selectCurrentOwner();
		String currentProfileId = String.valueOf(UserInfo.getProfileId()).substring(0, 15);

		if (String.isNotBlank(currentOwner)) {
			if (profileSettings.containsKey(currentProfileId + currentOwner)) {
				showRestrictedMessage = !profileSettings.get(currentProfileId + currentOwner);
			}
		}
	}

	private String prepareErrorMessage(String errorMsg) {
		if (errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
			return errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ':');
		}

		return errorMsg;
	}

	private void getProfileInfo() {
		Profile currentProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()] [0];

		if (currentProfile.Name.contains('Customer')) {
			isCustomerLayout = true;
			isMasterLayout = false;
		}
		else if (currentProfile.Name.contains('Supplier')) {
			isSupplierLayout = true;
			isMasterLayout = false;
		}
	}

	private void populateDefaultFields() {
		// query User
		User[] users = [SELECT Id, Contact.AccountId, Profile.UserLicense.Name, Contact.Account.Plant__c, Profile.Name
		                FROM User
		                WHERE ID = :UserInfo.getUserId()];

		// set customer info
		if (!users.isEmpty() && users[0].Profile.Name.contains('Customer')) {
			Monetary_Claim__c mc = (Monetary_Claim__c) mcController.getRecord();
			mc.Customer__c = users[0].Contact.AccountId;

			plantsToSelect = new List<SelectOption> ();
			plantsToSelect.add(new SelectOption('None', 'None'));
			if (String.isNotBlank(users[0].Contact.Account.Plant__c)) {
				List<String> allPlants = users[0].Contact.Account.Plant__c.split(';');

				for (String plant : allPlants) {
					plantsToSelect.add(new SelectOption(plant, plant));
				}
			}

			if(plantsToSelect.size() ==  2){
				selectedPlant = plantsToSelect[1].getValue();
			}
		}

		 if (!users.isEmpty() && users[0].Profile.UserLicense.Name == 'Gold Partner') {
            isGoldPartner = true;
		 }
	}
	private void getCustomSettingsMap() {
		for (EQA_Owner_Rules__c ownerRule : EQA_Owner_Rules__c.getAll().values()) {
			profileSettings.put(ownerRule.Profile_Id__c + ownerRule.Current_Owner__c, ownerRule.Edit__c);
		}
	}

	private String selectCurrentOwner() {
		if (mcController.getId() != null) {
			Monetary_Claim__c currentPIR = [SELECT Id, Current_Owner__c FROM Monetary_Claim__c WHERE Id = :mcController.getId() LIMIT 1];

			if (currentPIR != null) {
				return currentPIR.Current_Owner__c;
			}
		}
		return '';
	}

	private Boolean checkPlantPopulated(){
		if (selectedPlant == 'None'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Plant: You must enter a value'));
			selectedPlant = null;
            return false;
		}
		return true;
	}


	private void populateCustomersToSelect(){
		customerId = ( (Monetary_Claim__c) mcController.getRecord()).Customer__c;
		if (customerId != null){
			repopulatePlantsForCustomer();
		}		

		List<Account> customerAccs = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'Plant'];
		customersToSelect = new List<SelectOption>();

		for (Account plant : customerAccs){
			customersToSelect.add(new SelectOption(String.valueOf(plant.Id), plant.Name));
		}

		if (customerId == null && customersToSelect.size() > 0){
			customerId = Id.valueOf(customersToSelect[0].getValue());
			repopulatePlantsForCustomer();		
		}
	}
}