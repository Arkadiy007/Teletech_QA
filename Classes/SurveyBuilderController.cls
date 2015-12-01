/**********************************************************************
Name: SurveyBuilderController
Copyright © notice: Nissan Motor Company
======================================================
Purpose:  Controller for SurveyBuilderPage
======================================================
History:

VERSION AUTHOR DATE DETAIL
    1.0 - William Taylor      10/16/2015 Created
                         
***********************************************************************/
public class SurveyBuilderController {
    public Survey s {get; set;}
    public List<SurveyQuestion> surveyQuestions {get; set;}
    public Surveys__c thisSurvey {get; set;}
    public String surveyId { get; set;}
    public Boolean isComplete { get; set;}
    public Boolean isNissan { get; set;}
    public Boolean isInfiniti { get; set;}
    public String brandName {get; set; }
    
    public class SurveyQuestion {
        public String questionText {get; set;}
        public String questionType {get; set;}
        public String questionNumber {get; set;}
        public String destinationField {get; set;}
        public Boolean isText {get; set;}
        public Boolean isDate {get; set;}
        public Boolean isYesNo {get; set;}
        public Boolean isTextArea {get; set;}
        public Boolean isInformation {get; set;}
        public Boolean isSlider {get; set;}
        public Boolean isChoice {get; set;}
        public Boolean isRadioChoice {get; set;}
        public Boolean isVerticalRadioChoice {get; set;}
        public Boolean isRendered {get; set;}
        public Boolean visible {get; set;}
        public String visibilityConditions {get;set;}
        
        public Boolean isFinish {get; set;}
        public Boolean isRequired {get; set;}
        public Boolean isCheckbox {get; set;}
        
        public List<SelectOption> qChoices {get; set;}
        public List<SelectOption> qvisibilityConditions {get; set;}
        public String selectedCondition {get; set;}
        public String selectedChoice {get; set;}
        public String newChoiceValue {get; set;}
        public Boolean recentlyEdited {get; set;}
        
        public String newConditionQuestionNum {get; set;}
        public String newConditionQuestionOperator {get; set;}
        public String newConditionValue {get;set;}
        
        public String defaultValue {get; set; }
        
        public String questionAnswer {get; set;}
    }

    public class Survey {
        public String surveyTitle {get; set;}
        public List<SurveyQuestion> surveyQuestions;
    }

