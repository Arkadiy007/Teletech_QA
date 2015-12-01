/**********************************************************************
Name: DTS_FI_helper_tests
Copyright � notice: Nissan Motor Company.
======================================================
Purpose:
tests for DTS_FI_helper
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Anna Koseikina 7/16/2015 Created
***********************************************************************/
@isTest
public class DTS_FI_helper_tests {
    static testMethod void testChangeOwner() {
        Case c = new Case(
                          Description = 'UNIT TESTING',
                          Origin = 'Phone',
                          Priority = 'Medium',
                          Status = 'New',
                          RecordTypeId = '012F0000000yFmQ', DTS_Notes__c = 'test'
        );
        Profile dtsprof = [select id from profile where name = 'DTS Manager' limit 1];
        User testUs = TestData_Utils.CreateUser(dtsprof.Id);
        insert testUs;
        insert c;
        DTS_Field_Inspection__c dts = new DTS_Field_Inspection__c();
        Map <Id, DTS_Field_Inspection__c > oldValues = new Map <Id, DTS_Field_Inspection__c > ();
        List <DTS_Field_Inspection__c > newValues = new List <DTS_Field_Inspection__c > ();

        dts.Related_Support_Case__c = c.id;
        insert dts;

        dts.ownerId = testUs.id;
        update dts;
        
        newValues.add(dts);
        DTS_Field_Inspection__c dts2 = new DTS_Field_Inspection__c();

        dts2.Related_Support_Case__c = c.id;
        insert dts2;
        oldValues.put(dts2.id, dts2);
        DTS_FI_Helper.handleAfterUpdate(newValues, oldValues);

    }
}