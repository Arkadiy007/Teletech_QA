trigger Brochure_Request_After on Brochure_Request__c (after insert, after update) {
    // Call the web service to send the Brochure Request on all upserts
    // and whenever the request has not been previously processed sucessfully.
    // Only call for brochure requests, not literature requests.
    RecordType brochureRequestRecordType = [select id from recordtype where sobjecttype = 'Brochure_Request__c' and name = 'Brochure Request'];
    for (Brochure_Request__c rec : Trigger.new) {
        if (rec.RecordTypeId == brochureRequestRecordType.Id) {
            if ((Trigger.isInsert || rec.Processed_Successfully__c == false)
                && BrochureRequest_Webservices.triggerUpdate == false) {
                BrochureRequest_Webservices.CallSubmitRecord(rec.id);
            } else {
                BrochureRequest_Webservices.triggerUpdate = false;
            }
        }
    }
}