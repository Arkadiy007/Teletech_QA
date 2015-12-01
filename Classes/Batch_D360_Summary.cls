/**********************************************************************
Name: Batch_D360_Summary
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This Class copies closed cases with the servicing dealer
account and inserts them into the Closed Dealer Case Summary
table for use in the D360 REST API.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr         02/25/2014 Created
***********************************************************************/

global class Batch_D360_Summary implements Database.Batchable<sObject>{

global final String Query;
                             
global Batch_D360_Summary(){
    
    String months = system.Label.D360Months; //Used to sepcify how many months are calculated
    Query = 'Select Id, ClosedDate, CaseNumber, CreatedDate, RecordType.Name, '+
                             'Status, Account.Name, VIN__c, Servicing_Dealer__c, Servicing_Dealer__r.Name, '+
                             'Servicing_Dealer__r.Dealer_Code__c, Servicing_Dealer__r.Make_Name__c, '+
                             'Servicing_Dealer__r.BillingCountry, Data_Net__c, Servicing_Dealer__r.Recordtype.Name, '+
                             'Servicing_Dealer__r.Dealer_Inactive_Indicator__c '+
                             'from Case where RecordType.Name in (\'CA Closed Case\',\'T5\') and '+
                             '(ClosedDate = Last_n_Months:'+months+' or ClosedDate = This_Month)';
}

global Database.QueryLocator start(Database.BatchableContext BC){return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC,List<Case> scope){
    
    //Set variables
    List<Code__c> salescodes = [Select Id from Code__c where Description__c in ('NSN DEALER SALES DEPT.','NSN DEALER FINANCE DEPT.', 'NSN DEALER ADVERTISING')];
    List<Code__c> servicecodes = [Select Id from Code__c where Description__c in ('NSN DEALER SERVICE DEPT.','NSN DEALER PARTS DEPT.')];
    List<Closed_Dealer_Case_Detail__c> casedetail4insert = new List<Closed_Dealer_Case_Detail__c>();
    List<Closed_Dealer_Case_Summary__c> summary4insert = new List<Closed_Dealer_Case_Summary__c>();
    List<Case> needsummary = new List<Case>();
    List<Account> needsummaryacct = new List<Account>();  
    List<Id> needsummaryId = new List<Id>();  
    List<Error_Log__c> errors = new List<Error_Log__c>();
    Map<string, string> existingseviceacct = new Map<string, string> {};
    Map<string, string> newserviceacct = new Map<string, string> {};
    String summaryid;
    String summaryid2;
    String serviceId;
        
    //Locate existing Dealers already in the CDCS table
    for(Closed_Dealer_Case_Summary__c cdcs : [select Id, Dealer_Id__c from Closed_Dealer_Case_Summary__c]){
        String cdcsid = cdcs.Id;
        existingseviceacct.put(cdcs.Dealer_Id__c, cdcsid);
    }
    
    //Create Detail records from cases with existing Dealers inthe CDCS table
    for(Case c : scope){
        if(c.Servicing_Dealer__r.BillingCountry != 'Canada' && 
           c.Servicing_Dealer__r.Recordtype.Name == 'Dealer' && 
           c.Servicing_Dealer__r.Dealer_Inactive_Indicator__c == false &&
           c.Servicing_Dealer__r.Make_Name__c != null){
    
        String cat;
        
        serviceId = c.Servicing_Dealer__c;
        
  
        if(existingseviceacct.containsKey(serviceId)){
       
        summaryId = existingseviceacct.get(c.Servicing_Dealer__c);
        
        
        Closed_Dealer_Case_Detail__c newdetail = new Closed_Dealer_Case_Detail__c(
            Case_Id__c = c.Id,
            Case_Closed_Date__c = date.valueOf(c.ClosedDate),
            Case_Number__c = c.CaseNumber,
            Case_Open_Date__c = c.CreatedDate,
            Case_Type__c = c.RecordType.Name,
            Closed_Dealer_Case_Summary__c = summaryid,
            Current_Status__c = c.Status,
            Customer_Name__c = c.Account.Name,
            VIN__c = c.VIN__c);
            
       for(Case_Categorization__c cc : [select Id, Category__c, Category__r.Description__c from Case_Categorization__c
                                        where Case__c = :c.Id and Case__r.Data_Net__c = true and
                                        (Category__c in :salescodes or Category__c in :servicecodes)]){
        
        Closed_Dealer_Case_Detail__c newdetail2 = new Closed_Dealer_Case_Detail__c(
            Case_Id__c = c.Id,
            Case_Closed_Date__c = date.valueOf(c.ClosedDate),
            Case_Number__c = c.CaseNumber,
            Case_Open_Date__c = c.CreatedDate,
            Case_Type__c = c.RecordType.Name,
            Closed_Dealer_Case_Summary__c = summaryid,
            Current_Status__c = c.Status,
            Customer_Name__c = c.Account.Name,
            VIN__c = c.VIN__c);
                                            
                                            
        if(cc.Category__r.Description__c == 'NSN DEALER SALES DEPT.' ||
            cc.Category__r.Description__c == 'NSN DEALER FINANCE DEPT.' ||
            cc.Category__r.Description__c == 'NSN DEALER ADVERTISING'){
            
            	newdetail2.Case_Category__c = 'sales';
                casedetail4insert.add(newdetail2);
            
            }
            
        if(cc.Category__r.Description__c == 'NSN DEALER SERVICE DEPT.' ||
           cc.Category__r.Description__c == 'NSN DEALER PARTS DEPT.'){
           
           		newdetail2.Case_Category__c = 'service';
           		casedetail4insert.add(newdetail2);
           }
                                            
        
        }    
        
        for(Check_Request__c cr : [select Id, GL_Value_Code__c from Check_Request__c where 
                                   GL_Value_Code__c != null and Case__c = :c.Id]){
        
        String glcode = cr.GL_Value_Code__c.toLowerCase();
                                       
        if(glcode.contains('buyback')){
         
         cat = 'buyback';
         
         	}                         
        }                                 
        
            if(cat == 'buyback' ){
                newdetail.Case_Category__c = cat;            
                casedetail4insert.add(newdetail);
            }
        
        }     
        //If Dealer is not in the CDCS table add them to the needsummary list
         else{
         needsummaryId.add(c.Servicing_Dealer__c);         
         needsummary.add(c);   
         }
        }
    
    }
    
    
    //For Dealers without an existing CDCS record
    if(needsummary.size() > 0){
        
        for(Account serviceacct : [select Id, Name, Dealer_Code__c, Make_Name__c from Account
                                    where Id in :needsummaryId]){
        
        Closed_Dealer_Case_Summary__c sum = new Closed_Dealer_Case_Summary__c(
            Dealer_Id__c = serviceacct.Id,
            Dealer_Name__c = serviceacct.Name,
            Dealer_Code__c = serviceacct.Dealer_Code__c,
            Dealer_Division__c = serviceacct.Make_Name__c);            
            
        summary4insert.add(sum);            
        
        }
        
        //Insert new Dealer record
        try{
            if(summary4insert.size()>0){
        		insert summary4insert;
            }
        }
     catch (Exception e){
            errors.add(new Error_Log__c(Error_Message__c = e.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_D360_Summary-InsertNewSummaries', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error'));
     }
        
        for(Closed_Dealer_Case_Summary__c cdcs : summary4insert){
        String cdcsid = cdcs.Id;
        newserviceacct.put(cdcs.Dealer_Id__c, cdcsid);
    }
        
        //For Detail record after the new Dealer record has been inserted
        for(Case c3 : needsummary){
        
        String cat;
        summaryid2 = newserviceacct.get(c3.Servicing_Dealer__c);
                                                 
         Closed_Dealer_Case_Detail__c newdetail = new Closed_Dealer_Case_Detail__c(
            Case_Id__c = c3.Id,
            Case_Closed_Date__c = date.valueOf(c3.ClosedDate),
            Case_Number__c = c3.CaseNumber,
            Case_Open_Date__c = c3.CreatedDate,
            Case_Type__c = c3.RecordType.Name,
            Closed_Dealer_Case_Summary__c = summaryId2,
            Current_Status__c = c3.Status,
            Customer_Name__c = c3.Account.Name,
            VIN__c = c3.VIN__c);
            
            for(Case_Categorization__c cc : [select Id, Category__c, Category__r.Description__c from Case_Categorization__c
                                             where Case__c = :c3.Id and Case__r.Data_Net__c = true and
                                             (Category__c in :salescodes or Category__c in :servicecodes)]){
        
        Closed_Dealer_Case_Detail__c newdetail3 = new Closed_Dealer_Case_Detail__c(
            Case_Id__c = c3.Id,
            Case_Closed_Date__c = date.valueOf(c3.ClosedDate),
            Case_Number__c = c3.CaseNumber,
            Case_Open_Date__c = c3.CreatedDate,
            Case_Type__c = c3.RecordType.Name,
            Closed_Dealer_Case_Summary__c = summaryid,
            Current_Status__c = c3.Status,
            Customer_Name__c = c3.Account.Name,
            VIN__c = c3.VIN__c);

        if(cc.Category__r.Description__c == 'NSN DEALER SALES DEPT.' ||
            cc.Category__r.Description__c == 'NSN DEALER FINANCE DEPT.' ||
            cc.Category__r.Description__c == 'NSN DEALER ADVERTISING'){
            
            newdetail3.Case_Category__c = 'sales';
                casedetail4insert.add(newdetail3);
            
            }
            
        if(cc.Category__r.Description__c == 'NSN DEALER SERVICE DEPT.' ||
           cc.Category__r.Description__c == 'NSN DEALER PARTS DEPT.'){
           
           newdetail3.Case_Category__c = 'service';
                casedetail4insert.add(newdetail3);
           
           }   
        
        }
        
        for(Check_Request__c cr : [select Id, GL_Value_Code__c from Check_Request__c where 
                                   GL_Value_Code__c != null and Case__c = :c3.Id]){
        
        String glcode = cr.GL_Value_Code__c.toLowerCase();
                                       
        if(glcode.contains('buyback')){
         
         cat = 'buyback';
         
         }                         
                                   
        }  
        
            if(cat == 'buyback'){
                newdetail.Case_Category__c = cat;            
                casedetail4insert.add(newdetail);
            }
        
        }
        
    }
    
    try{
        if(casedetail4insert.size()>0){
     		insert casedetail4insert;
        }
     }
     catch (Exception e){
            errors.add(new Error_Log__c(Error_Message__c = e.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_D360_Summary-InsertNewDetails', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error'));
     }
    
    if(errors.size()>0){
        insert errors;
    }

}
    
global void finish(Database.BatchableContext BC){

   id batchinstanceid = database.executeBatch(new Batch_D360_Calc());

}

}