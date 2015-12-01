//VERSION AUTHOR DATE DETAIL 
//1.0 - William Taylor 1/13/2013 Created
//***********************************************************************/
global class OneTimeVehicleUpdateModelLine implements Database.Batchable<sObject> {


    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
     
        
        String query = 'Select Id, Vehicle_Identification_Number__c, ' +
        ' Model_Line_Series__c FROM Vehicle__c WHERE Model_Line_Series__c = NULL AND Model_Year__c != NULL LIMIT 200000';// 
        //' AND Id=\'a0GF000000D7VKUMA3\'';
        return Database.getQueryLocator(query);
    }
      
    global void execute(Database.BatchableContext BC, List<Vehicle__c> scope) {
         
        List<Code__c> modelLineSeriesList = [select Value__c, Description__c from Code__c where Type__c = 'MOD LINE/SERIES'];
        Map<String,String> modelLineSeries = new Map<String,String>();
        
        for(Code__c modelLine: modelLineSeriesList) {
            modelLineSeries.put(modelLine.Value__c, modelLine.Description__c);
        }
        
        
        for(Vehicle__c curVehicle : scope) {
            
            if (curVehicle.Vehicle_Identification_Number__c != null) {
                if (curVehicle.Vehicle_Identification_Number__c.length() >= 10) {
                    curVehicle.Model_Line_Series__c = modelLineSeries.get(curVehicle.Vehicle_Identification_Number__c.substring(3,8));
                }
            }
             
        }
         
       update scope; 
    }  
    global void sendMSG(String msg) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'wrmtyr@gmail.com'};  //a.CreatedBy.Email
      
        mail.setToAddresses(toAddresses);
        mail.setSubject('Techline Batch Case DataLoad Message');
        mail.setPlainTextBody(msg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }
    
    global void finish(Database.BatchableContext BC) {
          AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email, CompletedDate
          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
            if (a.TotalJobItems >= 1000) {
            // run again
            // continue processing
            OneTimeVehicleUpdateModelLine batchd = new OneTimeVehicleUpdateModelLine();
            Database.executeBatch(batchd); 
        } else {
           sendMSG('Vehicle update batch has completed fully.');
        }
    }
}