/**********************************************************************
Name: SurveyBuilderToolController 
Copyright © notice: Nissan Motor Company
======================================================
Purpose: Controller for SurveyBuilderTool.

This class contains routines to handle the creation of a Survey 
using the SurveyBuilder object.

It essentially provides crud functions for the SurveyBuilder__c table)

Related Class : SurveyBuilderController
    (contains question structure and routines to render
        the survey)
        
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - William Taylor  10/27/2015 Created
***********************************************************************/

public class SurveyBuilderToolController {
  
    public List<SelectOption> recordTypeOptions {get; set;}
    public List<SelectOption> availableLanguages {get; set;}
    public String selectedSurvey {get; set;}
    public String selectedLanguage {get;set;}
    public List<SurveyBuilderController.SurveyQuestion> surveyQuestions {get; set;}
    public String surveyTitle {get; set;}
    public List<SelectOption> questionTypeOptions {get; set;}
    public Boolean haveRecords {get; set;}
    public Integer recordCount {get; set;}
    public Boolean previewModeOn {get; set;}
    public String testRecordId {get; set;}
    public String questionNumber {get; set;}
    public List<SelectOption> questionNumbers {get; set;}
    public List<SelectOption> questionOperators{get; set;}

    
    public String newOption {get; set;}
    
    public SurveyBuilderToolController() {
        previewModeOn = false;
        haveRecords = false;
        questionNumbers = new List<SelectOption>();
        
        questionTypeOptions = new List<SelectOption>();
        questionTypeOptions.add(new SelectOption('Text','Text'));
        questionTypeOptions.add(new SelectOption('Textarea','Text Area'));
        questionTypeOptions.add(new SelectOption('Slider','Slider Bar'));
        questionTypeOptions.add(new SelectOption('Date','Date Picker'));
        questionTypeOptions.add(new SelectOption('YesNo','Yes / No'));
        questionTypeOptions.add(new SelectOption('Choice','Choice'));
        questionTypeOptions.add(new SelectOption('VerticalRadio','Vertical Radio'));
        questionTypeOptions.add(new SelectOption('Radio','Radio'));
        questionTypeOptions.add(new SelectOption('Information','Information'));
        questionTypeOptions.add(new SelectOption('Finish','Post Survey Message'));
        questionTypeOptions.add(new SelectOption('Checkbox','Checkbox'));
        
        questionOperators = new List<SelectOption>();
        
        questionOperators.add(new SelectOption('=','='));
        questionOperators.add(new SelectOption('!=','!='));
        questionOperators.add(new SelectOption('>','>'));
        questionOperators.add(new SelectOption('<','<'));
        
        recordTypeOptions  = new List<SelectOption>();
        availableLanguages = new List<SelectOption>();
        surveyQuestions = new List<SurveyBuilderController.SurveyQuestion>();
        
        List<RecordType> allSurveyRecordTypes = [select id, name from recordtype where sobjecttype='Surveys__c'];
        List<AggregateResult> allLanguages = [select language__c l from SurveyBuilder__c group by language__c];
        recordTypeOptions.add(new SelectOption('','Select one..'));
        
        for (RecordType rt: allSurveyRecordTypes ) {
    
            recordTypeOptions.add(new SelectOption(rt.name,rt.name));
        }
    
        Set<String> languageSet = new Set<String>();
        languageSet.add('En');
        languageSet.add('Es');
        availableLanguages.add(new SelectOption('','Select one..'));
        for (AggregateResult r: allLanguages ) {
            String s = (String) r.get('l');
            languageSet.add(s);
        }
       
        for (String thisLanguage : languageSet) {
            availableLanguages.add(new SelectOption(thisLanguage,thisLanguage));
        }
        
    
    
    }

