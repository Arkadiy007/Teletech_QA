trigger UserAssignment_BI_BU on User_Assignment__c (before insert, before update) {
    
    UserAssignment.evaluateAssignment(Trigger.New, Trigger.isUpdate);

}