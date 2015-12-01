/**********************************************************************
Name: Batch_D360_Calc
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This Class calculates the number of Detail records by
month and category and updates the Delaer record.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr         02/26/2014 Created
***********************************************************************/
global class Batch_D360_Calc implements Database.Batchable<sObject>{

global final String Query;
                             
global Batch_D360_Calc(){
    
    Query = 'Select Id, Sales_Count_Current_Month__c, Sales_Count_Month_1__c, Sales_Count_Month_2__c, '+
            'Sales_Count_Month_3__c, Sales_Count_Month_4__c, Sales_Count_Month_5__c, Sales_Count_Month_6__c, '+
            'Sales_Count_Month_7__c, Sales_Count_Month_8__c, Sales_Count_Month_9__c, Sales_Count_Month_10__c, '+
            'Sales_Count_Month_11__c, Sales_Count_Month_12__c, Service_Count_Current_Month__c, Service_Count_Month_1__c, '+
            'Service_Count_Month_2__c, Service_Count_Month_3__c, Service_Count_Month_4__c, Service_Count_Month_5__c, '+
            'Service_Count_Month_6__c, Service_Count_Month_7__c, Service_Count_Month_8__c, Service_Count_Month_9__c, '+
            'Service_Count_Month_10__c, Service_Count_Month_11__c, Service_Count_Month_12__c, Buyback_Count_Current_Month__c, '+
            'Buyback_Count_Month_1__c, Buyback_Count_Month_2__c, Buyback_Count_Month_3__c, Buyback_Count_Month_4__c, '+
            'Buyback_Count_Month_5__c, Buyback_Count_Month_6__c, Buyback_Count_Month_7__c, Buyback_Count_Month_8__c, '+
            'Buyback_Count_Month_9__c, Buyback_Count_Month_10__c, Buyback_Count_Month_11__c, Buyback_Count_Month_12__c '+
            'from Closed_Dealer_Case_Summary__c';
}

global Database.QueryLocator start(Database.BatchableContext BC){return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC,List<Closed_Dealer_Case_Summary__c> scope){

    List<Closed_Dealer_Case_Summary__c> updatesummaries = new list<Closed_Dealer_Case_Summary__c>();
    List<Closed_Dealer_Case_Detail__c> details = new list<Closed_Dealer_Case_Detail__c>();
    List<Closed_Dealer_Case_Detail__c> deletedetails = new list<Closed_Dealer_Case_Detail__c>();
    List<Error_Log__c> errors = new List<Error_Log__c>();
    
    Date firstofcm = system.today().toStartOfMonth();
    Date lastbatchmonth = firstofcm.addMonths(-12);
    
    for(Closed_Dealer_Case_Summary__c cdcs : scope){
      //Set Variables  
        Decimal salescurrmonth = 0;
        Decimal salesmonth1 = 0;
        Decimal salesmonth2 = 0;
        Decimal salesmonth3 = 0;
        Decimal salesmonth4 = 0;
        Decimal salesmonth5 = 0;
        Decimal salesmonth6 = 0;
        Decimal salesmonth7 = 0;
        Decimal salesmonth8 = 0;
        Decimal salesmonth9 = 0;
        Decimal salesmonth10 = 0;
        Decimal salesmonth11 = 0;
        Decimal salesmonth12 = 0;
        
        Decimal servicecurrmonth = 0;
        Decimal servicemonth1 = 0;
        Decimal servicemonth2 = 0;
        Decimal servicemonth3 = 0;
        Decimal servicemonth4 = 0;
        Decimal servicemonth5 = 0;
        Decimal servicemonth6 = 0;
        Decimal servicemonth7 = 0;
        Decimal servicemonth8 = 0;
        Decimal servicemonth9 = 0;
        Decimal servicemonth10 = 0;
        Decimal servicemonth11 = 0;
        Decimal servicemonth12 = 0;
        
        Decimal bbcurrmonth = 0;
        Decimal bbmonth1 = 0;
        Decimal bbmonth2 = 0;
        Decimal bbmonth3 = 0;
        Decimal bbmonth4 = 0;
        Decimal bbmonth5 = 0;
        Decimal bbmonth6 = 0;
        Decimal bbmonth7 = 0;
        Decimal bbmonth8 = 0;
        Decimal bbmonth9 = 0;
        Decimal bbmonth10 = 0;
        Decimal bbmonth11 = 0;
        Decimal bbmonth12 = 0;
               
        for(Closed_Dealer_Case_Detail__c cdcd : [select Id, Case_Closed_Date__c, Case_Category__c,
                                                 Closed_Dealer_Case_Summary__c, Buyback_Case__c 
                                                 from Closed_Dealer_Case_Detail__c
                                                 where Closed_Dealer_Case_Summary__c = :cdcs.Id]){
                                                            
        try{
        Date closedatemonth = cdcd.Case_Closed_Date__c.toStartOfMonth();
      
        
                if(cdcd.Case_Closed_Date__c < lastbatchmonth){
                 deletedetails.add(cdcd);
        }      
            
        if(cdcd.Case_Category__c == 'sales'){        
            if(closedatemonth == firstofcm){salescurrmonth += 1;}
            if(closedatemonth == firstofcm.AddMonths(-1)){salesmonth1 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-2)){salesmonth2 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-3)){salesmonth3 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-4)){salesmonth4 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-5)){salesmonth5 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-6)){salesmonth6 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-7)){salesmonth7 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-8)){salesmonth8 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-9)){salesmonth9 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-10)){salesmonth10 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-11)){salesmonth11 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-12)){salesmonth12 += 1;}
        }
        
        if(cdcd.Case_Category__c == 'service'){        
            if(closedatemonth == firstofcm){servicecurrmonth += 1;}
            if(closedatemonth == firstofcm.AddMonths(-1)){servicemonth1 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-2)){servicemonth2 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-3)){servicemonth3 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-4)){servicemonth4 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-5)){servicemonth5 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-6)){servicemonth6 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-7)){servicemonth7 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-8)){servicemonth8 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-9)){servicemonth9 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-10)){servicemonth10 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-11)){servicemonth11 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-12)){servicemonth12 += 1;}
        }
        
        if(cdcd.Case_Category__c == 'buyback'){        
            if(closedatemonth == firstofcm){bbcurrmonth += 1;}
            if(closedatemonth == firstofcm.AddMonths(-1)){bbmonth1 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-2)){bbmonth2 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-3)){bbmonth3 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-4)){bbmonth4 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-5)){bbmonth5 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-6)){bbmonth6 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-7)){bbmonth7 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-8)){bbmonth8 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-9)){bbmonth9 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-10)){bbmonth10 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-11)){bbmonth11 += 1;}
            if(closedatemonth == firstofcm.AddMonths(-12)){bbmonth12 += 1;}
        }
            
    
       }  
      Catch (Exception e){            
             errors.add(new Error_Log__c(Record_ID__c = cdcd.Id,
                                    Error_Message__c = e.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_D360_Calc', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error'));                                            
        }
         
         
         }
    
        cdcs.Sales_Count_Current_Month__c = salescurrmonth;
        cdcs.Sales_Count_Month_1__c = salesmonth1;    
        cdcs.Sales_Count_Month_2__c = salesmonth2;
        cdcs.Sales_Count_Month_3__c = salesmonth3;
        cdcs.Sales_Count_Month_4__c = salesmonth4;
        cdcs.Sales_Count_Month_5__c = salesmonth5;
        cdcs.Sales_Count_Month_6__c = salesmonth6;
        cdcs.Sales_Count_Month_7__c = salesmonth7;
        cdcs.Sales_Count_Month_8__c = salesmonth8;
        cdcs.Sales_Count_Month_9__c = salesmonth9;
        cdcs.Sales_Count_Month_10__c = salesmonth10;
        cdcs.Sales_Count_Month_11__c = salesmonth11;
        cdcs.Sales_Count_Month_12__c = salesmonth12;
        
        cdcs.Service_Count_Current_Month__c = servicecurrmonth;
        cdcs.Service_Count_Month_1__c = servicemonth1;
        cdcs.Service_Count_Month_2__c = servicemonth2;
        cdcs.Service_Count_Month_3__c = servicemonth3;
        cdcs.Service_Count_Month_4__c = servicemonth4;
        cdcs.Service_Count_Month_5__c = servicemonth5;
        cdcs.Service_Count_Month_6__c = servicemonth6;
        cdcs.Service_Count_Month_7__c = servicemonth7;
        cdcs.Service_Count_Month_8__c = servicemonth8;
        cdcs.Service_Count_Month_9__c = servicemonth9;
        cdcs.Service_Count_Month_10__c = servicemonth10;
        cdcs.Service_Count_Month_11__c = servicemonth11;
        cdcs.Service_Count_Month_12__c = servicemonth12;
        
        cdcs.Buyback_Count_Current_Month__c = bbcurrmonth;
        cdcs.Buyback_Count_Month_1__c = bbmonth1;
        cdcs.Buyback_Count_Month_2__c = bbmonth2;
        cdcs.Buyback_Count_Month_3__c = bbmonth3;
        cdcs.Buyback_Count_Month_4__c = bbmonth4;
        cdcs.Buyback_Count_Month_5__c = bbmonth5;
        cdcs.Buyback_Count_Month_6__c = bbmonth6;
        cdcs.Buyback_Count_Month_7__c = bbmonth7;
        cdcs.Buyback_Count_Month_8__c = bbmonth8;
        cdcs.Buyback_Count_Month_9__c = bbmonth9;
        cdcs.Buyback_Count_Month_10__c = bbmonth10;
        cdcs.Buyback_Count_Month_11__c = bbmonth11;
        cdcs.Buyback_Count_Month_12__c = bbmonth12;
        
        updatesummaries.add(cdcs);
    }
    
    try{
 
    update updatesummaries;
    delete deletedetails;
    
    }
    catch (Exception e){
        errors.add(new Error_Log__c(Error_Message__c = e.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_D360_Calc-Update-Delete', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error'));
 
 }
    
    if(errors.size()>0){
        insert errors;
    }
}
    
global void finish(Database.BatchableContext BC){}

}