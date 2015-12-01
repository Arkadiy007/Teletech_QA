/**********************************************************************
Name: D360_WebService
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This Class queries data to return to Square Root for
Dealer 360 App based on REST api
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr         03/03/2014 Created
***********************************************************************/
@RestResource(urlMapping='/d360data/*')
global with sharing class D360_WebService {

@HttpGet
  global static ReturnClass doget() {

      String dv = RestContext.request.params.get('division');
      String mo = RestContext.request.params.get('month');
      String ct = RestContext.request.params.get('type');
      Integer monthcount = integer.valueOf(mo) * -1;
      Date fromdate = system.today().toStartOfMonth().AddMonths(monthcount);
      Date todate = fromdate.addMonths(1).addDays(-1);
      List<Closed_Dealer_Case_Summary__c> results = new List<Closed_Dealer_Case_Summary__c>();
      
      Try{
      List<Closed_Dealer_Case_Summary__c> allresults = [Select Id, Sales_Count_Current_Month__c, Sales_Count_Month_1__c, Sales_Count_Month_2__c,
            Sales_Count_Month_3__c, Sales_Count_Month_4__c, Sales_Count_Month_5__c, Sales_Count_Month_6__c,
            Sales_Count_Month_7__c, Sales_Count_Month_8__c, Sales_Count_Month_9__c, Sales_Count_Month_10__c,
            Sales_Count_Month_11__c, Sales_Count_Month_12__c, Service_Count_Current_Month__c, Service_Count_Month_1__c,
            Service_Count_Month_2__c, Service_Count_Month_3__c, Service_Count_Month_4__c, Service_Count_Month_5__c,
            Service_Count_Month_6__c, Service_Count_Month_7__c, Service_Count_Month_8__c, Service_Count_Month_9__c,
            Service_Count_Month_10__c, Service_Count_Month_11__c, Service_Count_Month_12__c, Buyback_Count_Current_Month__c,
            Buyback_Count_Month_1__c, Buyback_Count_Month_2__c, Buyback_Count_Month_3__c, Buyback_Count_Month_4__c,
            Buyback_Count_Month_5__c, Buyback_Count_Month_6__c, Buyback_Count_Month_7__c, Buyback_Count_Month_8__c,
            Buyback_Count_Month_9__c, Buyback_Count_Month_10__c, Buyback_Count_Month_11__c, Buyback_Count_Month_12__c,
            Dealer_Code__c, Case_Count__c, Case_Closed_Date_From__c, Case_Closed_Date_To__c
            from Closed_Dealer_Case_Summary__c where Dealer_Division__c = :dv];
            
      if(mo == '0'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Current_Month__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Current_Month__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Current_Month__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }
      
      if(mo == '1'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Month_1__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Month_1__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Month_1__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }
      
      if(mo == '2'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Month_2__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Month_2__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Month_2__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }
      
      if(mo == '3'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Month_3__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Month_3__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Month_3__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }
      
      if(mo == '4'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Month_4__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Month_4__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Month_4__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }
      
      if(mo == '5'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Month_5__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Month_5__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Month_5__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }
      
      if(mo == '6'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Month_6__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Month_6__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Month_6__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }
      
      if(mo == '7'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Month_7__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Month_7__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Month_7__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }
      
      if(mo == '8'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Month_8__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Month_8__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Month_8__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }
      
      if(mo == '9'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Month_9__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Month_9__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Month_9__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }
          
      if(mo == '10'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Month_10__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Month_10__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Month_10__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }
      
      if(mo == '11'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Month_11__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Month_11__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Month_11__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }
      
      if(mo == '12'){           
         if(ct == 'sales'){          
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Sales_Count_Month_12__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'service'){    
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Service_Count_Month_12__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
             }
          if(ct == 'buyback'){
                for(Closed_Dealer_Case_Summary__c cdcs : allresults){
                    results.add(New Closed_Dealer_Case_Summary__c(
                        Case_Count__c = cdcs.Buyback_Count_Month_12__c,
                        Dealer_Code__c = cdcs.Dealer_Code__c));}
          }
      }


      for(Closed_Dealer_Case_Summary__c cdcs : results){
          cdcs.Case_Closed_Date_From__c = fromdate;
          cdcs.Case_Closed_Date_To__c = todate;
          }
       
          
      return new ReturnClass ('true', 'Query executed successfully.', results);
      }
     
      Catch (exception e){
          return new ReturnClass('false', e.getMessage(), null);          
    }
  }
      
      Global Class ReturnClass {
          
        global String success;
        global String message;
        global List<Closed_Dealer_Case_Summary__c> records;

  global ReturnClass(String success, String message, List<Closed_Dealer_Case_Summary__c> records) {
  this.success = success;
  this.message = message;
  this.records = records;  
          
      }
      }
}