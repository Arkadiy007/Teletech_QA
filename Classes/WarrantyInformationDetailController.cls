public with sharing class WarrantyInformationDetailController {

    public Warranty_Information__c wrtyInfo{ get; set; }
    
    
    public WarrantyInformationDetailController(){
        wrtyInfo = new Warranty_Information__c();
        
        Map<String, String> pageParam = ApexPages.currentPage().getParameters();
        
        if(!pageParam.isEmpty()){
            if(pageParam.get('desc') != null && pageParam.get('desc') != ''){
                wrtyInfo.Warranty_Description__c = pageParam.get('desc');
            }
            if(pageParam.get('title') != null && pageParam.get('title') != ''){
                wrtyInfo.Title_Number__c= pageParam.get('title');
            }
            if(pageParam.get('expDate') != null && pageParam.get('expDate') != ''){
                System.debug('Date::'+pageParam.get('expDate'));
                wrtyInfo.Warranty_Expiration_Date__c= Date.parse(pageParam.get('expDate'));
                System.debug('wrtyInfo.Warranty_Expiration_Date__c:::'+wrtyInfo.Warranty_Expiration_Date__c);
            }
            if(pageParam.get('bCode') != null && pageParam.get('bCode') != ''){
                wrtyInfo.Branded_Code__c= pageParam.get('bCode');
            }
            if(pageParam.get('expMiles') != null && pageParam.get('expMiles') != ''){
                wrtyInfo.Warranty_Expiration_Miles__c = decimal.valueOf(pageParam.get('expMiles'));
            }
            if(pageParam.get('modelYr') != null && pageParam.get('modelYr') != ''){
                wrtyInfo.Model_Year__c = pageParam.get('modelYr');
            }
            if(pageParam.get('wrtyRecType') != null && pageParam.get('wrtyRecType') != ''){
                wrtyInfo.WS_Warranty_Record_Type__c = pageParam.get('wrtyRecType');
            }
            if(pageParam.get('vehIdentNo') != null && pageParam.get('vehIdentNo') != ''){
                wrtyInfo.Vehicle_Identification_Number__c = pageParam.get('vehIdentNo');
            }
            if(pageParam.get('wrtyInfBusId') != null && pageParam.get('wrtyInfBusId') != ''){
                wrtyInfo.Warranty_Information_Business_ID__c = pageParam.get('wrtyInfBusId');
            }
            if(pageParam.get('wrtyExclCode') != null && pageParam.get('wrtyExclCode') != ''){
                wrtyInfo.Warranty_Exclusion_Code__c = pageParam.get('wrtyExclCode');
            }
            if(pageParam.get('wrtyExclName') != null && pageParam.get('wrtyExclName') != ''){
                wrtyInfo.Warranty_Exclusion_Name__c = pageParam.get('wrtyExclName');
            }
            if(pageParam.get('polkDt') != null && pageParam.get('polkDt') != ''){
                System.debug('Date::'+pageParam.get('polkDt'));
                wrtyInfo.Polk_Run_Date__c= Date.parse(pageParam.get('polkDt'));
                System.debug('wrtyInfo.Polk_Run_Date__c:::'+wrtyInfo.Polk_Run_Date__c);
            }
            if(pageParam.get('state') != null && pageParam.get('state') != ''){
                wrtyInfo.State_Code__c = pageParam.get('state');
            }
            
        }
        
    }
    
}