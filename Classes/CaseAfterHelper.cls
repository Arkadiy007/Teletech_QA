/**********************************************************************
  Name: CaseAfterHelper
  Copyright � notice: Nissan Motor Company
  ======================================================
  Purpose: 
  Helper for Case_After trigger
  ======================================================
  History: 

  VERSION AUTHOR DATE DETAIL 
  1.0 - Anna Koseikina    2/2/2015 Created, moved all code from Case_After trigger into this separate class
  1.1 - Arkadiy Sychev    03/27/2015 Add logic for process 'Ignored Case recordTypes' (list of recordTypes for which notification aren't created) 
  and 'Users Who Can View All Updates' (list of users, who can get update nofifications for Cases with ignored recordTypes) 
  fields of MCC Custom Setting.
  1.2 - Anna Koseikina    8/31/2015 Changes for Tiger Team Survey
 ***********************************************************************/
public class CaseAfterHelper {
    public static boolean firstRun = true;

    public void tigerTeamSurveys(Map<Id, Case> newCases, map<Id, Case> oldCases, Set<ID> contactIds) {
        List<Surveys__c> createSurveys = new List<Surveys__c> ();
        
        Id tigerTeam = Schema.SObjectType.Surveys__c.getRecordTypeInfosByName().get('TigerTeam Survey').getRecordTypeId();
        
        Set<Id> casesWithExistSurv = new Set<Id> ();
        for (Surveys__c survey :[Select Id, Tiger_Team_Case__c from Surveys__c where recordtypeid = :tigerTeam and Tiger_Team_Case__c != null]) {
            casesWithExistSurv.add(survey.Tiger_Team_Case__c);
        }
        
        Map<Id, Contact> caseContacts;
        
        caseContacts = new Map<Id, Contact> ([Select Id, FirstName, LastName, Email from Contact where Id in :contactIds]);
        
        for (Case caseitem : newCases.values()) {
        System.debug('*****ownername ' + caseItem.Owner.Name);
            if (caseitem.Reason == 'Tiger Team / STP' && caseItem.Status == 'Closed' && caseContacts.get(caseitem.ContactId) != null && oldCases.get(caseitem.Id) != null && oldCases.get(caseitem.Id).Status != 'Closed' && !casesWithExistSurv.contains(caseitem.id)) {
                Surveys__c survey = new Surveys__c(Case_Id__c = caseItem.Id,
                                                   recordTypeId = tigerTeam,
                                                   Email__c = caseContacts.get(caseitem.ContactId).Email,
                                                   First_Name__c = caseContacts.get(caseitem.ContactId).firstName,
                                                   Last_Name__c = caseContacts.get(caseitem.ContactId).lastName,
                                                   Case_Number_Discussed_with_TT__c = caseitem.CaseNumber,
                                                   Tiger_Team_Case__c = caseitem.Id);
                
                    survey.Case_Owner__c = caseitem.Owner.Name;
                
                                                   
                if (String.isNotBlank(caseitem.Part_Number_1__c)) {
                    survey.Part_Number__c = caseitem.Part_Number_1__c.toUpperCase();
                }
                createSurveys.add(survey);
            }
        }

        if(createSurveys.size() > 0){
            Database.SaveResult[] dbResults = Database.insert(createSurveys, false);

                    // If there are any results, handle the errors
                    if (!dbResults.isEmpty())
                    {
                        // Loop through results returned
                        for (integer row = 0; row <createSurveys.size(); row++)
                        {
                            // If the current row was not sucessful, handle the error.
                            if (!dbResults[row].isSuccess())
                            {                               // Get the error for this row
                                Database.Error err = dbResults[row].getErrors() [0];
                                newCases.get(createSurveys[row].Tiger_Team_Case__c).addError('Survey cannot be saved ' + err.getMessage());
                            }            
                        }
                    
                }
        }
    }
}