    public PageReference populateSurvey() {
    
        surveyTitle = '';
        if (selectedSurvey!= null && selectedLanguage != null && selectedSurvey != '' && selectedLanguage != '') {
        System.debug('[' + selectedSurvey + '] is the survey and [' + selectedLanguage + ']');
         
        haveRecords = true;
        surveyQuestions.clear();
    
        
        List<SurveyBuilder__c> sbList = [select id,defaultValue__c, visible__c,visibilityConditions__c, question__c, required__c, question_type__c, question_number__c, language__c, mapsto__c, surveytitle__c from SurveyBuilder__c where recordtypename__c=:selectedSurvey and language__c=:selectedLanguage order by question_number__c asc];
        
        
        AggregateResult sresult = [select max(question_number__c) max from surveybuilder__c where recordtypename__c=:selectedSurvey and language__c=:selectedLanguage];
        recordCount = Integer.valueOf(sresult.get('max'));
        
        
        if (sbList.size() > 0) {
            
             questionNumbers.clear();
            for (SurveyBuilder__c sb : sbList) {
                      
                       
                       surveyTitle = sb.surveytitle__c;
                       SurveyBuilderController.SurveyQuestion sq = new SurveyBuilderController.SurveyQuestion();
                       sq.qChoices = new List<SelectOption>();
                       sq.qvisibilityConditions = new List<SelectOption>();
                       
                       String choiceText = '';
                       sq.defaultValue = sb.defaultValue__c;
                       sq.isChoice = false;
                       sq.isRadioChoice = false;
                       sq.visible = sb.visible__c;
                       sq.visibilityConditions = sb.visibilityConditions__c;
                       sq.isRequired = sb.required__c;
                       sq.questionText = sb.question__c;
                       sq.questionNumber = String.valueOf(sb.question_number__c); 
                       questionNumbers.add(new SelectOption(sq.questionNumber,sq.questionNumber));
                       
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
                           sq.questionType = 'Choice';
                       } 
                       if (sb.Question_Type__c.startsWith('Radio')) {                
                           sq.isRadioChoice = true;
                           choiceText = sb.Question_Type__c.substring(5);
                            sq.questionType = 'Radio'; 
                       } 
                       if (sb.Question_Type__c.startsWith('VerticalRadio')) {                
                           sq.isVerticalRadioChoice = true;
                           choiceText = sb.Question_Type__c.substring(13);
                            sq.questionType = 'VerticalRadio'; 
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
                           for (String cond: allConds) {
                               sq.qvisibilityConditions.add(new SelectOption(cond, cond.replace(',','')));    
                           }
                       }
                       
                       surveyQuestions.add(sq); 
                    }
                
            }
        } else {
            haveRecords = false;
        }
    
