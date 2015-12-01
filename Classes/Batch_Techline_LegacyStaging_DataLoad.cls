/**********************************************************************
Name: Batch_Techline_LegacyStaging_DataLoad 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class loads Legacy Flagged Case table data into Stage_Case__c, Techline Recordtype
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Will Taylor    1/31/2014 Designed to just load stage case legacy data once
***********************************************************************/
global class Batch_Techline_LegacyStaging_DataLoad implements Database.Batchable<sObject> {
    // String of query for all creatable fields on Case
    global String query;

    private static final String DEFAULT_EMPTY_VALUE = 'NONE';
    private static final String DEFAULT_ZCA_ID = '12345678';
    
    public static String getQuery() {
        //Here was retrieving the 'Parts_Avail__c', 'Parts_Request_Date__c', 'Parts_Requestor__c', 'Parts_Shipped_Date__c', 'Parts_Received_Date__c' fields among the other fields in the returning query
        return 'SELECT (SELECT Id FROM Attachments), Description, Issue_Type__c, Mailing_Zip_Code__c,DocumentId__c,CaseNumber,DealerCode__c,Phone_Number__c,OwnerId,CreatedById,' +
        'Vehicle_Name__c,Model_Line__c,Model_Year__c,Case_External_Id__c,Model_Code__c,Current_Mileage__c,'+ 
        'Distributor_Code__c,In_Service_Date__c,Component_Code__c,Component_Code_Issue__c,Attachment_Indicator__c, ' + 
        'Symptom_Code__c,Symptom_Code_Issue__c,ClosedDate,Solution_Rating__c,AssignmentLevel__c,Caller_Name__c,'+
        'Critical_Status_Flag__c,Solution_Description__c,Report_Type__c,Customer_Name__c,'+
        'Response_Date__c,Project_Number__c,Incident_Date__c,Engine_Number__c,'+
        'Region_Code__c,Dealer_Code__c,ModelSeriesFromVehicle__c,'+
        'Revision_Number__c,Dealer_Could_Benefit_By__c,'+
        'Incident_Category__c,Operating_Mode__c,Operating_Temperature__c,'+
        'Ambient_Temperature__c,Ambient_Humidity__c,Frequency_of_Problem__c,'+
        'Product_Alert_Number__c,CreatedDate,LastModifiedDate,'+
        'Manufacturer_Date__c,Vehicle_Mileage_Prior_Value__c,TREAD_Component__c,'+
        'TREAD_Component_Prior_Value__c,TREAD_Effective_Date__c,Reason_For_Call__c,FFFS__c,'+
        'FFFS_Date__c,Field_Inspection_Indicator__c,Recommendation_Rating__c,'+
        'NNA_Field_Inspection_Date__c, Vehicle_Name__r.Vehicle_Identification_Number__c, Vehicle_Name__r.In_Service_Date__c, Vehicle_Name__r.Model_Line_Series__c, RecordType.Name, ' + 
        'Contact.Phone, Contact.Email, Contact.FirstName, Contact.LastName, Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.HomePhone, Contact.MobilePhone, Contact.OtherPhone, ' +
        'Owner.Name, Status, LastModifiedBy.Name '+
        'FROM Case WHERE  ' + 

                 '  RecordTypeId = \'012F0000000yFmQ\' '; // as this is onetime legacy load going to only query techline case recordtype
                  
                  
                  
                  
                  //Id=\'500Z0000007Ir8B\'
    }   
   
    // Start method using QueryLocator
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = getQuery();
       
        /* if (Test.isRunningTest()) {
            query = query + ' And Call_Recording_Id__c = \'ZYXABC\'';
         } else {
           // query = query + ' AND Case_External_Id__c IN (\'FI1103533\',\'FI1156691\',\'FI1146002\',\'FI1156693\') '; 
         }*/
          
        return Database.getQueryLocator(query);
    } 

    // Handle each batch of Case rows returned and insert corresponding records into Stage_Case
    global void execute(Database.BatchableContext BC, List<Case> lstCaseTable) {
        // Initialize variables and lists
       
       
        Stage_Case__c CaseStgRec;
        List<Stage_Case__c> lstCaseStg = new List<Stage_Case__c>(); 
        Map<Integer, Case> CaseInsMap = new Map<Integer, Case>();
        

        integer ins = 0;
        List<Error_Log__c> errors = new List<Error_Log__c>();
        Case doneCase;
        List<Case> updateCaseList = new List<Case>();
        Stage_Case_Detail__c dealerInstructions;
        List<Stage_Case_Detail__c> rootCauses;
        Map<Id, Stage_Case_Detail__c> commentHeaderMap = new Map<Id, Stage_Case_Detail__c>();
        Map<Id, Stage_Case_Detail__c> commentDealerInstructionsMap = new Map<Id, Stage_Case_Detail__c>();
        Map<Id, List<Stage_Case_Detail__c>> rootCausesMap = new Map<Id, List<Stage_Case_Detail__c>>();
        List<Stage_Case_Detail__c> commentList = new List<Stage_Case_Detail__c>();

        // Get all ZCA ids looked up from User records
        Map<String,User> users = new Map<String,User>([select Id, ZCA_Id__c, TSS_Code__c from User]);

        // Get all Model lines from Code__c records
        List<Code__c> modelLineList = new List<Code__c>([select Id, Type__c, Code__c, Description__c 
                                                         from Code__c
                                                         where Type__c = 'Model_Line']);
        Map<String,String> modelLines = new Map<String,String>();
        for(Code__c modelLine: modelLineList) {
            modelLines.put(modelLine.Description__c, modelLine.Code__c);
        }
    
        // Loop through all Cases returned
        for (Case CaseAll : lstCaseTable)
        {
            CaseStgRec = new Stage_Case__c();
            
            try {

                // send an Add action
                CaseStgRec.SFDC_Action_Code__c = System.Label.Stage_Action_Add;
                fillCaseStage(CaseStgRec, CaseAll, users, modelLines);
                    
                // Add Stage_Case record to the list to insert 
                lstCaseStg.add(CaseStgRec); 
                
                // Save the input Case to a numbered Map where the key of the Map is the
                // index of the Case in the original input.
                CaseInsMap.put(ins,CaseAll);    
                ins++;
            } catch (Exception err) {
                errors.add(new Error_Log__c(Record_ID__c = CaseAll.Id,
                                    Record_Type__c = 'Case', 
                                    Error_Message__c = err.getMessage() + ' line ' + err.getLineNumber(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_TechLineNewLegacy_CaseStaging_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
            }
        }
        
        // If any Stage_Case rows are in the list, insert them and handle any errors.
        if (!lstCaseStg.isEmpty())      //INSERT/UPDATE PROCESSED
        {   
            // Insert rows
            Database.SaveResult[] dbCStage = Database.insert(lstCaseStg, false);

            // If there are any results, handle the errors
            if (!dbCStage.isEmpty()) 
            {
                // Loop through results returned
                for (integer row = 0; row < lstCaseStg.size(); row++)
                {
                    // If the current row was not sucessful, handle the error.
                    if (!dbCStage[row].isSuccess())
                    {
                        // Get the error for this row and add it to a list of Error_Log rows.
                        Database.Error err = dbCStage[row].getErrors()[0];
                        errors.add(new Error_Log__c(Record_ID__c = (CaseInsMap.get(row)).Id,
                                    Record_Type__c = 'Stage_Case__c', 
                                    Error_Message__c = err.getMessage(), 
                                    TimeStamp__c = System.now(), 
                                    Operation_Name__c = 'Batch_TechlineNewLegacy_CaseStaging_DataLoad', 
                                    Source__c='Salesforce', 
                                    Log_Type__c = 'Error', 
                                    Log_Level__c = 1));
                    } else {
                        // If the current row was successful, set its status to Done Processing.

                        /*if (commentHeaderMap.containsKey((CaseInsMap.get(row)).Id)) {
                            commentList.add(commentHeaderMap.get((CaseInsMap.get(row)).Id));
                        }
                        if (commentDealerInstructionsMap.containsKey((CaseInsMap.get(row)).Id)) {
                            commentList.add(commentDealerInstructionsMap.get((CaseInsMap.get(row)).Id));
                        }
                        if(rootCausesMap.containsKey((CaseInsMap.get(row)).Id)) {
                            commentList.addAll(rootCausesMap.get((CaseInsMap.get(row)).Id));
                        }*/
                    }
                }
            }
        }

        // If any errors were returned, add them to the Error_Log table.
        if (!errors.isEmpty()) {
            // Insert rows
            Database.SaveResult[] dbResults = Database.insert(errors, false);
        }
    }

    public static void fillCaseStage(Stage_Case__c stage, Case c, Map<String,User> users, Map<String,String> modelLines) {
        
        User user = users.get(c.OwnerId);
        User lmod = users.get(c.LastModifiedById);
        
        String zcaId = user != null ? user.ZCA_Id__c : null;
        String tssId = user != null ? user.TSS_Code__c : null;
        String lmod_tssId = lmod != null ? lmod.TSS_Code__c : null;


        if (c.Attachments.size() > 0) {
            stage.Attachment_Indicator__c = 'Y';
            c.Attachment_Indicator__c = true;
        } else {
            stage.Attachment_Indicator__c = 'N';
            c.Attachment_Indicator__c = false;
        }    
        
        stage.Origination_Source__c = 'SFDC';
        stage.Origination_Type__c = 'TechlineNew';
        stage.Batch_Status__c = 'LEGACY';
        stage.Description__c = c.Description;
        //stage.Incident_Number__c = c.CaseNumber;
        
        if (c.Case_External_Id__c != null) {
            stage.Incident_Number__c = c.Case_External_Id__c;
        } else {
            stage.Incident_Number__c = c.CaseNumber;
        }
        stage.Customer_Name__c = c.Customer_Name__c;
        stage.DealerCode__c = c.DealerCode__c;
        
        if (String.valueOf(c.Phone_Number__c) == '' || c.Phone_Number__c == null) {
            stage.Phone_Number__c = '0';
        } else {
            //stage.Phone_Number__c = c.Phone_Number__c;
            Pattern nonDigits = Pattern.compile('[^0-9]');
            stage.Phone_Number__c = nonDigits.matcher(c.Phone_Number__c).replaceAll('');
        }


        
        stage.Vehicle_Name__c = c.VIN__c;
        stage.Model_Line__c = c.Vehicle_Name__r.Model_Line_Series__c;
        if (String.valueOf(c.Current_Mileage__c) == '' || c.Current_Mileage__c == null) {
            stage.Current_Mileage__c = '0';
        } else {
            stage.Current_Mileage__c = String.valueOf(c.Current_Mileage__c);
        }
        stage.Distributor_Code__c = c.Distributor_Code__c;
        stage.In_Service_Date__c = c.In_Service_Date__c != null ?  String.valueOf(c.In_Service_Date__c).replace('-','') : null;
        stage.Component_Code__c = c.Component_Code_Issue__c;
        stage.Symptom_Code__c = c.Symptom_Code_Issue__c;
        stage.Close_Date__c = c.ClosedDate != null ? String.valueOf(c.ClosedDate).replace('-','').substring(0,8) : null;
       // System.debug('William Taylor- Closed Date: ' + c.ClosedDate);
       // System.debug('William Taylor- Closed Date proc: ' + String.valueOf(c.ClosedDate).replace('-','').substring(0,8));

        stage.Open_Date__c = c.CreatedDate != null ? String.valueOf(c.CreatedDate).replace('-','').substring(0,8) : null;
        stage.CreatedDate__c = c.CreatedDate != null ? String.valueOf(c.CreatedDate).replace('-','').substring(0,8) : null;
        
        stage.Solution_Rating__c = c.Solution_Rating__c;
        stage.Assignment_Level__c = c.AssignmentLevel__c;
        stage.Critical_Status_Flag__c = c.Critical_Status_Flag__c != null ? String.valueOf(c.Critical_Status_Flag__c).replace('false','N').replace('true','Y') : 'N';  
        stage.Solution_Description__c = c.Solution_Description__c;
        stage.Report_Type__c = c.Report_Type__c;
        stage.Caller_Name__c = c.Caller_Name__c;
        stage.Response_Date__c = c.Response_Date__c != null ? String.valueOf(c.Response_Date__c).replace('-','') : null;
        stage.Project_Number__c = c.Project_Number__c;
        stage.Incident_Date__c = c.Incident_Date__c != null ? String.valueOf(c.Incident_Date__c).replace('-','') : null;
        stage.Region_Code__c = String.valueOf(c.Region_Code__c);
        stage.Retail_Dealer_Code__c = c.Dealer_Code__c;
        stage.ModelSeriesFromVehicle__c = c.ModelSeriesFromVehicle__c;
        //stage.Parts_Available_Indicator__c = c.Parts_Avail__c != null ? String.valueOf(c.Parts_Avail__c).replace('false','N').replace('true','Y') : 'N';
        //stage.Parts_Request_Date__c = c.Parts_Request_Date__c;
        //stage.Parts_Request_Date_Txt__c =  c.Parts_Request_Date__c != null ? String.valueOf(c.Parts_Request_Date__c).replace('-','') : null;
        //stage.Parts_Requestor__c = c.Parts_Requestor__c;
        //stage.Parts_Received_Date__c = c.Parts_Received_Date__c;
        //stage.Parts_Received_Date_Txt__c = c.Parts_Received_Date__c != null ? String.valueOf(c.Parts_Received_Date__c).replace('-','') : null;
        //stage.Parts_Shipped_Date__c = c.Parts_Shipped_Date__c != null ? String.valueOf(c.Parts_Shipped_Date__c).replace('-','') : null;
        stage.Revision_Number__c = String.valueOf(c.Revision_Number__c);
        stage.Dealer_Could_Benefit_By__c = c.Dealer_Could_Benefit_By__c;
        stage.Incident_Category__c = c.Incident_Category__c;
        stage.Operating_Mode__c = c.Operating_Mode__c;
        stage.Operating_Temperature__c = c.Operating_Temperature__c;
        stage.Ambient_Temperature__c = c.Ambient_Temperature__c;
        stage.Ambient_Humidity__c = c.Ambient_Humidity__c;
        stage.Frequency_of_Problem__c = c.Frequency_of_Problem__c;
        stage.Product_Alert_Number__c = c.Product_Alert_Number__c;
        stage.Vehicle_Mileage_Prior_Value__c = String.valueOf(c.Vehicle_Mileage_Prior_Value__c);
        stage.Last_Update_Date__c = String.valueOf(c.LastModifiedDate).replace('-','').substring(0,8);
        stage.Last_Modified_Date_Time__c = String.valueOf(c.LastModifiedDate).replace('-','').substring(0,8);
        stage.Report_Type__c = c.Issue_Type__c;
        stage.TREAD_Effective_Date__c = c.TREAD_Effective_Date__c!= null ? String.valueOf(c.TREAD_Effective_Date__c).replace('-','') : null;
        stage.Reason_for_Call_Code__c = c.Reason_For_Call__c;
        stage.FFFS__c = c.FFFS__c != null ? String.valueOf(c.FFFS__c).replace('false','N').replace('true','Y') : 'N';
        stage.FFFS_Date__c = c.FFFS_Date__c != null ? String.valueOf(c.FFFS_Date__c).replace('-','') : null;
        stage.Field_Inspection_Indicator__c = c.Field_Inspection_Indicator__c  != null ? String.valueOf(c.Field_Inspection_Indicator__c).replace('false','N').replace('true','Y') : 'N';
        stage.NNA_Field_Inspection_Date__c = c.NNA_Field_Inspection_Date__c != null ? String.valueOf(c.NNA_Field_Inspection_Date__c).replace('-','') : null;
        stage.TREAD_Component__c = c.TREAD_Component__c;
        stage.Case_Status__c = c.Status;
        
        if (tssId == null || tssId == '') {
           stage.STC_CODE_1__c = '0';
        } else {
           stage.STC_CODE_1__c = tssId + '|' + c.Owner.Name; 
        }
        if (lmod_tssId == null || lmod_tssId == '') {
            stage.STC_CODE_2__c = '0';
        } else {
            stage.STC_CODE_2__c = lmod_tssId + '|' + c.LastModifiedBy.Name;
        }
        
        
        //stage.STC_CODE_1__c = tssId + '|' + c.Owner.Name;
        //stage.STC_CODE_2__c = lmod_tssId + '|' + c.LastModifiedBy.Name;
        
        //stage.Vehicle_Maintained_Location__c = c.Vehicle_Maintained_Location__c != null ? c.Vehicle_Maintained_Location__c.toUpperCase() : 'NONE';
        //stage.Vehicle_Purchase_Type__c = c.VehiclePurchasedType__c == 'Pre-Owned' ? 'P' : 'N';
        //stage.Vehicle_Purchased_Miles__c = c.Vehicle_Purchased_Miles__c;
        //stage.Vehicles_Owned__c = c.Vehicles_Owned__c != null ? String.valueOf(c.Vehicles_Owned__c) : null;
        if (c.Vehicle_Name__c != null && c.Vehicle_Name__r.Vehicle_Identification_Number__c != null) { 
            stage.VIN__c = c.Vehicle_Name__r.Vehicle_Identification_Number__c;
            stage.Vehicle_Name__c = c.Vehicle_Name__r.Vehicle_Identification_Number__c;
        } else if (c.VIN__c != null) {
            stage.VIN__c = c.VIN__c;
            stage.Vehicle_Name__c = c.VIN__c;
        }
        if (stage.VIN__c == null || stage.VIN__c == '')
            stage.VIN__c = 'NONE';
        //stage.When_Plan_Purchase__c = c.When_Plan_Purchase__c;
        stage.ZIP__c = getNormalizedZipCode(c);


    }


  private static String getNormalizedZipCode(Case c) {
    String zip = null;
        if (c.Mailing_Zip_Code__c != null)
            zip = getNormalizedZipCode(c.Mailing_Zip_Code__c);
        
        if (zip == null && c.Contact.MailingPostalCode != null)
            zip = getNormalizedZipCode(c.Contact.MailingPostalCode);
            
        return zip;
  }
  
  private static String getNormalizedZipCode(String zip) {
    String outZip = '';
    String hex;
    
    // Convert each character to hex and create a new String with only numbers 0-9, all other
    // characters are stripped out.
    for (Integer zipChar = 0; zipChar < zip.length(); zipChar++) {
      hex = encodingUtil.convertToHex(Blob.valueOf(zip.substring(zipChar, zipChar + 1)));
      if (hex == '30' || hex == '31' || hex == '32' || hex == '33' || hex == '34' ||
            hex == '35' || hex == '36' || hex == '37' || hex == '38' || hex == '39') {
        outZip = outZip + zip.substring(zipChar, zipChar + 1);
      }
    }
    
    // Return a String of 9 numbers if possible, otherwise a String of 5 numbers, otherwise blank.
    if (outZip.length() > 9) {
      outZip = outZip.substring(0,9);
    } else if (outZip.length() != 9 && outZip.length() > 5) {
      outZip = outZip.substring(0,5);
    } else if (outZip.length() != 9 && outZip.length() != 5) {
      outZip = '';
    }
    
    return outZip;
  }
 
 
    // Empty finish method - nothing needed
    global void finish(Database.BatchableContext BC){

    }
}