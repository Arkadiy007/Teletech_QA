@isTest
public class RecordTypeUtil_Test{
    
    static testMethod void Test1() {
        
        String AcctTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Dealer');
        try{
        String ErrorTypeId = RecordtypeUtil.getObjectRecordTypeId(Account.SObjectType, 'Error');
        } catch (exception e){}
    }
}