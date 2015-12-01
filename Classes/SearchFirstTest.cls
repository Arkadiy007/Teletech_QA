//  Copyright (c) 2009, Christoph Foeckeler, Sales Engineering, Salesforce.com Inc.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//    1.    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
//    2.    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
//          documentation and/or other materials provided with the distribution.
//    3.    Neither the name of the salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this
//          software without specific prior written permission. 
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 
@isTest
private class SearchFirstTest {

    static testMethod void myUnitTest() {
        Test.starttest();
        PageReference testPage = Page.searchfirst;
        Test.setCurrentPage(testPage);
        
        SearchFirstController myController = new SearchFirstController();
        
		myController.searchCustomerId = '';
        myController.searchFirstname = '';
        myController.searchLastname = '';
        myController.searchCompany = '';
        myController.searchPhone = '';
        myController.searchEmail = '';
        myController.noLeadResult = true;
        myController.noContactResult = true;
        myController.noAccountResult = true;
        myController.emptyLeadList = true;
        myController.emptyContactList = true;
        myController.emptyAccountList = true;
        myController.numLeads = 0;
        myController.numContacts = 0;
        myController.numAccounts = 0;
        myController.errorShow = true;
        myController.errorTitle = '';
        myController.errorMessage = '';
        myController.errorSeverity = '';
             
        myController.getresultListLeads();
        myController.getresultListContacts();
        myController.getresultListAccounts();  
        System.assertEquals('',myController.searchFirstname);
        System.assertEquals('',myController.searchLastname);
        System.assertEquals('',myController.searchCompany);
        System.assertEquals('',myController.searchPhone);
        System.assertEquals('',myController.searchEmail);
        System.assert(myController.noLeadResult);
        System.assert(myController.noContactResult);
        System.assert(myController.noAccountResult);
        System.assert(myController.emptyLeadList);
        System.assert(myController.emptyContactList);
        System.assert(myController.emptyAccountList);
        System.assert(myController.errorShow);
        System.assertEquals('',myController.errorTitle);
        System.assertEquals('',myController.errorMessage);
        System.assertEquals('',myController.errorSeverity);

        myController.search();
        myController.createNewLead();      
        myController.createNewContact(); 
        myController.createNewAccount(); 

        myController.searchFirstname = 'Test';
        myController.searchLastname = '';
        myController.searchCompany = 'Test';
        myController.searchPhone = '345345';
        myController.searchEmail = '435345@test.com';
        myController.search();

        myController.searchFirstname = '';
        myController.searchLastname = 'Test';
        myController.searchCompany = 'Test';
        myController.searchPhone = '345345';
        myController.searchEmail = '435345@test.com';
        myController.search();

        myController.searchFirstname = 'Test';
        myController.searchLastname = 'Test';
        myController.searchCompany = 'Test';
        myController.searchPhone = '345345';
        myController.searchEmail = '435345@test.com';
        myController.search();    
        
        myController.searchFirstname = '';
        myController.searchLastname = '';
        myController.searchCompany = 'x';
        myController.searchPhone = '';
        myController.searchEmail = '';
        myController.search();  
        
        myController.createNewLead();      
        myController.createNewContact(); 
        myController.createNewAccount(); 
        myController.reset();
        Test.stoptest();
    }
}