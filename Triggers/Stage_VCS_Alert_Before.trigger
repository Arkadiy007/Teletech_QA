trigger Stage_VCS_Alert_Before on Stage_VCS_Alert__c (before insert, before update) {
    for (Stage_VCS_Alert__c stage: Trigger.new) {
        if (stage.Stage_Status__c == 'Processed') {
            stage.Stage_Status__c = 'Done';
        } else {
            stage.Stage_Status__c = 'Process';
        }
    }
}