@isTest 
private class D360_Webservice_Test{
    Static{
     
        Closed_Dealer_Case_Summary__c cdcs1 = new Closed_Dealer_Case_Summary__c(
            Dealer_division__c = 'Nissan',
            Sales_Count_Current_Month__c = 2,
            Sales_Count_Month_1__c = 2,
            Sales_Count_Month_2__c = 2,
            Sales_Count_Month_3__c = 2,
            Sales_Count_Month_4__c = 2,
            Sales_Count_Month_5__c = 2,
            Sales_Count_Month_6__c = 2,
            Sales_Count_Month_7__c = 2,
            Sales_Count_Month_8__c = 2,
            Sales_Count_Month_9__c = 2,
            Sales_Count_Month_10__c = 2,
            Sales_Count_Month_11__c = 2,
            Sales_Count_Month_12__c = 2,
            Service_Count_Current_Month__c = 2,
            Service_Count_Month_1__c = 2,
            Service_Count_Month_2__c = 2,
            Service_Count_Month_3__c = 2,
            Service_Count_Month_4__c = 2,
            Service_Count_Month_5__c = 2,
            Service_Count_Month_6__c = 2,
            Service_Count_Month_7__c = 2,
            Service_Count_Month_8__c = 2,
            Service_Count_Month_9__c = 2,
            Service_Count_Month_10__c = 2,
            Service_Count_Month_11__c = 2,
            Service_Count_Month_12__c = 2,
            Buyback_Count_Current_Month__c = 2,
            Buyback_Count_Month_1__c = 2,
            Buyback_Count_Month_2__c = 2,
            Buyback_Count_Month_3__c = 2,
            Buyback_Count_Month_4__c = 2,
            Buyback_Count_Month_5__c = 2,
            Buyback_Count_Month_6__c = 2,
            Buyback_Count_Month_7__c = 2,
            Buyback_Count_Month_8__c = 2,
            Buyback_Count_Month_9__c = 2,
            Buyback_Count_Month_10__c = 2,
            Buyback_Count_Month_11__c = 2,
            Buyback_Count_Month_12__c = 2);
        insert cdcs1;
        
        Closed_Dealer_Case_Summary__c cdcs2 = new Closed_Dealer_Case_Summary__c(
            Dealer_division__c = 'Infiniti',
            Sales_Count_Current_Month__c = 2,
            Sales_Count_Month_1__c = 2,
            Sales_Count_Month_2__c = 2,
            Sales_Count_Month_3__c = 2,
            Sales_Count_Month_4__c = 2,
            Sales_Count_Month_5__c = 2,
            Sales_Count_Month_6__c = 2,
            Sales_Count_Month_7__c = 2,
            Sales_Count_Month_8__c = 2,
            Sales_Count_Month_9__c = 2,
            Sales_Count_Month_10__c = 2,
            Sales_Count_Month_11__c = 2,
            Sales_Count_Month_12__c = 2,
            Service_Count_Current_Month__c = 2,
            Service_Count_Month_1__c = 2,
            Service_Count_Month_2__c = 2,
            Service_Count_Month_3__c = 2,
            Service_Count_Month_4__c = 2,
            Service_Count_Month_5__c = 2,
            Service_Count_Month_6__c = 2,
            Service_Count_Month_7__c = 2,
            Service_Count_Month_8__c = 2,
            Service_Count_Month_9__c = 2,
            Service_Count_Month_10__c = 2,
            Service_Count_Month_11__c = 2,
            Service_Count_Month_12__c = 2,
            Buyback_Count_Current_Month__c = 2,
            Buyback_Count_Month_1__c = 2,
            Buyback_Count_Month_2__c = 2,
            Buyback_Count_Month_3__c = 2,
            Buyback_Count_Month_4__c = 2,
            Buyback_Count_Month_5__c = 2,
            Buyback_Count_Month_6__c = 2,
            Buyback_Count_Month_7__c = 2,
            Buyback_Count_Month_8__c = 2,
            Buyback_Count_Month_9__c = 2,
            Buyback_Count_Month_10__c = 2,
            Buyback_Count_Month_11__c = 2,
            Buyback_Count_Month_12__c = 2);
        insert cdcs2;
    }
    static testMethod void testDoGet0() {
    
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '0');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
  
    static testMethod void testDoGet1() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '1');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGet2() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '2');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGet3() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '3');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGet4() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '4');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGet5() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '5');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGet6() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '6');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGet7() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '7');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGet8() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '8');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGet9() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '9');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGet10() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '10');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGet11() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '11');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGet12() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Nissan');
     req.addParameter('month', '12');
     req.addParameter('type', 'buyback');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales0() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '0');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales1() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '1');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales2() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '2');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales3() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '3');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales4() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '4');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales5() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '5');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales6() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '6');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales7() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '7');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales8() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '8');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales9() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '9');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales10() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '10');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales11() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '11');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetsales12() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '12');
     req.addParameter('type', 'sales');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice0() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '0');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice1() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '1');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice2() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '2');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice3() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '3');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice4() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '4');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice5() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '5');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice6() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '6');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice7() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '7');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice8() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '8');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice9() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '9');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice10() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '10');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice11() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '11');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
    static testMethod void testDoGetservice12() {   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
         
    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/d360data';  
    req.httpMethod = 'GET';
     req.addParameter('division', 'Infiniti');
     req.addParameter('month', '12');
     req.addParameter('type', 'service');
        
    RestContext.request = req;
    RestContext.response = res;
 
    D360_WebService.ReturnClass results = D360_WebService.doGet();
    
   }
    
 

}