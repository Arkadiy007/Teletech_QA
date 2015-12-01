trigger Account_CA_AIAU on Account(after insert, after update) {
QAS_NA.CAAddressCorrection.ExecuteCAAsyncForTriggerConfigurationsOnly(trigger.new);
}