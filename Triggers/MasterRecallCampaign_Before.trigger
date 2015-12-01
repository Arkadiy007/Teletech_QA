trigger MasterRecallCampaign_Before on Master_Recall_Campaign__c (before insert) {
    // Make sure Name, Recall_Identifier__c, and Vehicle_Recall_Business_Id__c are all
    // set to the same Id.  Users enter the Name field while automated jobs set
    // the Recall Identifier and/or Vehicle Recall Business Id.
    for (Master_Recall_Campaign__c mrc: Trigger.new) {
        if (mrc.Name != null && mrc.Name.length() < 10) {
            if (mrc.Vehicle_Recall_Business_Id__c == null) {
                mrc.Vehicle_Recall_Business_Id__c = mrc.Name;
            }
            if (mrc.Recall_Identifier__c == null) {
                mrc.Recall_Identifier__c = mrc.Name;
            }
        } else if (mrc.Name == null || mrc.Name.length() >= 10) {
            if (mrc.Recall_Identifier__c != null) {
                mrc.Name = mrc.Recall_Identifier__c;
                mrc.Vehicle_Recall_Business_Id__c = mrc.Recall_Identifier__c;
            } else if (mrc.Vehicle_Recall_Business_Id__c != null) {
                mrc.Name = mrc.Vehicle_Recall_Business_Id__c;
                mrc.Recall_Identifier__c = mrc.Vehicle_Recall_Business_Id__c;
            }
        }
    }
}