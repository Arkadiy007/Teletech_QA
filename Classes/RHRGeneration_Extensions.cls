public with sharing class RHRGeneration_Extensions {
    
    public boolean isSuccess {get; set;}
    public Case casObj {get; set;}
    
    public RHRGeneration_Extensions(ApexPages.StandardController controller) {
    
        casObj = [Select Id, CaseNumber, ContactId, Vehicle_Name__r.Name, Vehicle_Name__r.Id, Vehicle_Name__c, Servicing_Dealer_Region__c from Case where Id =: ((Case)controller.getRecord()).Id];        
        
    }
    
    public PageReference CallRepairOrder(){
        Map<String, ID> mapVINs = new Map<String, ID>();
        mapVINs.put(casObj.Vehicle_Name__r.Name, casObj.Vehicle_Name__r.Id);
        List<Service_Repair_History__c> ROs = new List<Service_Repair_History__c>();
        List<Service_Repair_History__c> SRHs = new List<Service_Repair_History__c>();
        
        isSuccess = false;
        if(casObj != null && casObj.Vehicle_Name__c != null){
         try{
              Controller_ByVinsInAccount_RepairOrders.callout(mapVINs, ROs); 
              Controller_ByVinsInAccount_Claims.callout(mapVINs, SRHs); 
              
              if(ROs.size() > 0){
                  Controller_ByVinsInAccount_Claims.dmlOperations(ROs);
              }
              
              if(SRHs.size() > 0){
                  Controller_ByVinsInAccount_Claims.dmlOperations(SRHs);
              }  
              
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Success! Please hit Create RHR button to create the RHR Attachment.'));  
                        
          } catch (CalloutException ex) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occurred while trying to create RHRs. Please try again by clicking Retry and if the issue persists, please contact your administrator'));
          }
            
        }
    
        return null;
    }

}