public class VehicleRecallByVINsInCasesExtension {
    
    public boolean showPowerCust{get; set;}
    public boolean showF1Dealer {get; set;}
     
    public VehicleRecallByVINsInCasesExtension(ApexPages.StandardController controller) {
        showPowerCust = false;
        showF1Dealer = false;
        Date inServStartDt = Date.parse(Label.In_Service_Start_Date);
        Date inServEndDt = Date.parse(Label.In_Service_End_Date);
        
        Id caseId = ((Case)controller.getRecord()).Id;
        
        Case caseObj = [Select Id, AccountId, Vehicle_Name__c, Vehicle_Name__r.In_Service_Date__c, F1_Dealer__c, RecordType.Name
        				from Case where Id =: caseId limit 1];
        
        if(caseObj != null){
	        if(Label.Show_JD_Power_Message == 'Yes'){
	        	if(caseObj.Vehicle_Name__r.In_Service_Date__c >= inServStartDt && caseObj.Vehicle_Name__r.In_Service_Date__c <= inServEndDt){
	           		 showPowerCust = true;
	        	}        	
	        }
         	if(caseObj.F1_Dealer__c != null && (caseObj.RecordType.Name == 'TECH LINE' || caseObj.RecordType.Name == 'TECH LINE Cases') && caseObj.F1_Dealer__c == 'F1'){
         		showF1Dealer = true;	
         	}
        }     
    }

}