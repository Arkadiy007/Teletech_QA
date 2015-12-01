/**********************************************************************
Name: DQR_Lead_Stage_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Creates DQR record from DQR Lead Stage
======================================================
History:
 
VERSION AUTHOR DATE DETAIL 
1.0 - Yuli Fintescu 3/29/2012 Created
***********************************************************************/
trigger DQR_Lead_Stage_Before on Dealer_Quotes_Request_Lead_Stage__c (before insert) {
	DQRClass.buildDQRs(Trigger.new);
}