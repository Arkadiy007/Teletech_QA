public class ServiceHistoryTriggerHelper{
    
    public static void handleBeforeInsert(List<Service_Repair_History__c> newServHistories){
        
        Set <String> nnacodes = new Set<String>();
        Set <String> ncicodes = new Set<String>();
        Map <String,String> nnatonci = new Map<String,String>();
        
        for(Service_Repair_History__c shist : newServHistories){
            nnacodes.add(shist.Dealer_Number__c);
        }
        
        List<NNAtoNCIdealercodes__c> nnatonciq = [select NCIDealerCode__c,NNADealerCode__c from NNAtoNCIdealercodes__c where NNADealerCode__c IN :nnacodes];
        
        for (NNAtoNCIdealercodes__c nc : nnatonciq) {
            if (!nnatonci.containsKey(nc.NNADealerCode__c)) {
                nnatonci.put(nc.NNADealerCode__c,nc.NCIDealerCode__c);
                 ncicodes.add(nc.NCIDealerCode__c);
            }
        }
        Map<String, ID> dealerMap = new Map<String, ID>();
        if (ncicodes.size() > 0) {
            for (Account dealer : [Select Id, Dealer_Code__c From Account WHERE RecordType.Name IN ('Dealer','NCI - Dealer') and Dealer_Code__c in: ncicodes]) {
                if (!dealerMap.containsKey(dealer.Dealer_Code__c)) {
                    dealerMap.put(dealer.Dealer_Code__c, dealer.ID);
                }
            }
            
         }


        for(Service_Repair_History__c shist : newServHistories){
            if(shist.Complaint_Description__c != null && shist.Complaint_Description__c != ''){
                shist.Complaint_Description_2__c = shist.Complaint_Description__c;
            }else if(shist.PNC_Code_Description__c != null && shist.PNC_Code_Description__c != ''){
                shist.Complaint_Description_2__c = shist.PNC_Code_Description__c;
            }else{
               shist.Complaint_Description_2__c = shist.Primary_Operation_Code_Description__c;
            }
            if (shist.NCI_Dealer_Code__c == null && nnatonci.containsKey(shist.Dealer_Number__c)) {
                shist.NCI_Dealer_Code__c = nnatonci.get(shist.Dealer_Number__c);
                 shist.NCI_Dealer_Id__c = dealerMap.get(nnatonci.get(shist.Dealer_Number__c));
            }
        }
    
    }
    
    public static void handleBeforeUpdate(List<Service_Repair_History__c> newServHistories){
         System.debug('checking starting');
           
        Set <String> nnacodes = new Set<String>();
        Set <String> ncicodes = new Set<String>();
        
        Map <String,String> nnatonci = new Map<String,String>();
        
        
        for(Service_Repair_History__c shist : newServHistories){
            System.debug('checking ' + shist.Dealer_Number__c);
            nnacodes.add(shist.Dealer_Number__c);
        }
        
      
        
        List<NNAtoNCIdealercodes__c> nnatonciq = [select NCIDealerCode__c,NNADealerCode__c from NNAtoNCIdealercodes__c where NNADealerCode__c IN :nnacodes];
        
        for (NNAtoNCIdealercodes__c nc : nnatonciq) {
            if (!nnatonci.containsKey(nc.NNADealerCode__c)) {
                nnatonci.put(nc.NNADealerCode__c,nc.NCIDealerCode__c);
                ncicodes.add(nc.NCIDealerCode__c);
            }
        }
        Map<String, ID> dealerMap = new Map<String, ID>();
        if (ncicodes.size() > 0) {
            for (Account dealer : [Select Id, Dealer_Code__c From Account WHERE RecordType.Name IN ('Dealer','NCI - Dealer') and Dealer_Code__c in: ncicodes]) {
                if (!dealerMap.containsKey(dealer.Dealer_Code__c)) {
                    dealerMap.put(dealer.Dealer_Code__c, dealer.ID);
                }
            }
            
         }
    
        
        for(Service_Repair_History__c shist : newServHistories){
            if(shist.Complaint_Description__c != null && shist.Complaint_Description__c != ''){
                shist.Complaint_Description_2__c = shist.Complaint_Description__c;
            }else if(shist.PNC_Code_Description__c != null && shist.PNC_Code_Description__c != ''){
                shist.Complaint_Description_2__c = shist.PNC_Code_Description__c;
            }else{
               shist.Complaint_Description_2__c = shist.Primary_Operation_Code_Description__c;
            }
            if (shist.NCI_Dealer_Code__c == null && nnatonci.containsKey(shist.Dealer_Number__c)) {
                shist.NCI_Dealer_Code__c = nnatonci.get(shist.Dealer_Number__c);
                shist.NCI_Dealer_Id__c = dealerMap.get(nnatonci.get(shist.Dealer_Number__c));
            }
            
        }   
        
        
        
        
         
    }
  

}