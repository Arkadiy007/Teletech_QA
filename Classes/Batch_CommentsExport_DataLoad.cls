/***********************************************************************/
global class Batch_CommentsExport_DataLoad implements Database.Batchable<sObject> {
    // String of query for all creatable fields on Case
    global String query;
    global String jobName;
    global string verbiageFilter;
    global string dateRangeFilter;
    global string recordTypeFilter;
    
       
     // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        //query = getQuery();
        
        return Database.getQueryLocator(query);
    } 
    
      // Handle each batch of Case rows returned and insert corresponding records into Case Comment Header and Case Comment Detail
    global void execute(Database.BatchableContext BC, List<Case> lstCaseTable) {
        
        List<Case_Comment_Detail__c> detailList = new List<Case_Comment_Detail__c>(); 
        Case_Comment_Detail__c commDetail;
        Map<String, Case_Comment_Header__c> caseHeadermap = new Map<String, Case_Comment_Header__c>();
        Case_Comment_Header__c commHeader;
        List<Case_Comment_Header__c> commHeaderList = new List<Case_Comment_Header__c>();
        Map<String, Case> casMap = new Map<String, Case>();
        Map<String, List<CaseComment>> caswithCommMap = new Map<String, List<CaseComment>>();
        
        if(verbiageFilter == null && dateRangeFilter == null){
        	for(Case c : lstCaseTable){
        		if(c.CaseComments.size() > 0){
	        		commHeader = new Case_Comment_Header__c(Name = jobName, Case_Created_Date__c = c.CreatedDate, Case_Number__c = c.CaseNumber,
	        					 Engine_Code_4__c = c.Vehicle_Name__r.Engine_4_Code__c, Latest_Recorded_Mileage__c = c.Vehicle_Name__r.Latest_Recorded_Mileage_Number__c, Manufacturer_Date__c = c.Manufacturer_Date__c, 
	        					 Vehicle_In_Service_Date__c= c.Vehicle_Name__r.In_Service_Date__c , Vehicle_Plant_Name__c = c.Vehicle_Name__r.M_F_Plant__c, Model_Code__c = c.Model_Code__c,
	                             Case_Record_Type__c = c.RecordType.Name, Contact_State__c = c.Contact.MailingState, Model_Line__c = c.Model_Line__c,
	                             Model_Year__c = c.Model_Year__c, Type__c = c.Type, VIN__c = c.VIN__c);
	        		
	        		caseHeadermap.put(c.Id, commHeader);
        		
        		}
        	}
        	
        	if(caseHeadermap.size() > 0){
        		Database.insert(caseHeadermap.values(), false); 
        		
        		for(Case cCom : lstCaseTable){
        			if(caseHeadermap.get(cCom.Id) != null){
		        		for(CaseComment casCom : cCom.CaseComments){
		                 commDetail = new Case_Comment_Detail__c(Comment_Body__c = casCom.CommentBody, Comment_Created_Date__c = casCom.CreatedDate, Related_Case__c = caseHeadermap.get(cCom.Id).Id);                
		                 detailList.add(commDetail); 
		             	}
        			}
        		}
        	}
        	
        }else{
        	
        	for(Case c : lstCaseTable){
        		casMap.put(c.Id, c);
        		caswithCommMap.put(c.Id, c.CaseComments);
        	}
        
	        Set<String> caseIds = checkComments(casMap, caswithCommMap, caseHeadermap);
	        
	        if(caseHeadermap.keyset().size() > 0){            
	          Database.insert(caseHeadermap.values(), false);  
	          
	         for(Case c : lstCaseTable){
	           if(caseHeadermap.containsKey(c.Id) && caseHeadermap.get(c.Id) != null){
	             Case_Comment_Header__c com = caseHeadermap.get(c.Id);
	             for(CaseComment casCom : c.CaseComments){
	                 commDetail = new Case_Comment_Detail__c(Comment_Body__c = casCom.CommentBody, Comment_Created_Date__c = casCom.CreatedDate, Related_Case__c = com.Id);                
	                 detailList.add(commDetail); 
	             }
	           }
	         }
	        }
        }
        
        if(detailList.size() > 0){        
            Database.insert(detailList, true);  
            System.debug('detailList:::'+detailList);      
        }
        
        
    }
    
    global void finish(Database.BatchableContext BC){
    
      AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                               TotalJobItems, CreatedBy.Email, CompletedDate
                        FROM AsyncApexJob WHERE Id = :BC.getJobId()];
     
      User usr = [Select Id, Email, Name from User where Id=: userinfo.getUserId()];
      
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddresses = new String[]{};  //a.CreatedBy.Email
      toAddresses.add(usr.Email);
        for(String s : Label.CommentsExportEmail.split(';')){
            if(s != usr.Email){
                toAddresses.add(s);
            }
        }  
        mail.setToAddresses(toAddresses);
        mail.setSubject('Comments Export Job done, ' + a.Status);
        mail.setPlainTextBody('The batch Apex job for Job Name: "'+jobName+'" processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
     
    }
    
    
    private Set<String> checkComments(Map<String, Case> mapCases, Map<String, List<CaseComment>> mapCaseWithComments, Map<String, Case_Comment_Header__c> caseHeadermap){
       
       Set<String> casIds= new Set<String>();
       Set<String> cVerbSet = new Set<String>();
       Case_Comment_Header__c commHeader;
       
             
       if(verbiageFilter.contains(',')){
           for(String s : verbiageFilter.split(',')){
               cVerbSet.add(s);
           }
       }else{
           cVerbSet.add(verbiageFilter);
       }
       
       for(Case cas : mapCases.values()){
       	 System.debug('caseList::'+mapCaseWithComments.get(cas.Id)); 
           if(mapCaseWithComments.get(cas.Id).size() > 0){ 
           for(String comnt : cVerbSet){          
               for(CaseComment cCom : mapCaseWithComments.get(cas.Id)){                   
                   if(cCom.CommentBody != null){                       
                      if(cCom.CommentBody.containsIgnoreCase(comnt)){
                       casIds.add(cas.Id);
                       
                       commHeader = new Case_Comment_Header__c(Name = jobName, Case_Created_Date__c = cas.CreatedDate, Case_Number__c = cas.CaseNumber,
                             Engine_Code_4__c = cas.Vehicle_Name__r.Engine_4_Code__c, Latest_Recorded_Mileage__c = cas.Vehicle_Name__r.Latest_Recorded_Mileage_Number__c, Manufacturer_Date__c = cas.Manufacturer_Date__c, 
	        				 Vehicle_In_Service_Date__c= cas.Vehicle_Name__r.In_Service_Date__c , Vehicle_Plant_Name__c = cas.Vehicle_Name__r.M_F_Plant__c, Model_Code__c = cas.Model_Code__c,
                             Case_Record_Type__c = cas.RecordType.Name, Contact_State__c = cas.Contact.MailingState, Model_Line__c = cas.Model_Line__c,
                             Model_Year__c = cas.Model_Year__c, Type__c = cas.Type, VIN__c = cas.VIN__c, Date_Range_Filter__c = dateRangeFilter,
                             Record_Type_Filter__c = recordTypeFilter, Verbiage_Filter__c = verbiageFilter); 
           
                       
                       caseHeadermap.put(cas.Id, commHeader);
                       break;
                     }
                   }  
                }
             }           
           }       
       }
       
       return casIds;        
        
    }
}