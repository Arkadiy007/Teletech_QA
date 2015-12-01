/**********************************************************************
Name: Batch_Techline_New_Comments_DataLoad
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads Techline onetimedata comments into the  case comments 
object
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - William Taylor 2/3/2013 Created
***********************************************************************/
global class Batch_Techline_New_Comments_DataLoad implements Database.Batchable<sObject> {
 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String WClause = '';
        if (Test.isRunningTest()) {
            WClause = WClause + ' Case_ID__c=\'F1999999\' ';
        } else {
         //   WClause = WClause + ' Case_ID__c in (\'FI1152874\',\'FI1207343\',\'FI1285183\') ';   //    Id=\'a1iZ00000003rNfIAI\'   // test id                    
        }        
        String query = BuildSoqlUtil.getCreatableFieldsSOQL('OneTimeTechlineCommentsLoad__c', WClause); 
        return Database.getQueryLocator(query);
    } 

    global void execute(Database.BatchableContext BC, List<OneTimeTechlineCommentsLoad__c> lstCommentsTable) {
        System.debug('Will Taylor - in the execute phase in comments');
                
       List<Error_Log__c> errors = new List<Error_Log__c>();
       
       CaseComment newCaseComment;
        List<CaseComment> lstCaseCommentInsert = new List<CaseComment>();   
            
        List<String> theseCases = new List<String>();
        
        for (OneTimeTechlineCommentsLoad__c stage: lstCommentsTable) { 
            theseCases.add(stage.Case_ID__c);
        }
        
        System.debug('Will Taylor - about to run case query ');
        
        List<Case> caseList = [select Id, Case_External_Id__c FROM Case WHERE RecordType.Name='TECH LINE Cases' AND Bonus_Cash_Code__c='99' AND Case_External_Id__c IN :theseCases];
        Map<String,String> parentCaseMap = new Map<String,String>();
        
        for(Case thisCase:  caseList) {
            parentCaseMap.put(thisCase.Case_External_Id__c, thisCase.Id);
        }

       List<User> userTSSList = [select Id, TSS_Code__c FROM User];
       Map<String,String> userTSSMap = new Map<String,String>();
        for(User thisuserTSS:  userTSSList) {
            userTSSMap.put(thisuserTSS.TSS_Code__c, thisuserTSS.Id);
        }




        for (OneTimeTechlineCommentsLoad__c stage : lstCommentsTable)
        {
            try {

                if (parentCaseMap.get(stage.Case_ID__c) != null) {

                          if (stage.Comment_Body__c.length() >= 4000) {
                               String thisChunk = '';
                               String remainderString = stage.Comment_Body__c; 
                               while (remainderString.length() > 0) {
                                    thisChunk = remainderString.left(3999);
                                  
                                    // add chunk comment
                                    newCaseComment = new CaseComment();
                                    newCaseComment.CreatedDate = dateParse(stage.DateTime__c);  
                                    newCaseComment.parentId = parentCaseMap.get(stage.Case_ID__c);
                                    newCaseComment.CommentBody = thisChunk;
            
                                    if (userTSSMap.get(stage.ZCA_ID__c.substring(0,3)) != null) {
                                         newCaseComment.CreatedById = userTSSMap.get(stage.ZCA_ID__c.substring(0,3));
                                    } else {
                                        // newCase.OwnerId = '00GZ0000001F0pY';
                                    }
                                      
                                    lstCaseCommentInsert.add(newCaseComment);
                                    System.debug('WIll Taylor:  parent id: ' + parentCaseMap.get(stage.Case_ID__c));
                                    System.debug('Will Taylor comment:  this chunk: ' + thisChunk);
                                    
                                    remainderString = remainderString.removeStart(thisChunk);
                               }
                                                         
                         } else {

                            newCaseComment = new CaseComment(); 
                            newCaseComment.CreatedDate = dateParse(stage.DateTime__c);  
                            newCaseComment.parentId = parentCaseMap.get(stage.Case_ID__c);
                            newCaseComment.CommentBody = stage.Comment_Body__c;
                            if (stage.ZCA_ID__c != null) {
                                if (userTSSMap.get(stage.ZCA_ID__c.substring(0,3)) != null) {
                                     newCaseComment.CreatedById = userTSSMap.get(stage.ZCA_ID__c.substring(0,3));
                                } else {
                                     newCaseComment.CreatedById = '005F0000001zSCS';
                                }  
                            } else {
                                newCaseComment.CreatedById = '005F0000001zSCS';
                            }
                                
                            lstCaseCommentInsert.add(newCaseComment);
                     
                     }
                     
                 
                 
                    
                }
                
                
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = stage.Id,
                                    Record_Type__c = 'OneTimeTechlineCommentsLoad__c', 
                                    Error_Message__c = err.getMessage() + 'Line: ' + err.getLineNumber(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_TechlineNewComments_Dataload', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }
        }

        // Create new Vehicle__c objects for any Vehicles in the list that do not already exist.  These will
        // then be linked automatically to the Cases when they are inserted.
      
        // Insert Cases
        if (lstCaseCommentInsert.size() > 0) {
            Schema.SObjectField parentIdCaseCommentField = CaseComment.Fields.ParentId;
            
            
            
             //Database.UpsertResult[] lstCSIns = Database.upsert(lstCaseCommentInsert, parentIdCaseCommentField, false);
             Database.SaveResult[] lstCSIns = Database.insert(lstCaseCommentInsert, false);
           
            if (lstCSIns.size() > 0) {
                
                for (integer x = 0; x < lstCaseCommentInsert.size(); x++) {
                   
                   // CStageIns = CaseStagingInsMap.get(x);
                    if (lstCSIns[x].isSuccess()) {
                        System.debug('Will Taylor - Successful DML operation');
                        
                        //CStageIns.Successful__c = 'Y';
                    } else {           
                        
                        //CStageIns.Successful__c = 'N';
                        Database.Error err = lstCSIns[x].getErrors()[0];
                       // CStageIns.Error_Message__c = err.getMessage();      
                        System.debug('Will Taylor - FAILED DML operation' +err.getMessage() );                        
                    }
                     
   
                }
            }
        } else {
            
        }

        // If any errors were returned, add them to the Error_Log table.
        if (!errors.isEmpty()) {
            // Insert rows
            Database.SaveResult[] dbResults = Database.insert(errors, false);
        }
    }


    global void finish(Database.BatchableContext BC){

     // Get the ID of the AsyncApexJob representing this batch job  
        // from Database.BatchableContext.    
        // Query the AsyncApexJob object to retrieve the current job's information. 
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email, CompletedDate
          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion. 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'wrmtyr@gmail.com'};  //a.CreatedBy.Email
      
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Case DataLoad ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
    
    
    }
    

   private Date dateParse(String inDate) {
        if (inDate == null || inDate.length() < 8) {
            return null;
        } else {
            String thisYear = inDate.substring(0,4);
            String thisMonth = inDate.substring(4,6);
            String thisDay = inDate.substring(6,8);
            return Date.parse(thisMonth  + '/' + thisDay  + '/' + thisYear  );
        }
    }

    
    
}