    return null;
    
    }

    public PageReference moveUp() {
        // take given question number, find it, subtract one from it, and renumber the questions
        if (questionNumber == null || Integer.valueOf(questionNumber) == 1) { return null; }
        for (SurveyBuilderController.SurveyQuestion sq: surveyQuestions) {
            if (Integer.valueOf(sq.questionNumber) == Integer.valueOf(questionNumber) - 1) { 
                sq.questionNumber = questionNumber;
            } else {
                if (Integer.valueOf(sq.questionNumber) == Integer.valueOf(questionNumber)) {
                    sq.questionNumber = String.valueOf(Integer.valueOf(questionNumber) - 1);
                }
            }
                
        }     
        save();
           
        return null;
    
    }
    public PageReference moveDown() {
    
        Integer currentMax = surveyQuestions.size();
        
     // take given question number, find it, add one to it, and renumber the questions
        
        if (questionNumber == null || Integer.valueOf(questionNumber) == currentMax) { 
            return null; 
        }
        
        for (SurveyBuilderController.SurveyQuestion sq: surveyQuestions) {
            if (Integer.valueOf(sq.questionNumber) == Integer.valueOf(questionNumber) + 1) { 
                sq.questionNumber = questionNumber;
            } else {
                if (Integer.valueOf(sq.questionNumber) == Integer.valueOf(questionNumber)) {
                    sq.questionNumber = String.valueOf(Integer.valueOf(questionNumber) + 1);
                }
            }        
        }   
        save();   
        return null;
    }


    public PageReference addCondition() {
        
        for (SurveyBuilderController.SurveyQuestion sq: surveyQuestions) {
            sq.recentlyEdited=false;
        }       
        
        for (SurveyBuilderController.SurveyQuestion sq: surveyQuestions) {
            if (sq.questionNumber == questionNumber) {
                sq.qvisibilityConditions.add(new SelectOption(sq.newConditionQuestionNum + ',' + sq.newConditionQuestionOperator + ',' + sq.newConditionValue,'Question ' + sq.newConditionQuestionNum + ' ' + sq.newConditionQuestionOperator + ' \"' + sq.newConditionValue+ '\"'));
                sq.newConditionQuestionNum= '';
                sq.newConditionQuestionOperator = '';
                sq.newConditionValue = '';
                sq.recentlyEdited = true;
            }
            
        }
        return null;
    
    }
    public PageReference deleteCondition() {
        Integer qCounter = 0;
        
        for (SurveyBuilderController.SurveyQuestion sq: surveyQuestions) {
            sq.recentlyEdited=false;
        }       
        
        for (SurveyBuilderController.SurveyQuestion sq: surveyQuestions) {
            if (sq.questionNumber == questionNumber) {
                for (SelectOption s: sq.qvisibilityConditions) {
                    
                    if (s.getValue() == sq.selectedCondition) {
                        System.debug('found the one i want to delete..' + s.getValue());
                        sq.qvisibilityConditions.remove(qCounter);
                        sq.recentlyEdited = true;
                        return null;
                        
                    }
                    qCounter++;
                    
                }
            }
            
        }
        return null;
    
    }

    public PageReference addoption() {
        
        for (SurveyBuilderController.SurveyQuestion sq: surveyQuestions) {
            sq.recentlyEdited=false;
        }       
        
        for (SurveyBuilderController.SurveyQuestion sq: surveyQuestions) {
            if (sq.questionNumber == questionNumber) {
                sq.qChoices.add(new SelectOption(sq.newChoiceValue,sq.newChoiceValue));
                sq.newChoiceValue = '';
                sq.recentlyEdited = true;
            }
            
        }
        return null;
    
    }
    
    public PageReference deleteoption() {
        Integer qCounter = 0;
        
        for (SurveyBuilderController.SurveyQuestion sq: surveyQuestions) {
            sq.recentlyEdited=false;
        }       
        
        for (SurveyBuilderController.SurveyQuestion sq: surveyQuestions) {
            if (sq.questionNumber == questionNumber) {
                for (SelectOption s: sq.qChoices) {
                    
                    if (s.getValue() == sq.selectedChoice) {
                        System.debug('found the one i want to delete..' + s.getValue());
                        sq.qChoices.remove(qCounter);
                        sq.recentlyEdited = true;
                        return null;
                        
                    }
                    qCounter++;
                    
                }
            }
            
        }
        return null;
    
    }
    
    
    public PageReference save() {
    
        List<SurveyBuilder__c> sbInsertList = new List<SurveyBuilder__c>();
    
        for (SurveyBuilderController.SurveyQuestion sq: surveyQuestions) {
             SurveyBuilder__c thissb = new SurveyBuilder__c();
             
             thissb.SurveyTitle__c = surveyTitle;
             thissb.question_number__c = Integer.valueOf(sq.questionNumber);
             thissb.question__c = sq.questionText;
             thissb.required__c = sq.isRequired;
             thissb.visible__c = sq.visible;
             thissb.defaultValue__c = sq.defaultValue;
             if (thissb.visible__c != true) {
                 String vC = '';
                 
                 for (SelectOption thisOption: sq.qvisibilityConditions) {
                     vC = vC + thisOption.getValue() + '|';
                 }
                 
                 thissb.visibilityConditions__c = vC;
             }
             
             thissb.question_type__c = sq.questionType;
             if (thissb.question_type__c == 'Choice' || thissb.question_type__c == 'Radio' || thissb.question_type__c == 'VerticalRadio') {
                 String addOn = ',';
                 for (SelectOption thisOption: sq.qChoices) {
                     if (thisOption.getValue() != '') {
                         addOn = addOn + thisOption.getValue() + ',';
                     }
                 }
                 addOn = addOn.removeEnd(',,');
                 addOn = addOn.removeEnd(',');
                 thissb.question_type__c = thissb.question_type__c + addOn;
             }
             
             thissb.language__c = selectedLanguage;
             thissb.mapsto__c = sq.destinationField;
             thissb.recordtypename__c = selectedSurvey;
    
             sbInsertList.add(thissb);
             
        }
         List<SurveyBuilder__c> sbList = [select id, question__c, required__c, question_type__c, question_number__c, language__c, mapsto__c,surveytitle__c from SurveyBuilder__c where recordtypename__c=:selectedSurvey and language__c=:selectedLanguage order by question_number__c asc];
        Database.delete(sbList);
        
        Database.insert(sbInsertList);
        
        //System.debug(sbInsertList);
        populateSurvey();
        return null;
    }

    public PageReference deleteQuestion() {
        Integer qNumber = Integer.valueOf(questionNumber);
        
        List <SurveyBuilder__c> sbList = [select id,question_number__c from SurveyBuilder__c where recordtypename__c=:selectedSurvey and language__c=:selectedLanguage and question_number__c=:qNumber order by question_number__c asc];
        Database.delete(sbList);
        populateSurvey();
        return null; 
    }
    
    public PageReference addQuestion() {
    
        SurveyBuilderController.SurveyQuestion sq = new SurveyBuilderController.SurveyQuestion();
        if (recordCount == null) {
            recordCount = 0;
        }
        sq.questionNumber = String.valueOf(recordCount + 1);
        sq.questionType = 'Text';
        sq.questionText = 'Enter question text...';
        sq.isRequired = false;
        sq.qvisibilityConditions = new List<SelectOption>();
        
        sq.visible = true;
        sq.isRendered = true;
        
        surveyQuestions.add(sq);
        save();
        
        return null;
        
    }

    public PageReference previewMode() {
            if (selectedSurvey != null && selectedLanguage != null) {
                // we should have recordtype to make/test for an upserted surveys__c record and then reset it's submitted.
                List<recordtype> rtNames = [select id, name from recordtype where name =:selectedSurvey and sobjecttype='Surveys__c' limit 1];
                if (rtNames.size() == 1) {
                    Surveys__c thisTestSurvey = new Surveys__c();
                    thisTestSurvey.recordtypeid = rtNames[0].id;
                    insert thisTestSurvey;
                    testRecordId = String.valueOf(thisTestSurvey.id);
                    previewModeOn = true;
                }
                
            
           }
           return null;
    }

    public PageReference endPreviewMode() {
        previewModeOn = false;
        return null;
        
    }

}