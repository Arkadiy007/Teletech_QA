public class SREditExtension {
    public ApexPages.StandardController srController {get; Set;}
    
    public Map<String, Boolean> profileSettings {get; set;}

    // To determine current user layour - 1+3 = customer, 2+3 = supplier, NOT(3) - EQA, Sysadmin, etc
    public Boolean isCustomerLayout {get; set;}
    public Boolean isSupplierLayout {get; set;}
    public Boolean isGoldPartner {get; set;}

	// To lock record from changes when it is sent
    public Boolean showRestrictedMessage {get; set;}
    
	// For different plants select
    public String selectedPlant {get; set;}
	public List<SelectOption> plantsToSelect {get; set;}


	public String customerId {get; Set;}
	public List<SelectOption> customersToSelect {get; set;}

    public SREditExtension(ApexPages.StandardController sc){
        srController = sc;

        profileSettings = new Map<String, Boolean>();
        getCustomSettingsMap();


        if (srController.getId() != null){
            selectedPlant = [SELECT Plant__c FROM Sorting_Report__c WHERE ID = :srController.getId() LIMIT 1].Plant__c;
        }

        populateDefaultFields();
        getProfileInfo();
        restrictAccess();

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

			 Sorting_Report__c sortingReport = (Sorting_Report__c) srController.getRecord();
			 sortingReport.Customer__c = Id.valueOf(customerId);
		}
		return null;
	}

	public Pagereference save(){
		if (!checkPlantPopulated()){
            return null;
		}

		Sorting_Report__c sortingReport = (Sorting_Report__c) srController.getRecord();
		sortingReport.Plant__c = selectedPlant;   
        Pagereference pageRef = srController.save();
        

        if (String.isEmpty(srController.getRecord().Id)){
            try {           
                insert sortingReport;
                
            }
            catch (Exception e){
                if(!ApexPages.hasMessages(ApexPages.Severity.Error)){
                    String errorMessage = prepareErrorMessage(e.getMessage());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                    return null;
                }
            }
        }
    
        return pageRef;
    }

    public Pagereference saveAndNew(){
		if (!checkPlantPopulated()){
            return null;
		}


		Sorting_Report__c sortingReport = (Sorting_Report__c) srController.getRecord();
		sortingReport.Plant__c = selectedPlant;
        srController.save();
        
        PageReference newPagePR = new PageReference('/apex/SREdit');
        newPagePR.setRedirect(true);

        return newPagePR;
    }

    public Pagereference saveAndSend(){
		if (!checkPlantPopulated()){
            return null;
		}
        
        Sorting_Report__c sortingReport = (Sorting_Report__c) srController.getRecord();
        sortingReport.Plant__c = selectedPlant;
        PageReference pageRef = srController.save();
        if (null == pageRef) {
          // record not saved, in this case show error messages
          return null;
        }

        Boolean isInsert = false;
        sortingReport = (Sorting_Report__c) srController.getRecord();
        //check if its report creation
        if (!ApexPages.currentpage().getparameters().containsKey('id')){
            EmailNotificationHelper.disabledAutoSharing(sortingReport);
            EmailNotificationHelper.sendNotification(sortingReport, 'Sorting Report Notification For Supplier', 'Supplier');
            EmailNotificationHelper.sendEmails();
            sortingReport.Last_Modified_By_Customer__c = System.now();
            sortingReport.Current_Owner__c = 'Supplier';
            if(EmailNotificationHelper.currentOwnerId != null){
                sortingReport.OwnerId = EmailNotificationHelper.currentOwnerId;
            }
            isInsert = true;
        } else {
          sortingReport.Save_And_Send_Flag__c = true;
        }

        try {           
            upsert sortingReport;
            ShareHelper.share(sortingReport);
        }
        catch (Exception e){
            if(!ApexPages.hasMessages(ApexPages.Severity.Error)){
                String errorMessage = prepareErrorMessage(e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                return null;
            }
        }

        return pageRef;
    }

    public Pagereference saveSendAndNew(){
		if (!checkPlantPopulated()){
            return null;
		}

        saveAndSend();
        
        if(!ApexPages.hasMessages(ApexPages.Severity.Error)){
            PageReference newPagePR = new PageReference('/apex/SREdit');
            newPagePR.setRedirect(true);

            return newPagePR;
        }
        return null;
    }

    private String prepareErrorMessage(String errorMsg){
        if (errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            return errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ':');
        }

        return errorMsg;
    }

    private void getProfileInfo(){
        Profile currentProfile = [Select Name From Profile  where Id=:UserInfo.getProfileId()][0];
        
        if (currentProfile.Name.contains('Customer')){
            isCustomerLayout = true;
        }
        else if (currentProfile.Name.contains('Supplier')){
            isSupplierLayout = true;
        }
    }

    public void restrictAccess(){
        String currentOwner = selectCurrentOwner();
        String currentProfileId = String.valueOf(UserInfo.getProfileId()).substring(0, 15);

        if(String.isNotBlank(currentOwner)){
            if(profileSettings.containsKey(currentProfileId + currentOwner)){
                showRestrictedMessage = !profileSettings.get(currentProfileId + currentOwner);
            }
        }
    }

    private void populateDefaultFields() {
        isCustomerLayout = false;
        isSupplierLayout = false;
        showRestrictedMessage = false;
		isGoldPartner = false;

        // query User
        User[] users = [SELECT Id, Contact.AccountId, Profile.Name,  Contact.Account.Plant__c, Profile.UserLicense.Name 
                                            FROM User
                                         WHERE ID = :UserInfo.getUserId()];

        // set customer info
        if (!users.isEmpty() && users[0].Profile.Name.contains('Customer')) {
            Sorting_Report__c sortingReport = (Sorting_Report__c) srController.getRecord();
            sortingReport.Customer__c = users[0].Contact.AccountId;
            
			plantsToSelect = new List<SelectOption>();
			plantsToSelect.add(new SelectOption('None', 'None'));
			if(String.isNotBlank(users[0].Contact.Account.Plant__c)){
				List<String> allPlants = users[0].Contact.Account.Plant__c.split(';');
				
				for(String plant : allPlants){
					plantsToSelect.add(new SelectOption(plant, plant));
				}
		    }

			if(plantsToSelect.size() ==  2){
				selectedPlant = plantsToSelect[1].getValue();
			}
        }

		// check that current user is Gold Partner license
		if (!users.isEmpty() && users[0].Profile.UserLicense.Name == 'Gold Partner') {
		   isGoldPartner = true;
		}
    }

    private void getCustomSettingsMap(){
        for(EQA_Owner_Rules__c ownerRule : EQA_Owner_Rules__c.getAll().values()){
            profileSettings.put(ownerRule.Profile_Id__c+ownerRule.Current_Owner__c, ownerRule.Edit__c);
        }   
    }

    private String selectCurrentOwner(){
        if(srController.getId() != null){
            Sorting_Report__c currentPIR = [SELECT Id, Current_Owner__c FROM Sorting_Report__c WHERE Id = :srController.getId() LIMIT 1];

            if(currentPIR != null){
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
		customerId = ( (Sorting_Report__c) srController.getRecord()).Customer__c;
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