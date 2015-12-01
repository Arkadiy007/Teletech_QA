public with sharing class CaseCommentsExportController {

    public String selectedVal{get; set;}
    public List<SelectOption> recordTypevalues{get; set;}
    public Contact fromCont{get; set;}
    public Contact toCont{get; set;}
    public String commVerbage{get; set;}
    public String caseNumbers{get; set;}
    public boolean verbiageSearch{get;set;}
    
    Set<String> caseIds = new Set<String>();
    List<Case> cases; 
    
    
    public CaseCommentsExportController(){
       
        fromCont = new Contact();
        toCont = new Contact();   
        cases = new List<Case>();   
        verbiageSearch = false;   
         
        Map<String, Schema.RecordTypeInfo> rtInfosByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
        recordTypevalues = new List<SelectOption>();    
        
        for(String s : rtInfosByName.keyset()){
            if(!s.contains('Admin')){
            recordTypevalues.add(new SelectOption(rtInfosByName.get(s).getRecordTypeId(),s)); 
            }
                   
        }         
        
    }
    
    public PageReference submitJob(){
       caseIds.clear();
       cases.clear();
       
       try{
          if(!validateCriteria()){             
            Batch_CommentsExport_DataLoad commExport = new Batch_CommentsExport_DataLoad();
            commExport.jobName = 'Comment Export-'+Userinfo.getUserName() +'-'+ Datetime.now().format();  
            if(!verbiageSearch){
            commExport.query = getCaseSQL();
            }else{  
            selectedVal = selectedVal.replace('[','').replace(']','');     
            commExport.query = getSQL();
            commExport.verbiageFilter = commVerbage;
            commExport.dateRangeFilter = fromCont.BirthDate + ' - ' + toCont.BirthDate;
            commExport.recordTypeFilter = selectedVal; 
            }
            Id batchId = Database.executeBatch(commExport, 200);
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please export the Case Detail Comment once the Job with Id:'+batchId +' Completes for Comment Header Name as "'+ commExport.jobName+'"')); 
          } 
            
         }catch(Exception ex){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'An exception occured. Please contact your System Administrator'));               
         }
        
               
        return null;
    }
    
    
    public Boolean validateCriteria(){
       
       boolean isError = false; 
       
       if(verbiageSearch){        
           if(fromCont.BirthDate == null || toCont.BirthDate == null){
               isError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please enter date criteria.'));         
           }
           if(selectedVal == null || selectedVal == '[]'){
               isError = true;
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please select Record Types')); 
           }
           if(commVerbage == null || commVerbage == ''){
               isError = true;
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please enter Verbiage for Comments')); 
           }
       }else{       
           if(caseNumbers == null || caseNumbers == ''){               
               isError = true;
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please enter Case Numbers')); 
           }
       }
       
       return isError;
        
    }       
    
    
    public String getCaseSQL(){
    
       String sql = 'Select Id, LastModifiedById, CreatedById, CaseNumber, VIN__c, Type, Model_Year__c, Model_Line__c, Contact.Phone, Owner.Name, Origin, Contact.Name, '
       				+ 'CreatedDate, RecordType.Name, Contact.OtherState, Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, '
                    + 'Model_Code__c, Vehicle_Name__r.Latest_Recorded_Mileage_Number__c, Vehicle_Name__r.In_Service_Date__c, Vehicle_Name__r.Engine_4_Code__c, Vehicle_Name__r.M_F_Plant__c, Vehicle_Name__c, Manufacturer_Date__c, ClosedDate, '
                    + '(Select Id, ParentId, CommentBody, CreatedDate, LastModifiedDate From CaseComments) From Case Where CaseNumber IN ('+parseCaseNumbers(caseNumbers)+')';
       
       return sql;             
    }
    
    public String getSQL(){
    
       
        String sql = 'Select Id, LastModifiedById, CreatedById, CaseNumber, VIN__c, Type, Model_Year__c, Model_Line__c, Contact.Phone, Owner.Name, Origin, Contact.Name, '
        			 +'CreatedDate, RecordType.Name, Contact.OtherState, Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, '
                     + 'Model_Code__c, Vehicle_Name__r.Latest_Recorded_Mileage_Number__c, Vehicle_Name__r.In_Service_Date__c, Vehicle_Name__r.Engine_4_Code__c, Vehicle_Name__r.M_F_Plant__c, Vehicle_Name__c, Manufacturer_Date__c, ClosedDate, '
                    + '(Select Id, ParentId, CommentBody, CreatedDate, LastModifiedDate From CaseComments limit 190) From Case '
                    + 'WHERE CreatedDate >= '+formatDtTime(fromCont.BirthDate)+ ' AND CreatedDate <= '+formatDtTime(toCont.BirthDate);
        
        String recIds = '(';
                    
        if(selectedVal != null){
            selectedVal.trim();
            if(selectedVal.contains(',')){
                integer i = 0;
                for(String s : selectedVal.split(',')){
                    if(i == 0){
                    recIds += '\''+s.trim() +'\''; 
                    }else{
                        recIds += ',\''+s.trim() +'\'';
                    } 
                    
                    i++;                  
                }  
                         
            }else{            
                recIds += '\''+selectedVal+'\'';
            }
            
            recIds += ')';
            
            sql += ' AND RecordtypeId IN '+recIds;
            
        }
        
        System.debug('sql::'+sql);
        
        return sql;
    }
    
    private String parseCaseNumbers(String val) {
        String inClause = '';
        for (String s : val.contains(',') ? val.split(',') : new List<String>{val}) {
            inClause += '\''+s+'\',';
        }
        return inClause.substring(0,inClause.length()-1);
    }
    
    private String formatDtTime(Date d) { 
       Datetime dt = datetime.newInstance(d.year(), d.month(),d.day());
      
       return dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'', 'GMT'); 
    }
    
    public void checkCommentsVerbiage(){
        
        // do nothing        
    }
    
}