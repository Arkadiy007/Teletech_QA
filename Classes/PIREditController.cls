public class PIREditController {
    public ApexPages.StandardController pirController {get; Set;}

    public String comments {get; Set;}
    private Part_Incident_Report__c report {get; Set;}
    
    public Boolean isCustomerLayout {get; set;}
    public Boolean isSupplierLayout {get; set;}
    public Boolean isGoldPartner {get; set;}

    public Map<String, Boolean> profileSettings {get; set;}
    public Boolean showRestrictedMessage {get; set;}

    public String selectedPlant {get; set;}
	public List<SelectOption> plantsToSelect {get; set;}

	public String customerId {get; Set;}
	public List<SelectOption> customersToSelect {get; set;}

    public PIREditController(ApexPages.StandardController sc){
        pirController = sc;

        showRestrictedMessage = false;
        
        if (pirController.getId() != null){
            selectedPlant = [SELECT Plant__c FROM Part_Incident_Report__c WHERE ID = :pirController.getId() LIMIT 1].Plant__c;
        }
        
		plantsToSelect = new List<SelectOption>();
        profileSettings = new Map<String, Boolean>();


        populateDefaultFields();
        getProfileInfo();
        getCustomSettingsMap();
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

			 report = (Part_Incident_Report__c) pirController.getRecord();
			 report.Customer__c = Id.valueOf(customerId);
		}
		return null;
	}

    public Pagereference save(){	
		if (!checkPlantPopulated()){
            return null;
		}
		checkCommentIsAdded();

        report = (Part_Incident_Report__c) pirController.getRecord();
		report.Plant__c = selectedPlant;
		
		
        
		Pagereference recordDetailPR = pirController.save();
        
        if (String.isEmpty(pirController.getRecord().Id)){
            try {           
                insert report;
                
            }
            catch (Exception e){
                if(!ApexPages.hasMessages(ApexPages.Severity.Error)){
                    String errorMessage = prepareErrorMessage(e.getMessage());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                    return null;
                }
            }
        }
    
        createCommentsRecord();
        return recordDetailPR;
    }
    
    public Pagereference saveAndSend(){
        if (!checkPlantPopulated()){
          return null;
        }

        checkCommentIsAdded();
        report = (Part_Incident_Report__c) pirController.getRecord();
        report.Plant__c = selectedPlant;
        PageReference pageRef = pirController.save();
        if (null == pageRef) {
          // record not saved, in this case show error messages
          return null;
        }

        report = (Part_Incident_Report__c) pirController.getRecord();
        Boolean isInsert = false;

        // As we have trigger only on update:
        if (!ApexPages.currentpage().getparameters().containsKey('id')){
            EmailNotificationHelper.disabledAutoSharing(report);
            EmailNotificationHelper.sendNotification(report, 'PIR Notification For Supplier', 'Supplier');
            EmailNotificationHelper.sendEmails();

            report.Last_Modified_By_Customer__c = System.now();
            report.Current_Owner__c = 'Supplier';
            if(EmailNotificationHelper.currentOwnerId != null){
                report.OwnerId = EmailNotificationHelper.currentOwnerId;
            }
            isInsert = true;
        } else {
          report.Save_And_Send_Flag__c = true;
        }

        try {        
            upsert report;
            createCommentsRecord();
            ShareHelper.share(report);
        }
        catch (Exception e){
            if(!ApexPages.hasMessages(ApexPages.Severity.Error)){
                String errorMessage = prepareErrorMessage(e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                return null;            
            }
            return null;
        }

        return pageRef;
    }

    public Pagereference saveSendAndNew(){
		if (!checkPlantPopulated()){
            return null;
		}

	    checkCommentIsAdded();
        saveAndSend();
         
        if(!ApexPages.hasMessages(ApexPages.Severity.Error)){
            PageReference newPagePR = new PageReference('/apex/PIREdit?sfdc.tabName=01r180000008a1i');
            newPagePR.setRedirect(true);

            return newPagePR;
        }
        return null;
    }

    public Pagereference saveAndNew(){
		if (!checkPlantPopulated()){
            return null;
		}

		checkCommentIsAdded();
        report = (Part_Incident_Report__c) pirController.getRecord();
        report.Plant__c = selectedPlant;
        pirController.save();

        if (String.isEmpty(pirController.getRecord().Id)){
            try {           
                insert report;
                
            }
            catch (Exception e){
                if(!ApexPages.hasMessages(ApexPages.Severity.Error)){
                    String errorMessage = prepareErrorMessage(e.getMessage());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                    return null;
                }
            }
        }
        createCommentsRecord();
        pirController.save();
        PageReference newPagePR = new PageReference('/apex/PIREdit?sfdc.tabName=01r180000008a1i');
        newPagePR.setRedirect(true);

        return newPagePR;
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


    private void createCommentsRecord(){
        if (String.isNotBlank(comments) && report.id != null){
            PIR_Comment__c comment = new PIR_Comment__c(Comment__c = comments, Part_Inquiry_Request__c = report.Id);
            insert comment;
        }
    }

    private String prepareErrorMessage(String errorMsg){
        if (errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            return errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ':');
        }

        if (errorMsg.contains('DUPLICATE_VALUE')){
            return errorMsg.substringBetween('DUPLICATE_VALUE,', 'on');
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

    private void populateDefaultFields() {
		isCustomerLayout = false;
        isSupplierLayout = false;
		isGoldPartner = false;

        // query User
        User[] users = [SELECT Id, Contact.AccountId, Contact.Account.Plant__c, Profile.Name, Profile.UserLicense.Name 
                                            FROM User
                                         WHERE ID = :UserInfo.getUserId()];

        // set customer info
        if (!users.isEmpty() && users[0].Profile.Name.contains('Customer')) {
            Part_Incident_Report__c report = (Part_Incident_Report__c) pirController.getRecord();
            report.Customer__c = users[0].Contact.AccountId;
            
			plantsToSelect = new List<SelectOption>();
			if(String.isNotBlank(users[0].Contact.Account.Plant__c)){
				plantsToSelect.add(new SelectOption('None', 'None'));
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
        if(pirController.getId() != null){
            Part_Incident_Report__c currentPIR = [SELECT Id, Current_Owner__c FROM Part_Incident_Report__c WHERE Id = :pirController.getId() LIMIT 1];

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

	private void checkCommentIsAdded(){
		 Part_Incident_Report__c pir =  (Part_Incident_Report__c) pirController.getRecord();

		 if (String.isNotBlank(comments)){
			 if(isCustomerLayout){
				pir.Last_Modified_By_Customer__c = System.now();
			 }
			 else if(isSupplierLayout){
				pir.Last_Modified_By_Supplier__c = System.now();
			}
		 }
	}

	private void populateCustomersToSelect(){
		customerId = ( (Part_Incident_Report__c) pirController.getRecord()).Customer__c;
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