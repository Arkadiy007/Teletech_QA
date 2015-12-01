/**********************************************************************
Name: TestNotor_Redirect 
Copyright © notice: Nissan Motor Company.
======================================================
Purpose: Test class for Notor_Redirect.
======================================================
History:

VERSION     AUTHOR             DATE         DETAIL
1.0 -     Vivek Batham        06/17/2015    Created

***********************************************************************/

@isTest
private class TestNotor_Redirect {
    
    
    public static testmethod void test1(){
          
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, Notor_Id__c = '12345', 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.nis', ZCA_Id__c='dwil', warranty_app_amount__c='25', warranty_vcan_delete__c=true );
        insert u;  
        
        System.runAs(u){
            
            Notor_Redirect ntrRedirect = new Notor_Redirect();
            ntrRedirect.getUrlForRedirecting();
        }
        
    }
    
 }