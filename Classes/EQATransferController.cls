public class EQATransferController {

	public String redirectString {get; set;}
	public Boolean isSuccess {get; set;}
	private Id objectId {get; Set;}
	private String owner {get; set;}
	
	public PageReference changeOwner(){
		getObjectId();
		getOwner();
		isSuccess = false;
		redirectString = '/';
		if(propertiesValid()){
			if(objectId.getSObjectType() == Monetary_Claim__c.sObjectType) {
				Monetary_Claim__c monClaim = selectMonetaryClaim();
				
				if(owner == 'Supplier'){
					EmailNotificationHelper.getSuppliersForMC(monClaim);
					monClaim.Current_Owner__c = 'Supplier';
          EmailNotificationHelper.sendNotification(monClaim, 'Monetary Claim Notification For Supplier', 'Supplier');
				}
				else if(owner == 'Customer'){
					EmailNotificationHelper.getCustomersForMC(monClaim);
					monClaim.Current_Owner__c = 'Customer';
          EmailNotificationHelper.sendNotification(monClaim, 'Monetary Claim Notification For Customer', 'Customer');
				}

				monClaim.OwnerId = EmailNotificationHelper.currentOwnerId;
        
        EmailNotificationHelper.disabledAutoSharing(monClaim);
				update monClaim;
				isSuccess = true;
				redirectString += String.valueOf(monClaim.Id);
				ShareHelper.share(monClaim);

        EmailNotificationHelper.sendEmails();
			}


			if(objectId.getSObjectType() == Part_Incident_Report__c.sObjectType){
				Part_Incident_Report__c partIncidentReport = selectPartIncidentReport();
				
				if(owner == 'Supplier'){
					EmailNotificationHelper.getSuppliersForPIR(partIncidentReport);
					partIncidentReport.Current_Owner__c = 'Supplier';
          EmailNotificationHelper.sendNotification(partIncidentReport, 'PIR Notification For Supplier', 'Supplier');
				}
				else if(owner == 'Customer'){
					EmailNotificationHelper.getCustomersForPIR(partIncidentReport);
					partIncidentReport.Current_Owner__c = 'Customer';
          EmailNotificationHelper.sendNotification(partIncidentReport, 'PIR Notification For Customer', 'Customer');
				}

				partIncidentReport.OwnerId = EmailNotificationHelper.currentOwnerId;
				
        EmailNotificationHelper.disabledAutoSharing(partIncidentReport);
        update partIncidentReport;
				isSuccess = true;
				redirectString += String.valueOf(partIncidentReport.Id);
				ShareHelper.share(partIncidentReport);

        EmailNotificationHelper.sendEmails();
			}
			
			if(objectId.getSObjectType() == Sorting_Report__c.sObjectType){
				Sorting_Report__c sortingReport = selectSortingReport();
				
				if(owner == 'Supplier'){
					EmailNotificationHelper.getSuppliersForSR(sortingReport);
					sortingReport.Current_Owner__c = 'Supplier';
          EmailNotificationHelper.sendNotification(sortingReport, 'Sorting Report Notification For Supplier', 'Supplier');
				}
				else if(owner == 'Customer'){
					EmailNotificationHelper.getCustomersForSR(sortingReport);
					sortingReport.Current_Owner__c = 'Customer';
          EmailNotificationHelper.sendNotification(sortingReport, 'Sorting Report Notification For Customer', 'Customer');
				}

				sortingReport.OwnerId = EmailNotificationHelper.currentOwnerId;
				
        EmailNotificationHelper.disabledAutoSharing(sortingReport);
        update sortingReport;
				isSuccess = true;
				redirectString += String.valueOf(sortingReport.Id);
				ShareHelper.share(sortingReport);

        EmailNotificationHelper.sendEmails();
			}
		}
		
		if (!isSuccess){
			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Info, 'Issues with sending to ' + owner + '. Please check ' + owner + ' users exsist'));
		}

    redirectString = Site.getPathPrefix() + redirectString;
		return null;
	}


	private void getObjectId(){
		if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('id'))){
			objectId = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));			
		}
	}

	private void getOwner(){
		if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('owner'))){
			owner = ApexPages.currentPage().getParameters().get('owner');			
		}
	}

	private Monetary_Claim__c selectMonetaryClaim(){
		return [SELECT Id, Customer__c, Part_Incident_Report__c, Sorting_Report__c, RecordTypeId FROM Monetary_Claim__c WHERE Id =: objectId LIMIT 1][0];
	}

	private Part_Incident_Report__c selectPartIncidentReport(){
		return [SELECT Id, Customer__c, Part__c FROM Part_Incident_Report__c WHERE Id =: objectId LIMIT 1][0];
	}

	private Sorting_Report__c selectSortingReport(){
		return [SELECT Id, Customer__c, Part__c FROM Sorting_Report__c WHERE Id =: objectId LIMIT 1][0];
	}

	private Boolean propertiesValid(){
		return objectId != null && String.isNotBlank(owner) && (owner == 'Supplier' || owner == 'Customer');
	}

}