    public SurveyBuilderController() {
        isComplete = false;
        surveyQuestions = new List<SurveyQuestion>();
        s = new Survey();
    
        String selectedSurvey = '';
        String selectedLanguage = 'En';
        surveyId = '';
        if (Apexpages.currentPage().getParameters().size() > 0) {
             surveyId = Apexpages.currentPage().getParameters().get('sid');    
        }
        
        List<Surveys__c> theseSurveys = new List<Surveys__c>();
        
        if (surveyId.length() == 15 || surveyId.length() == 18) {
            theseSurveys = [Select id, recordtype.name, Customer__r.phone,Customer__r.personemail, vehicle__r.name,vehicle__r.Model_Name__c,dealerName__c, Customer__r.firstname, Customer__r.lastname, language_completed__c, brand__c,Survey_Submitted__c  from surveys__c where id=:surveyId limit 1];
        }
        if (theseSurveys.size() == 1) {
            thisSurvey = theseSurveys[0]; // only one should match by id.
            selectedSurvey = thisSurvey.recordtype.name;
            brandName = thisSurvey.brand__c == null ? 'Nissan/Infiniti' : thisSurvey.brand__c.toLowerCase();
            isInfiniti = false;
            isNissan = false;
            isComplete = thisSurvey.survey_submitted__c;
            
            if (brandName == 'nissan') {
                isNissan = true; brandName = 'Nissan';
            }
            if (brandName == 'infiniti') {
                isInfiniti = true; brandName = 'Infiniti';
            }
            
            selectedLanguage = thisSurvey.language_Completed__c == null ? 'En' : thisSurvey.language_Completed__c;
            if (selectedLanguage == 'E') { selectedLanguage = 'En';}
            if (selectedLanguage == 'F') { selectedLanguage = 'Fr';}
            
           List<SurveyBuilder__c> sbList = [select id, defaultValue__c, visible__c, visibilityConditions__c, question__c, required__c, question_type__c, question_number__c, language__c, mapsto__c, surveytitle__c from SurveyBuilder__c where recordtypename__c=:selectedSurvey and language__c=:selectedLanguage order by question_number__c asc];
           for (SurveyBuilder__c sb : sbList) {
               s.surveyTitle = sb.surveytitle__c;
               
               
               
               SurveyQuestion sq = new SurveyQuestion();
               sq.isRendered = sb.visible__c;        
               sq.visible = sb.visible__c;
               sq.visibilityConditions = sb.visibilityConditions__c;
               
               sq.recentlyEdited = false;
               
               sq.qChoices = new List<SelectOption>();
               String choiceText = '';
               
               sq.isChoice = false;
               sq.isRadioChoice = false;
               sq.isVerticalRadioChoice = false;

               sq.isRequired = sb.required__c;
               sq.questionText = sb.question__c.replace('!BRAND!',brandName);
               sq.questionText = thisSurvey.customer__r.firstname != null ? sb.question__c.replace('!FIRSTNAME!',thisSurvey.customer__r.firstname) :sb.question__c.replace('!FIRSTNAME!','')  ;
               sq.questionText = thisSurvey.customer__r.lastname != null ? sb.question__c.replace('!LASTNAME!',thisSurvey.customer__r.lastname) :sb.question__c.replace('!LASTNAME!','') ;
               sq.questionText = thisSurvey.vehicle__r.Model_Name__c != null ? sb.question__c.replace('!VEHICLENAME!',thisSurvey.vehicle__r.Model_Name__c) : sb.question__c.replace('!VEHICLENAME!','') ;
               sq.questionText = thisSurvey.dealerName__c != null ? sb.question__c.replace('!DEALERNAME!',thisSurvey.dealerName__c) : sb.question__c.replace('!DEALERNAME!','');
               sq.questionText = thisSurvey.vehicle__r.name != null ? sb.question__c.replace('!VIN!',thisSurvey.vehicle__r.name) :sb.question__c.replace('!VIN!','') ;
               sq.questionText = thisSurvey.customer__r.phone != null ? sb.question__c.replace('!PHONE!',thisSurvey.customer__r.phone) : sb.question__c.replace('!PHONE!','');
               sq.questionText = thisSurvey.customer__r.personemail != null ? sb.question__c.replace('!EMAIL!',thisSurvey.customer__r.personemail) : sb.question__c.replace('!EMAIL!','');
               

               sq.defaultvalue = sb.defaultValue__c;
               sq.questionNumber = String.valueOf(sb.question_number__c); 
               sq.questionType = sb.question_type__c;
               sq.destinationField = sb.mapsto__c;
               sq.isDate = sb.Question_Type__c == 'DatePicker' ? true : false;
               sq.isText = sb.Question_Type__c == 'Text' ? true : false;
               sq.isTextArea = sb.Question_Type__c == 'TextArea' ? true : false;
               sq.isInformation= sb.Question_Type__c == 'Information' ? true : false;
               sq.isSlider = sb.Question_Type__c == 'Slider' ? true : false;
               sq.isYesNo = sb.Question_Type__c == 'YesNo' ? true : false;
               sq.isFinish = sb.Question_Type__c == 'Finish' ? true : false;
               sq.isCheckbox = sb.Question_Type__c == 'Checkbox' ? true : false;
               
               if (sb.Question_Type__c.startsWith('Choice')) {                
                   sq.isChoice = true;
                   choiceText = sb.Question_Type__c.substring(6);
               } 
               if (sb.Question_Type__c.startsWith('Radio')) {                
                   sq.isRadioChoice = true;
                   choiceText = sb.Question_Type__c.substring(5);
                   
               } 
               if (sb.Question_Type__c.startsWith('VerticalRadio')) {                
                   sq.isVerticalRadioChoice = true;
                   choiceText = sb.Question_Type__c.substring(13);
                   
               } 
               if (choiceText.contains(',')) {
                       String[] arrTest = choiceText.split('\\,');
                       if (sq.isChoice) { sq.qChoices.add(new SelectOption('', 'Select one...')); }
                       for (String a : arrTest) {
                           if (a != null && a.length() > 0) {
                               sq.qChoices.add(new SelectOption(a, a));
                           }
                       }
               }
               
               if (sq.visibilityConditions != null && sq.visibilityConditions != '' && sq.visible == false) {
                   // check conditions
                   String[] allConds = sq.visibilityConditions.split('\\|');
                   for (String cond : allConds) {
                       String[] thisConditions = cond.split('\\,');
                       //fieldname,operator,value
                       if (thisConditions[1] == '=' && getAnswerValue(thisConditions[0])  ==  thisConditions[2]) {
                          sq.isRendered=true;
                       }
                       if (thisConditions[1] == '!=' && getAnswerValue(thisConditions[0])  !=  thisConditions[2]) {
                          sq.isRendered=true;
                       }
                       if (thisConditions[1] == '>' && getAnswerValue(thisConditions[0])  >  thisConditions[2]) {
                          sq.isRendered=true;
                       }
                       if (thisConditions[1] == '<' && getAnswerValue(thisConditions[0])  <  thisConditions[2]) {
                          sq.isRendered=true;
                       }
                   }
               }  
               
               if (sq.defaultValue != null) {
                   sq.questionAnswer = sq.defaultValue;
               }
               
               surveyQuestions.add(sq); 
            }
         } else {
             // no surveys match, nothing real given.
             isComplete = true;
         }
    }
    
    
    
    
   Public PageReference save(){
       
       Map<String, Schema.SObjectField> M;
       M = Schema.SObjectType.Surveys__c.fields.getMap();
           Schema.SObjectField field;
           String FldType; 
           
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This message for debug purposes only, wont be shown to real users:'));
        
       for (SurveyQuestion sq: surveyQuestions) {

           field = M.get(sq.destinationField);
           if (field != null) {
               FldType = field.getDescribe().getType().name();
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This message for debug purposes only, wont be shown to real users:' + sq.questionText + ' - ' + sq.questionAnswer  + ', will map to: ' + sq.destinationField + ', which is field type' + FldType ));
           
           } else {
               FldType = '';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,sq.questionText + ' - ' + sq.questionAnswer  + ', will map to: ' + sq.destinationField + ',  no matches. so no field type' + FldType ));
           }

