public class WarrantyInformationWrapper{

    public Integer sNo{get; set;}
    public Warranty_Information__c warrantyInfo{get; set;}

    public WarrantyInformationWrapper(Integer i, Warranty_Information__c wrty){    
        sNo = i;
        warrantyInfo = wrty;
    }
}