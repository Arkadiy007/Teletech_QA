trigger QASCAAccountCancel_BIBU on QAS_NA__QAS_CA_Account__c (before update) {
    for (Integer currentRecord= 0; currentRecord< trigger.new.size(); ++currentRecord) {
        trigger.new[currentRecord].QAS_NA__NumberOfFailedAttempts__c = 1;
    }
}