/**********************************************************************
Name: Nna360VCAN2MasterServiceSoap_Test
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
These are additional tests for the Nna360VCAN2MasterServiceSoap service.

 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - William Taylor  10/9/2014 Created 
***********************************************************************/
@isTest
private class Test_Nna360VCAN2MasterServiceSoap  {
   static testmethod void additionalTests() {

Test.startTest();
Nna360VCAN2MasterServiceSoap.DG_VCANResponseFaultBO rf = new Nna360VCAN2MasterServiceSoap.DG_VCANResponseFaultBO();
Nna360VCAN2MasterServiceSoap.deleteVCAN_Input rf2 = new Nna360VCAN2MasterServiceSoap.deleteVCAN_Input();
Nna360VCAN2MasterServiceSoap.createVCAN_Input rf3 = new Nna360VCAN2MasterServiceSoap.createVCAN_Input();
Nna360VCAN2MasterServiceSoap.updateVCAN_Input rf4 = new Nna360VCAN2MasterServiceSoap.updateVCAN_Input();
Nna360VCAN2MasterServiceSoap.viewVCAN_Input rf5 = new Nna360VCAN2MasterServiceSoap.viewVCAN_Input();

Nna360VCAN2MasterServiceSoap.deleteVCAN_Output r2 = new Nna360VCAN2MasterServiceSoap.deleteVCAN_Output();
Nna360VCAN2MasterServiceSoap.createVCAN_Output r3 = new Nna360VCAN2MasterServiceSoap.createVCAN_Output();
Nna360VCAN2MasterServiceSoap.updateVCAN_Output r4 = new Nna360VCAN2MasterServiceSoap.updateVCAN_Output();
Nna360VCAN2MasterServiceSoap.viewVCAN_Output r5 = new Nna360VCAN2MasterServiceSoap.viewVCAN_Output();

Nna360VCAN2MasterServiceSoap.deleteVCANResp rfe2 = new Nna360VCAN2MasterServiceSoap.deleteVCANResp();
Nna360VCAN2MasterServiceSoap.createVCANResp rfe3 = new Nna360VCAN2MasterServiceSoap.createVCANResp();
Nna360VCAN2MasterServiceSoap.updateVCANResp rfe4 = new Nna360VCAN2MasterServiceSoap.updateVCANResp();
Nna360VCAN2MasterServiceSoap.viewVCANResp rfe5 = new Nna360VCAN2MasterServiceSoap.viewVCANResp();

Test.stopTest();
}
}