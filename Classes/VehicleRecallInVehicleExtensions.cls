public class VehicleRecallInVehicleExtensions {
    
    public boolean showPowerCust{get; set;}
    public boolean showBrandedMsg{get; set;}
    public string brandedMsg{get; set;}
    public boolean showExclusionMsg{get; set;}
    public boolean startPolling {get; set;}
    Vehicle__c vehObj = new Vehicle__c();
    Id vehId;
    public integer counter {get; set;}
        
    public VehicleRecallInVehicleExtensions(ApexPages.StandardController controller) {
        showPowerCust = false;
        showBrandedMsg = false;
        startPolling = true;
        counter = 0;
        vehId = ((Vehicle__c)controller.getRecord()).Id;
        loadVehicleData();
       
    }
        
        
        public void pollAction(){
                loadVehicleData();
        }
        
        private void loadVehicleData(){
                vehObj = [Select Id, Branded_Title__c,Warranty_Exclusion__c from Vehicle__c where Id =:vehId ];
        Id vehId = vehObj.Id;
        counter++;
        if(vehObj.Branded_Title__c && vehObj.Warranty_Exclusion__c){
                showBrandedMsg = true;
                brandedMsg = Label.Vehicle_Branded_Warranty_Exclusion_Message;
        }else{
                
                if(vehObj.Warranty_Exclusion__c){
                        showBrandedMsg = true;
                        startPolling = false;
                        brandedMsg = Label.Vehicle_Warranty_Exclusion_Message;
                }else if(vehObj.Branded_Title__c){
                        showBrandedMsg = true;
                        brandedMsg = Label.Vehicle_Branded_Warranty_Message;
                        startPolling = false;
                }
        }
        
        Date purchStartDt = Date.parse(Label.Purchase_Start_Date);
        Date purchEndDt = Date.parse(Label.Purchase_End_Date);
        
        if(Label.Show_JD_Power_Message == 'Yes'){
        List<Vehicle_Retail_Sale__c> vehRetSaleList =  [Select Id, Vehicle_Identification_Number__c, Purchase_Date__c From Vehicle_Retail_Sale__c
                                                        where Vehicle_Identification_Number__c =:vehId Limit 40000];
        
        if(vehRetSaleList != null && vehRetSaleList.size() > 0){
                for(Vehicle_Retail_Sale__c vrs : vehRetSaleList){
                if(vrs.Purchase_Date__c >= purchStartDt && vrs.Purchase_Date__c <= purchEndDt){
                                showPowerCust = true;                                   
                        }            
                }
        } 
        }
        
        if(counter > 3){
                startPolling = false;
        }      
        }
}