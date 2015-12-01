trigger ExperianDataQuality_Account_BIBU on Account (before insert, before update) {
    EDQ.DataQualityService.SetValidationStatus(Trigger.new, Trigger.old, Trigger.IsInsert, 2);
}