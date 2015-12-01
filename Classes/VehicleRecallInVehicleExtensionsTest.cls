@isTest
public class VehicleRecallInVehicleExtensionsTest{

    static testmethod void myUnitTest(){
               
        Account acc = new Account();
        acc.Name = 'Test Account1234';
        Insert acc;
                       
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Name='Test Vehicle1234';
        vehicle.Make_Name__c = 'Nissan';
        vehicle.Model_Year__c = '2015';
        vehicle.Model_Line_Name__c = 'Altima';
        vehicle.In_Service_Date__c= Date.parse('04/04/2015') ;
        insert vehicle;
        
        Vehicle_Retail_Sale__c vrs = new Vehicle_Retail_Sale__c();
        vrs.Vehicle_Identification_Number__c = vehicle.Id;
        vrs.Owner_Id__c = acc.Id;
        vrs.Purchase_Date__c = Date.parse(System.Label.Purchase_Start_Date);
        insert vrs;
              
        Test.startTest();        
        
        ApexPages.StandardController controller = new ApexPages.StandardController(vehicle);
        VehicleRecallInVehicleExtensions inVehicleExtn = new VehicleRecallInVehicleExtensions(controller);    
        
            
        Test.stopTest();
        
        if(Label.Show_JD_Power_Message == 'Yes'){        
        System.assert(inVehicleExtn.showPowerCust); 
        }else{
        	 System.assert(!inVehicleExtn.showPowerCust);
        }  
        
        
    }

}