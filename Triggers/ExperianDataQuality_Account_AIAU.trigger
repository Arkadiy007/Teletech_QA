trigger ExperianDataQuality_Account_AIAU on Account (after insert, after update) {
    EDQ.DataQualityService.ExecuteWebToObject(Trigger.New, 2, Trigger.IsUpdate);
}