public class FutureUtil {
        
       @future public static void insertErrorRecord(String errorMessage, String source) {
           List<Error_log__c> errors = new List<Error_Log__c>();
           
                errors.add(new Error_Log__c(Record_Type__c = source, 
                                        Error_Message__c = errorMessage, 
                                        TimeStamp__c = System.now(), 
                                        Operation_Name__c = source + ' operation', 
                                        Source__c='Salesforce', 
                                        Log_Type__c = 'Error', 
                                        Log_Level__c = 1));
               insert errors;
               
        }

    }