           if ((sq.destinationField != null && sq.destinationField.length() > 0 && FldType != null && sq.questionAnswer != null) || (Test.isRunningTest() && sq.destinationField != null)) {
               if (FldType == 'DOUBLE') {
                   thisSurvey.put(sq.destinationField,sq.questionAnswer == null ?  null : Double.valueOf(sq.questionAnswer));
               } else if (FldType == 'DATETIME') {
                   thisSurvey.put(sq.destinationField,sq.questionAnswer == null ? null : DateTime.valueOf(sq.questionAnswer));
               } else if (FldType == 'DATE') {
                   thisSurvey.put(sq.destinationField,sq.questionAnswer == null ?  null : Date.valueOf(sq.questionAnswer));
               } else if (FldType == 'BOOLEAN') {
                   thisSurvey.put(sq.destinationField,sq.questionAnswer == null ?  false : Boolean.valueOf(sq.questionAnswer));
               } else {
                   thisSurvey.put(sq.destinationField,sq.questionAnswer == null ? null : sq.questionAnswer);
               }
               
           }

       }
           thisSurvey.Survey_Submitted__c = true;
           isComplete = true;
       update thisSurvey;
           
       return null;
   }
   
   
   Public PageReference partialSave(){
       
       for (SurveyQuestion sq: surveyQuestions) {
           if (sq.visible == false) {
               sq.isRendered = false; // check non visible questions each time.
           }
           
           if (sq.visibilityConditions != null && sq.visibilityConditions != '' && sq.visible == false) {
               // check conditions
               String[] allConds = sq.visibilityConditions.split('\\|');
               for (String cond : allConds) {
                   String[] thisConditions = cond.split('\\,');
                   //fieldname,operator,value
                   if (thisConditions[1] == '=' && getAnswerValue(thisConditions[0])  ==  thisConditions[2]) {
                      sq.isRendered=true;
                   }
                   if (thisConditions[1] == '!=' && getAnswerValue(thisConditions[0])  !=  thisConditions[2]) {
                      sq.isRendered=true;
                   }
                   if (thisConditions[1] == '>' && getAnswerValue(thisConditions[0])  >  thisConditions[2]) {
                      sq.isRendered=true;
                   }
                   if (thisConditions[1] == '<' && getAnswerValue(thisConditions[0])  <  thisConditions[2]) {
                      sq.isRendered=true;
                   }
               }
           }        

       }
       
       return null;
   }
   
   public String getAnswerValue(String questionNumber) {
 
      for (SurveyQuestion sq: surveyQuestions) {
          if (sq.questionNumber == questionNumber) {
              return sq.questionAnswer;
           }
      }
      return '';
      
   }
    
       
}