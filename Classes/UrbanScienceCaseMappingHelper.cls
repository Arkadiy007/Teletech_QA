public class UrbanScienceCaseMappingHelper {
    //--------------------------------------------------------------------------
    // Exceptions
    public class ValidationException extends Exception { }
    public static Boolean isConsent {get; set;}
    //--------------------------------------------------------------------------
    // Methods
    public static String generateAdfXMLFromCase(Case sourceCase) {
        // query mapping depending on Case RecordType
        List <USW_Case_Mappings__c > mappings = getMappings(sourceCase.RecordType.DeveloperName);

        // build map
        Map <String, String > request = mapCaseToIntermediateMap(sourceCase, mappings);

        // validate case
        isConsent = false;
        Boolean isValid = validateCase(sourceCase, request, mappings);

        if (false == isValid && !isConsent) {
            throw new ValidationException(Label.Dealer_Search_Controller_Case_Validation);
        }
        else if(isConsent){
            return '';
        }

        return buildXML(request, sourceCase);
    }

    public static Map <String, String > mapCaseToIntermediateMap(Case source, List <USW_Case_Mappings__c > mappings) {
        // map where key - US field, value - associated SF field value
        Map <String, String > request = new Map <String, String > ();

        // get related Call objects
        Call__c[] calls = source.Calls__r;
        if (!calls.isEmpty()) {
            request.put('notes', isCallsWithValidTypesAvailable(calls, source));
        }

        if (!mappings.isEmpty()) {
            // get describe for intermediate sObject
            Map <String, DescribeFieldResult > caseDescription = getFieldsMap(Case.SObjectType);

            // generate map
            for (USW_Case_Mappings__c mapping : mappings) {
                String sourceField = mapping.SF_Field_Name__c;
                String targetFeild = mapping.US_Field_Name__c;

        if (!isEmpty(sourceField) && !IsEmpty(targetFeild)) {
                  String convertedValue;
                  // if source field contains value(not field api name)
                  if (sourceField.startsWith('"')) {
                      convertedValue = sourceField.substringBetween('"');
                  } else {
                      // if source contains info about api name, we need iterate of all reference objects
                      SObject sourceSo = source;
                      List <String > referenceObjects = sourceField.split('\\.');
                      Integer N = referenceObjects.size();
                      for (Integer i = 0; i <N - 1; i++) {
                          if (null != sourceSo) {
                              sourceSo = sourceSo.getSObject(referenceObjects[i]);
                          }
                      }

                      if (null == sourceSo) {
                          convertedValue = '';
                      } else {
                          convertedValue = convertValue(caseDescription.get(sourceField), sourceSo.get(referenceObjects[N - 1]));
                      }
                  }

                  request.put(targetFeild, convertedValue);
        }
            }
        }

        return request;
    }

    public static String buildXML(Map <String, String > requestFields, Case sourceCase) {
    String business_unit = getValueFromMap(requestFields, 'vehicle_make');
    String source = getSource(business_unit);

    // parse model, to remove the make from it
    String vehicle_year = getValueFromMap(requestFields, 'vehicle_year');
    String vehicle_make = getValueFromMap(requestFields, 'vehicle_make');
    String vehicle_model = getValueFromMap(requestFields, 'vehicle_model');
    
    if(sourceCase.Origin == 'Chat' && sourceCase.RecordTypeId == RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'IB Case')){
        Pre_Chat_Data__c chatData = getPrechatIfAvailable(sourceCase);
        if(chatData != null){
            vehicle_model = chatData.Model__c;
            vehicle_year = chatData.Year__c;
            vehicle_make = chatData.Make__c;
            business_unit = chatData.Make__c;
            source = getSource(business_unit);

            if(String.isEmpty(vehicle_year)){
                vehicle_year = '';
            }
        }
        else{
            vehicle_model = '';
            vehicle_year = '';
            vehicle_make = '';
        }
    }

    vehicle_model = vehicle_model.toUpperCase();
    vehicle_year = vehicle_year.toUpperCase();
    vehicle_make = vehicle_make.toUpperCase();

    vehicle_model = vehicle_model.replace(vehicle_make, '');
    vehicle_model = vehicle_model.replace(vehicle_year, '');
    vehicle_model = vehicle_model.trim();
    if(sourceCase.Origin != 'Chat'  && sourceCase.RecordTypeId != RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'IB Case')){
        vehicle_model = getVehicle_ModelForIBCase(vehicle_model, sourceCase);
    }
    
    // split Account Name on First And Secondary name
    String contact_name = getValueFromMap(requestFields, 'contact_fullname');
    String contactFirstName='', contactLastName='';
    if ('' != contact_name) {
      Integer firstSpaceIndex = contact_name.indexOf(' ');
      contactFirstName = contact_name.left(firstSpaceIndex).trim();
      contactLastName = contact_name.right(contact_name.length() - firstSpaceIndex).trim();
    }

    // get only one email
    String contact_email = getValueFromMap(requestFields, 'contact_email');
    String contact_alternate_email = getValueFromMap(requestFields, 'contact_alternate_email');
    String contactEmail = (contact_email == '') ? contact_alternate_email : contact_email;

    // phone informations
        String[] phonesList = getPhonesList(
            getValueFromMap(requestFields, 'contact_home_phone'), 
            getValueFromMap(requestFields, 'contact_work_phone'),
            getValueFromMap(requestFields, 'contact_mobile_phone')
        );

        String xmlStr = '<adf>';
        xmlStr += '<prospect>';
        xmlStr += '<id sequence="1" source="' + source + '">' + getValueFromMap(requestFields, 'id') + '</id>';
        xmlStr += '<requestdate>' + JSON.serialize(System.now()).substringBetween('"') + '</requestdate>';
        
    xmlStr += '<vehicle interest="buy" status="new">';	
        if (!String.isBlank(vehicle_year)){
            xmlStr += '<year>' + vehicle_year + '</year>';
        }
        else{
            xmlStr += '<year>' + String.valueOf(Date.today().year()) + '</year>';
        }
        
        xmlStr += '<make>' + vehicle_make + '</make>';
        xmlStr += '<model>' + vehicle_model + '</model>';
        xmlStr += '<vin>' + getValueFromMap(requestFields, 'vehicle_vin') + '</vin>';
        xmlStr += '<stock>' + getValueFromMap(requestFields, 'vehicle_stock') + '</stock>';
        xmlStr += '<doors>' + getValueFromMap(requestFields, 'vehicle_doors') + '</doors>';
        xmlStr += '<bodystyle>' + getValueFromMap(requestFields, 'vehicle_bodystyle') + '</bodystyle>';
        xmlStr += '<transmission>' + getValueFromMap(requestFields, 'vehicle_transmission') + '</transmission>';
        xmlStr += '<colorcombination>';
        xmlStr += '<interiorcolor>' + getValueFromMap(requestFields, 'colorcombination_interiorcolor') + '</interiorcolor>';
        xmlStr += '<exteriorcolor>' + getValueFromMap(requestFields, 'colorcombination_exteriorcolor') + '</exteriorcolor>';
        xmlStr += '<preference>' + getValueFromMap(requestFields, 'colorcombination_preference') + '</preference>';
        xmlStr += '</colorcombination>';
        xmlStr += '</vehicle>';

        xmlStr += '<customer>';
        xmlStr += '<contact>';
        xmlStr += '<name part="first">' + contactFirstName + '</name>';
        xmlStr += '<name part="last">' + contactLastName + '</name>';
        
    if (!isEmpty(contactEmail)) {
      xmlStr += '<email>' + contactEmail + '</email>';
    }

    // if all phone fields is blank, send only one empty string
    if (!isEmpty(phonesList)) {
          xmlStr += '<phone type="voice" time="nopreference" preferredcontact="1">' + phonesList.remove(0).substringAfterLast('=') + '</phone>';
    } else {
            xmlStr += '<phone></phone>';
        }

        xmlStr += '<address>';
        xmlStr += '<street line="1">' + getValueFromMap(requestFields, 'contact_address1') + '</street>';
        xmlStr += '<street line="2">' + getValueFromMap(requestFields, 'contact_address2') + '</street>';
        xmlStr += '<apartment>' + getValueFromMap(requestFields, 'contact_apartment') + '</apartment>';
        xmlStr += '<city>' + getValueFromMap(requestFields, 'contact_city') + '</city>';
        xmlStr += '<regioncode>' + getValueFromMap(requestFields, 'contact_regioncode') + '</regioncode>';
        xmlStr += '<postalcode>' + getValueFromMap(requestFields, 'contact_postalcode') + '</postalcode>';
        xmlStr += '<country>' + getValueFromMap(requestFields, 'contact_country') + '</country>';
        xmlStr += '</address>';
        xmlStr += '</contact>';

        xmlStr += '<timeframe>';
        xmlStr += '<description>' + getValueFromMap(requestFields, 'timeframe_description') + '</description>';
        xmlStr += '<earliestdate>' + getValueFromMap(requestFields, 'timeframe_earliestdate') + '</earliestdate>';
        xmlStr += '<latestdate>' + getValueFromMap(requestFields, 'timeframe_latestdate') + '</latestdate>';
        xmlStr += '</timeframe>';

        String customer_comments = getValueFromMap(requestFields, 'customer_comments');
        String notes = getValueFromMap(requestFields, 'notes');
        
        String contact_customer_id = getValueFromMap(requestFields, 'contact_customer_id');

        String[] commentsList = new String[] {};

          
         if (!isEmpty(contact_customer_id)) {
            commentsList.add('dealer_contact_id=' + contact_customer_id);
        }

        if (!isEmpty(notes)) {
            commentsList.add(notes);
        }
        
        if (!isEmpty(customer_comments)) {
            commentsList.add(customer_comments);
        }

        commentsList.addAll(phonesList);

        for(String comment : commentsList){
                comment = comment.replaceAll('&|\'|"|>|<', ' ');
        }
    
        xmlStr += '<comments>' + String.join(commentsList, ' \\') + '</comments>';

        xmlStr += '</customer>';

        xmlStr += '<vendor>';
        xmlStr += '<id sequence="1" source="' + business_unit + '">' + getValueFromMap(requestFields, 'vendorid') + '</id>';
        xmlStr += '<vendorname>' + getValueFromMap(requestFields, 'vendorname') + '</vendorname>';
        xmlStr += '<url>' + getValueFromMap(requestFields, 'vendor_url') + '</url>';
        xmlStr += '</vendor>';

        xmlStr += '<provider>';
        xmlStr += '<id sequence="1" source="' + business_unit + '"/>';
        xmlStr += getProviderNameAndService(sourceCase);
        xmlStr += '<url>' + getValueFromMap(requestFields, 'provider_url') + '</url>';
        xmlStr += '</provider>';
        xmlStr += '</prospect>';
        xmlStr += '</adf>';

        
        
        return xmlStr;
    }

    //--------------------------------------------------------------------------
    // Helpers
    // validate that case contains all required info
    @TestVisible private static Boolean validateCase(Case cs, Map <String, String > requestFields, List <USW_Case_Mappings__c > mappings) {
        Boolean isValid = true;
        
        //First check - Consent To Sent PII
        if(!cs.Consent_to_send_Pii__c){
            isConsent = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Dealer_Search_Controller_Consent_Required);
            ApexPages.addMessage(myMsg);
            isValid = false;
            return isValid;
        }
        
        
    // check that all field mapping are correct
    for (USW_Case_Mappings__c mapping : mappings) {
      if (isEmpty(mapping.SF_Field_Name__c) && !isEmpty(mapping.US_Field_Name__c)) {
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 
          String.format(
            Label.Lead_to_Dealer_Invalid_mapping, 
            new String[] {mapping.US_Field_Name__c, mapping.Id, mapping.Name}
          )
        );
              ApexPages.addMessage(myMsg);
              return isValid = false;
      }
    }
       
        // validate that Prefered Dealer lookup not null
        if (null == cs.Preferred_Dealer__c) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Dealer_Search_Controller_Validate_Preferred_Dealer);
            ApexPages.addMessage(myMsg);
            isValid = false;
        }

        // Validate that on Preferred Dealer record checked Internet Certified cehckbox
        if ((false == cs.Preferred_Dealer__r.Internet_Certified__c) && (null != cs.Preferred_Dealer__c)) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Dealer_Search_Controller_Validate_Internet_Certified);
            ApexPages.addMessage(myMsg);
            isValid = false;
        }


        // validate Mandatory Fields
        // get all field labels for Case
        String type='Case';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();


        Map <String, String > mappingsMap = new Map <String, String > ();
        for (USW_Case_Mappings__c mapping : mappings) {
            mappingsMap.put(mapping.US_Field_Name__c, mapping.SF_Field_Name__c);
        }

        String[] mandatoryFields = new String[] {
            'contact_fullname', 'contact_postalcode'
        };

        String[] missingSfFields = new String[] { };
        
        
        if(cs.Origin == 'Chat' && cs.RecordTypeId == RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'IB Case')){
            Pre_Chat_Data__c supposedPrechat = getPrechatIfAvailable(cs);
            if(supposedPrechat == null || ( String.isBlank(supposedPrechat.Model__c) && String.isBlank(supposedPrechat.Make__c))){
                missingSfFields.add('Model on Chat Data');
                missingSfFields.add('Make on Chat Data');
            }
            else if(supposedPrechat != null && String.isBlank(supposedPrechat.Model__c)){
                 missingSfFields.add('Model on Chat Data');
            }
            else if(supposedPrechat != null && String.isBlank(supposedPrechat.Make__c)){
                 missingSfFields.add('Make on Chat Data');
            }    
        }
        else{
            mandatoryFields.add('vehicle_model');
            mandatoryFields.add('vehicle_make');  
        }
        

        for (String usField : mandatoryFields) {
            String value = getValueFromMap(requestFields, usField);
            if (usField.contains('model'))
            {

                if (cs.RecordTypeId == RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'IB Case')){
                    if (String.isBlank(cs.Model_of_Interest_1st__c) && String.isBlank(cs.Model_of_Interest_2nd__c)){
                        missingSfFields.add('Model of Interest 1st on Call');
                    }
                    else if(cs.Model_of_Interest_1st__c.contains('No Model') && cs.Model_of_Interest_2nd__c.contains('No Model')){
                        missingSfFields.add('Model of Interest 1st on Call');
                    }
                }
                else if (value.contains('No Model')){
                        if(fieldMap.containsKey(mappingsMap.get(usField))){
                            missingSfFields.add(fieldMap.get(mappingsMap.get(usField)).getDescribe().getLabel() + ' on Case');
                        }
                }
                else if (null == value || value.trim().length() == 0) {
                    if(fieldMap.containsKey(mappingsMap.get(usField))){
                        missingSfFields.add(fieldMap.get(mappingsMap.get(usField)).getDescribe().getLabel() + ' on Case');
                    }
                }

            }
            else if (null == value || value.trim().length() == 0) {
                if(fieldMap.containsKey(mappingsMap.get(usField))){
                    missingSfFields.add(fieldMap.get(mappingsMap.get(usField)).getDescribe().getLabel() + ' on Case');
                }
            }
        }

        // validate Email, Phone. A least one field should be populated
        String[] contactInfo = new String[] {
            'contact_email', 'contact_alternate_email', 'contact_home_phone',
            'contact_work_phone', 'contact_mobile_phone'
        };

        String[] missingContactFields = new String[] { };
        for (String usField : contactInfo) {
            String value = getValueFromMap(requestFields, usField);
            if (null == value || value.trim().length() == 0) {
                if(fieldMap.containsKey(mappingsMap.get(usField))){
                    missingContactFields.add(fieldMap.get(mappingsMap.get(usField)).getDescribe().getLabel() + ' on Case');
                }
            }
        }

        String[] errorMsgs = new String[] { };
        if (!missingSfFields.isEmpty()) {
            String errorMsg = String.format(Label.Dealer_Search_Controller_Mandatory_Fields, new String[] { String.join(missingSfFields, ', ') });
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
            ApexPages.addMessage(myMsg);
            isValid = false;
        }

        if (missingContactFields.size() == contactInfo.size()) {
            String errorMsg = String.format(Label.Dealer_Search_Controller_Email_or_Phone_validation, new String[] { String.join(missingContactFields, ', ') });
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
            ApexPages.addMessage(myMsg);
            isValid = false;
        }

        return isValid;
    }

    private static String getValueFromMap(Map <String, String > requestFields, String fieldName) {
        if (requestFields.containsKey(fieldName)) {
            String value = requestFields.get(fieldName);
            if (value != null && value != '') {
                value = value.replaceAll('&|\'|"|>|<', ' ');
                return value;
            }
            else {
                return '';
            }
        }

        return '';
    }

    private static String[] getPhonesList(String home, String work, String mobile) {
        String[] emails = new String[] {};

        if (!isEmpty(home)) {
            emails.add('home_phone=' + home);
        }

        if (!isEmpty(work)) {
            emails.add('work_phone=' + work);
        }

        if (!isEmpty(mobile)) {
            emails.add('mobile_phone=' + mobile);
        }

        return emails;
    }

    private static String getVehicle_ModelForIBCase(String original, Case originalCase){
        if(originalCase.RecordTypeId != RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'IB Case')){
            return original;
        }
        else{
            if (!String.isBlank(originalCase.Model_of_Interest_1st__c) && !originalCase.Model_of_Interest_1st__c.contains('No Model')){
                return originalCase.Model_of_Interest_1st__c;
            }
            else if(!String.isBlank(originalCase.Model_of_Interest_2nd__c) && !originalCase.Model_of_Interest_2nd__c.contains('No Model')){
                return originalCase.Model_of_Interest_2nd__c;
            }
            //Should never happed due to validation in validate case
            else{ 
                return '';
            }
        }
    }

    /** Convert value format from SalesForce Case record field to String value */
    @TestVisible private static String convertValue(DescribeFieldResult sourceField, Object data) {
        String result = '', value = (null != data) ? String.valueOf(data) : '';
        Schema.DisplayType sourceFieldType = (null != sourceField) ? sourceField.getType() : null;
        try {
            if (sourceFieldType == Schema.DisplayType.DATETIME) {
                result = ('' != value) ? DateTimeFormat(DateTime.valueOf(value)) : '';
            } else if (sourceFieldType == Schema.DisplayType.DATE) {
                result = ('' != value) ? DateTimeFormat(Date.valueOf(value)) : '';
            } else if (sourceFieldType == Schema.DisplayType.BOOLEAN) {
                result = value;
            } else if (sourceFieldType == Schema.DisplayType.INTEGER) {
                result = value;
            } else if ((sourceFieldType == Schema.DisplayType.DOUBLE) ||
            (sourceFieldType == Schema.DisplayType.PERCENT) ||
            (sourceFieldType == Schema.DisplayType.CURRENCY)) {

                if ('' != value) {
                    Integer scale = sourceField.getScale();
                    String[] decimalValue = value.split('\\.');
                    value = decimalValue[0];
                    if (0 != scale && decimalValue.size() > 1) {
                        value += String.format('.{0}', new String[] { decimalValue[1].subString(0, scale) });
                    }
                }

                result = value;
            } else if ((sourceFieldType == Schema.DisplayType.STRING) ||
            (sourceFieldType == Schema.DisplayType.TEXTAREA) ||
            (sourceFieldType == Schema.DisplayType.PICKLIST) ||
            (sourceFieldType == Schema.DisplayType.ID) ||
            (sourceFieldType == Schema.DisplayType.PHONE) ||
            (sourceFieldType == Schema.DisplayType.EMAIL) ||
            (sourceFieldType == Schema.DisplayType.URL)) {

                result = value;
            } else {
                result = value;
            }
        } catch(Exception ex) {
            // Ignore any exception
        }

        return result;
    }

    // get describe for sObject fields
    public static Map <String, DescribeFieldResult > getFieldsMap(Schema.SObjectType so) {
        Map <String, DescribeFieldResult > result = new Map <String, DescribeFieldResult > ();

        try {
            Map <String, Schema.SObjectField > fields = so.getDescribe().fields.getMap();

            for (String key : fields.keySet()) {
                final DescribeFieldResult fieldDescribe = fields.get(key).getDescribe();
                result.put(fieldDescribe.getName(), fieldDescribe);
            }
        } catch(Exception ex) {
            // no such object - return an empty list
        }

        return result;
    }

    // format data for specific format
    @TestVisible private static String DateTimeFormat(DateTime d) {
        return d.format('yyyy-MM-dd\'T\'HH:mm:ss');
    }

    private static String isCallsWithValidTypesAvailable(Call__c[] calls, Case cs){
        String notesString = '';
        if(cs.Origin == 'Chat'  && cs.RecordTypeId == RecordtypeUtil.getObjectRecordTypeId(Case.SObjectType, 'IB Case') ){
            for(Call__c call: calls){
                if (String.isNotBlank(call.Call_Type__c) && call.Call_Type__c.contains('Dealer')){
                    notesString += call.Notes__c + ' \\';
                }
            }   
        }
        else{
            for(Call__c call: calls){
                if (call.Call_Type__c == 'Inbound Customer Call' || call.Call_Type__c == 'Outbound Customer Call'){
                    notesString += call.Notes__c + ' \\';
                }
            }   
        }
        return notesString.left(notesString.length()-2);
    }

    private static Pre_Chat_Data__c getPrechatIfAvailable(Case sourceCase){
        if(sourceCase.LiveChatTranscripts.isEmpty()){
            return null;
        }

        Id liveChatId = sourceCase.LiveChatTranscripts[0].id;
        List<Pre_Chat_Data__c> chatData = [SELECT Id, Make__c, Model__c, Year__c FROM Pre_Chat_Data__c WHERE Live_Chat_Transcript__c = :liveChatId AND RecordtypeId = :RecordtypeUtil.getObjectRecordTypeId(Pre_Chat_Data__c.SObjectType, 'MCC')];
        
        if(chatData.isEmpty()){
            return null;
        }        

        return chatData[0];
    }

    private static String getProviderNameAndService(Case sourceCase){
        String xmlString = '';

        for (Dealer_Backfeed_Business_Rules__c busRule : Dealer_Backfeed_Business_Rules__c.getAll().values()) {
            if (sourceCase.RecordtypeId == busRule.RecordTypeValue__c)
            {
                if (sourceCase.Origin == busRule.OriginValue__c) 
                {
                    xmlString += '<name part="full">' + busRule.NameValue__c + '</name>';
                    xmlString += '<service>' + busRule.ServiceNameValue__c + '</service>'; 
                    return xmlString;
                }   
                else if(String.isBlank(busRule.OriginValue__c)){
                    xmlString += '<name part="full">' + busRule.NameValue__c + '</name>';
                    xmlString += '<service>' + busRule.ServiceNameValue__c + '</service>'; 
                    return xmlString;
                }
            }    
        }
        //default value
        xmlString += '<name part="full">' + 'CallCenter' + '</name>';
        xmlString += '<service>' + 'WarmLead' + '</service>';
        return xmlString;
    }

    /* @return the list of all available field mappings */
    private static Map <String, USW_Case_Mappings__c[] > CACHE = new Map <String, USW_Case_Mappings__c[] > ();
    @TestVisible private static List <USW_Case_Mappings__c > getMappings(String rtName) {
        if (CACHE.containsKey(rtName)) {
            return CACHE.get(rtName);
        } else {
            List <USW_Case_Mappings__c > mappings
            = [SELECT Id, Case_Record_Type__c, SF_Field_Name__c,
               US_Field_Name__c, Name
               FROM USW_Case_Mappings__c
               WHERE Case_Record_Type__c = :rtName];

            CACHE.put(rtName, mappings);
            return mappings;
        }
    }

    private static String getSource(String businessUnit) {
        String source = '';
        if ('nissan' == businessUnit.tolowercase()) {
            source = 'Nissanusa.com';
        } else if ('infiniti' == businessUnit.tolowercase()) {
            source = 'Infinitiusa.com';
        }

        return source;
    }

  /** utility method for determining if an object is null or blank.
   * this method doesn't work with Set or Map
   */
  public static Boolean isEmpty(Object o) {
    if (null == o) {
      return true;
    } else if (o instanceof String) {
      return (0 == ((String)o).trim().length());
    } else if (o instanceof List<Object>) {
      return (0 == ((List<Object>)o).size());
    } else {
      return false;
    }
  }
}