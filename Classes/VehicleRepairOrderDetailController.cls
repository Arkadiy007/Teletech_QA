public class VehicleRepairOrderDetailController {
    
    public Service_Repair_History__c servInfo{ get; set; }
    
    
    public VehicleRepairOrderDetailController(){
        servInfo = new Service_Repair_History__c();
        
        Map<String, String> pageParam = ApexPages.currentPage().getParameters();
        
        if(!pageParam.isEmpty()){
            if(pageParam.get('desc') != null){
                servInfo.PNC_Code_Description__c = pageParam.get('desc');
            }
            if(pageParam.get('covPayType') != null){
                servInfo.Claim_Approved_Coverage_Code__c = pageParam.get('covPayType');
            }
            if(pageParam.get('transdt') != null){
                System.debug('Date::'+pageParam.get('transdt'));
                servInfo.Vehicle_Repair_Close_Date__c = Datetime.parse(pageParam.get('transdt'));
            }
            if(pageParam.get('vrOpenDt') != null && pageParam.get('vrOpenDt') != ''){
                System.debug('Date::'+pageParam.get('vrOpenDt'));
                servInfo.Vehicle_Repair_Open_Date__c =pageParam.get('vrOpenDt') != null ? Datetime.parse(pageParam.get('vrOpenDt')) : null;
            }
            if(pageParam.get('vehMileage') != null){
                servInfo.Vehicle_Mileage_Number__c = Integer.valueOf(pageParam.get('vehMileage'));
            }
            if(pageParam.get('dealerNo') != null){
                servInfo.Dealer_Number__c = pageParam.get('dealerNo');
            }
            if(pageParam.get('claimLine') != null){
                servInfo.Claim_Line_Number__c = pageParam.get('claimLine');
            }
            if(pageParam.get('woNumber') != null){
                servInfo.Dealer_Number__c = pageParam.get('woNumber');
            }
            if(pageParam.get('olStatusCode') != null){
                servInfo.Work_Order_Line_Status_Code__c = pageParam.get('olStatusCode');
            }
            if(pageParam.get('cFirstName') != null){
                servInfo.Claim_Customer_First_Name__c = pageParam.get('cFirstName');
            }
            if(pageParam.get('cLastName') != null){
                servInfo.Claim_Customer_Last_Name__c = pageParam.get('cLastName');
            }
            if(pageParam.get('cStreetAdd1') != null){
                servInfo.Claim_Customer_Street_Address1__c = pageParam.get('cStreetAdd1');
            }
            if(pageParam.get('cStreetAdd2') != null){
                servInfo.Claim_Customer_Street_Address2__c = pageParam.get('cStreetAdd2');
            }
            if(pageParam.get('cCity') != null){
                servInfo.Claim_Customer_City__c = pageParam.get('cCity');
            }
            if(pageParam.get('cState') != null){
                servInfo.Claim_Customer_State_Province__c = pageParam.get('cState');
            }
            if(pageParam.get('cZip') != null){
                servInfo.Claim_Customer_Zip__c = pageParam.get('cZip');
            }
        }
        
    }

}