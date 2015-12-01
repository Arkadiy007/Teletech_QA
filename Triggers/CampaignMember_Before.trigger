/**********************************************************************
Name: CampaignMember_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
Whenever a new CampaignMember is created, fill in
Salesforce internal Ids by looking them up from
external ids provided.
 
Related Class : CampaignMemberClass
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry 01/14/2011 Created
1.1 - Bryan Fry 01/17/2011 Added VIN and Dealer Code lookups
1.2 - Bryan Fry 02/18/2011 Fixed Call Count code and columns
1.3 - JJ 01/16/12 Removed assignment of usa label from dealer codes per WO 15
        Changed query from Dealer_External_Id__c to Dealer_Code__c
1.4 - JJ        02/08/2012 Added check and count increase for System.Label.WFC
1.5 - Bryan Fry 06/19/2013 Changed dealer lookup to look at country and use Dealer_External_Id__c
***********************************************************************/

trigger CampaignMember_Before on CampaignMember (before insert) {
    Set<String> customerIds = new Set<String>();
    Set<String> vins = new Set<String>();
    Set<String> dealerExternalIds = new Set<String>();
    Set<Id> campaignIds = new Set<Id>();
    Campaign camp;
    List<Error_Log__c> errors = new List<Error_Log__c>();
    // Construct a Set of Customer_IDs from the CampaignMembers input through Trigger.new
    for (CampaignMember member : Trigger.new) {
        if (member.Customer_ID__c != null)
            customerIds.add(member.Customer_ID__c);
        if (member.Vehicle_Identification_Number__c != null)
            vins.add(member.Vehicle_Identification_Number__c);
        campaignIds.add(member.CampaignId);
    }

    Map<Id,Campaign> campaigns = new Map<Id,Campaign>([select id, name from Campaign where id in :campaignIds]);

    // Construct a Set of dealer external Ids using the campaign to determine whether to look for US or Canadian dealers.
    for (CampaignMember member : Trigger.new) {
        if (member.Dealer_Code__c != null) {
            camp = campaigns.get(member.CampaignId);
            if (camp.Name.startsWith('ServiceMarketing_NCI')) {
                dealerExternalIds.add(member.Dealer_Code__c + System.Label.Dealer_Canada);
            } else {
                dealerExternalIds.add(member.Dealer_Code__c + System.Label.Dealer_USA);
            }
        }
    }

    List<Account> accList = new List<Account>([select PersonContactId, TMS_Customer_ID__c
                                               , Overdue_Service_Call_Count__c
                                               , Service_Followup_Call_Count__c
                                               , Welcome_Call_Count__c
                                               , Warranty_Followup_Call_Count__c  
                                               from Account 
                                               where TMS_Customer_ID__c  in: customerIds]);
    
    List<Vehicle__c> vehicles = new List<Vehicle__c>([select id, Vehicle_Identification_Number__c 
                                                      from Vehicle__c
                                                      where Vehicle_Identification_Number__c in :vins
                                                      ]);
                                                      
    List<Account> dealers = new List<Account>([select id, Dealer_Code__c
                                               from Account
                                               where Dealer_External_Id__c in :dealerExternalIds]);

    // Loop through CampaignMembers in Trigger.new and set the ContactId, Vehicle__c, Dealer__c for each
    for (CampaignMember member : Trigger.new) {
        for(Account acc: accList){
            if(member.Customer_ID__c == acc.TMS_Customer_ID__c ){
                member.ContactId = acc.PersonContactId;
                
                // Set Call_Attempt_Number__c to the appropriate count from Account.
                if(member.Service_Marketing_Call_Type__c == System.Label.NSC){
                    if (acc.Overdue_Service_Call_Count__c == null) {
                        acc.Overdue_Service_Call_Count__c = 0;
                    }
                    acc.Overdue_Service_Call_Count__c++;
                    member.Call_Attempt_Number__c = acc.Overdue_Service_Call_Count__c;
                }
                else if(member.Service_Marketing_Call_Type__c == System.Label.SFC){
                    if (acc.Service_Followup_Call_Count__c == null) {
                        acc.Service_Followup_Call_Count__c = 0;
                    }
                    acc.Service_Followup_Call_Count__c++;
                    member.Call_Attempt_Number__c = acc.Service_Followup_Call_Count__c;
                }
                else if(member.Service_Marketing_Call_Type__c == System.Label.WLC){
                    if (acc.Welcome_Call_Count__c == null) {
                        acc.Welcome_Call_Count__c = 0;
                    }
                    acc.Welcome_Call_Count__c++;
                    member.Call_Attempt_Number__c = acc.Welcome_Call_Count__c;
                }
                else if(member.Service_Marketing_Call_Type__c == System.Label.WFC)
                {
                    if(acc.Warranty_Followup_Call_Count__c == null)
                    {
                        acc.Warranty_Followup_Call_Count__c = 0;    
                    }
                    acc.Warranty_Followup_Call_Count__c++;
                    member.Call_Attempt_Number__c = acc.Warranty_Followup_Call_Count__c;
                }
            }
        }
        for(Vehicle__c vehicle : vehicles) {
            if(member.Vehicle_Identification_Number__c == vehicle.Vehicle_Identification_Number__c)
                member.Vehicle__c = vehicle.id;
        }
        for(Account dealer : dealers) {
            if((member.Dealer_Code__c) == dealer.Dealer_Code__c)
                member.Dealer__c = dealer.id;
        }
    }     
    
    List<CampaignMember> mems = new List<CampaignMember>();
    List<Contact> conts = new List<Contact>();
    
    for (CampaignMember member : Trigger.new) {
        if (member.ContactId == null) {
           errors.add(new Error_Log__c(Record_Type__c = 'CampaignMember Before', 
                                        Error_Message__c = 'missing contactid for this record:' + member.Customer_ID__c, 
                                        TimeStamp__c = System.now(), 
                                        Operation_Name__c = 'Before campaign memberbefore operation', 
                                        Source__c='Salesforce', 
                                        Log_Type__c = 'Error', 
                                        Log_Level__c = 1));
               contact nc = new contact(firstname='Auto-generated contact',lastname='auto');
               
               mems.add(member);
               
               conts.add(nc);
               
         }
    }
    if (!conts.isEmpty()){
        Database.SaveResult[] sr = Database.insert(conts,false);
        Integer cnt = 0;
        for (Database.SaveResult tsr : sr) {
               if (tsr.isSuccess()) {
                   
                   mems[cnt].contactid = tsr.getId();
               }
            cnt++;
       }
     }  
 
    if (!errors.isEmpty()) {            
        Database.insert(errors,false);
    }
    
}