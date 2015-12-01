/**********************************************************************
Name: Specialty_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This Trigger looks up the TechlineVirtualAcademy__c (Master)
record to associate the Specialty record to using the
lookup fields Technician__c.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr         03/26/2014 Created
***********************************************************************/
trigger Specialty_Before on Specialty__c (Before Insert) {

    Map<string, string> tvaids = new Map<string, string>();
    Set<String> exdealerids = new Set<String>();
    
    for(Specialty__c s : trigger.new){
     
        if(s.Technician__c == null && s.SFDC_Dealer_External_ID__c != null){
            exdealerids.add(s.SFDC_Dealer_External_ID__c);
        }        
        
    }
    
    //Get all TechlineVirtualAcademyRecords
    if(exdealerids.size()>0){
        
        for(TechlineVirtualAcademy__c tva : [select Id, SFDC_External_Id__c from TechlineVirtualAcademy__c
                                             where SFDC_External_Id__c in :exdealerids]){
            
            String tvaid = tva.Id;
            tvaids.put(tva.SFDC_External_Id__c, tvaid);                                       
       }
    
    //sync the Specialty with the TVA record
            for(Specialty__c s : trigger.new){
        
                if(s.Technician__c == null && 
                    s.SFDC_Dealer_External_ID__c != null && 
                    tvaids.containsKey(s.SFDC_Dealer_External_ID__c)){
       
                        s.Technician__c = tvaids.get(s.SFDC_Dealer_External_ID__c);
        
            }
        }
    }    

}