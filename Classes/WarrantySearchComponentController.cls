public with sharing class WarrantySearchComponentController {

    public String vin { get; set; }
    public List<WarrantyInformationWrapper> WRTs {get; set;}
    Map<Integer, Warranty_Information__c> warrantyInfoMap;
    Set<String> VINs = new Set<String>();
    
    public WarrantySearchComponentController(){
    
        WRTs = new List<WarrantyInformationWrapper>(); 
        warrantyInfoMap = new Map<Integer, Warranty_Information__c>();   
    
    }
    
    public PageReference searchWarranty(){
        VINs.clear();
        WRTs.clear();
        try{
        if(vin != null && vin != ''){           
            VINs.add(vin);            
            WRTs = VehicleWarrantyIntegrationUtility.warrantyCallout(VINs, warrantyInfoMap);
            
            if(WRTs.size() <= 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.No_records_found));
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.VIN_Required));
        }
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.Warranty_Service_Error));
        }
        
        return null;
    }
    
}