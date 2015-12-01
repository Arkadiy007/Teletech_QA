public class sObjectFactory {
    
	public static Id supplierRT = RecordtypeUtil.getObjectRecordTypeId(Account.sObjectType, 'Supplier');
	public static Id plantRT = RecordtypeUtil.getObjectRecordTypeId(Account.sObjectType, 'Plant');
    

    public static Sorting_Report__c createSR(Part__c part){
        Sorting_Report__c sr = new Sorting_Report__c();
        sr.Average_Sort_Time_Per_Part__c = 10;
        sr.EQA_Average_Sort_Time_Per_Part__c = 10;
        sr.Certified_NEC_RAN__c = 'Test';
        sr.Certified_Supplier_RAN_Number__c = 'Test';
        sr.Current_Owner__c = 'Supplier';
        sr.Explanation__c = 'Test';
        sr.Future_Shipment_RAN__c = true;
        sr.Issue_Type__c = 'Defect';
        sr.Last_Suspect_RAN__c = true;
        sr.Name_of_Responder__c = 'Vasiliy';
        sr.NEC_Ship_Date__c = Date.today();
        sr.NEC_Sort_Required__c  = true;
        sr.Reason__c = 'Defect';
        sr.Reason_for_Status__c = 'Reason__c';
        sr.Ship_Date__c = Date.today();
        sr.Sorting_Report_Number__c = 'Sorting Report Number';
        sr.Status__c = 'Batch_Techline_New_Case_DataLoad';
        sr.Supplier_Response__c = 'ResetPasswordResult';
        sr.Technical_Issue_Location__c = 'ZASX';
        sr.Part__c = part.Id;

        return sr;
    }

    public static Sorting_Report_Item__c createSRI(Sorting_Report__c sr, Part_Incident_Report__c pir){
        Sorting_Report_Item__c sri = new Sorting_Report_Item__c();
        sri.Mixed_Part__c = 12;
        sri.Mixed_Part_Costs__c = 100;
        sri.No_Good__c = 11;
        sri.No_Good_Material_Costs__c = 100;
        sri.Part_Incident_Report__c = pir.Id;
        sri.Sorting_Report__c = sr.Id;
        sri.Total_Quantity_Sorted__c = 12;

        return sri;
    
    }

    public static Part_Incident_Report__c createPIR(String pirNumber, Part__c part){
        Part_Incident_Report__c pir = new Part_Incident_Report__c();
        pir.PIR_Number__c = pirNumber;
        pir.Part__c = part.id;
        pir.PIR_Status__c = 'Open';
        pir.Issue_Type__c = 'Logistics';

        return pir;
    }
    
    public static Monetary_Claim__c createMC(Sorting_Report__c sr, Part_Incident_Report__c pir){
        Monetary_Claim__c mc = new Monetary_Claim__c();
        
        if (sr != null){
                mc.Sorting_Report__c = sr.Id;
        }
        if (pir != null){
                mc.Part_Incident_Report__c = pir.Id;
        }
        

        mc.Closed_Date__c = Date.today().addDays(8);
        mc.Monetary_Claim_Number__c = 'XXX';
        mc.Account_Coding__c = 'Test';
        mc.Claim_Status__c = 'Open';

        return mc;

    }
    
    public static Part__c createPart(){
        Part__c part = new Part__c();
        part.Abolish_Date__c = Date.today();
        part.Base_Part_Number__c = 'Test';
        part.Customer_Number__c = 'CustomerNum';
        part.Destination_Country__c = 'Brasil';
        part.HARM_Code__c= ' Task';
        part.Part_Number__c = 'PST-8888';

    
        return part;
    }

	
	public static Account createSupplierAccount(){
		Account supplier = new Account();
		supplier.Name = 'Test Supplier';
		supplier.Supplier_Code__c = 'XXX-23';
		supplier.Global_Supplier_Number__c = 'GSN-1';
		supplier.RecordTypeId = supplierRT;
		return supplier;
	} 
	
	public static Account createPlantAccount(){
		Account plant = new Account();
		plant.Name = 'Test Plant';
		plant.Plant__c = 'St. Petersburg';
		plant.RecordTypeId = plantRT;
		return plant;
	} 

	public static Contact createContact(Id accountId){
		Contact plantContact = new Contact();
		plantContact.Lastname = 'Bezuhoff';
		plantContact.AccountId = accountId;
		plantContact.Email = 'secret@secret.com';
		return plantContact;
	}
 }