public class ServiceHistoryWrapHelper{

    public Integer sNo{get; set;}
    public Service_Repair_History__c servicehistory{get; set;}

    public ServiceHistoryWrapHelper(Integer i, Service_Repair_History__c shist){    
        sNo = i;
        servicehistory = shist;
    }

}