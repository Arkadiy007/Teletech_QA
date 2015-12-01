public with sharing class Controller_Customer_Journey {
    public static UnitTestUtil oUtil = UnitTestUtil.getInstance();
    
    private String authLogin;
    private Map<ID, username__c> mapLCJUserNames;
    public Controller_Customer_Journey(ApexPages.StandardController controller) {
        LCJUserNames = [select ID, Customer_Name__c, Customer_Id__c, Name, ReservationID__c, Portal_User_Name__c, Person_Hash_ID__c, Portal_Link__c, Integration_Id__c, CreatedDate 
                        from Username__c 
                        where Customer_Name__c = : controller.getRecord().ID and Portal_Type__c = 'Leaf'];
        mapLCJUserNames = new Map<ID, Username__c>(LCJUserNames);

        User theUser = [Select LCJ_Login__c from User where id =: userinfo.getUserId()];
        if (theUser.LCJ_Login__c != null)
            authLogin = theUser.LCJ_Login__c;
    }

    public ID SelectedUserNameID {get; set;}

    public PageReference gotoCJTargetURL() {
        // Get the login name to pass to the Leaf webservice to return a token. 
        String personHashId = null;
        Long cdbContactId = null;

        Username__c selectedUserName = mapLCJUserNames.get(SelectedUserNameID);
        if (selectedUserName.Person_Hash_ID__c != null)         
            personHashId = selectedUserName.Person_Hash_ID__c;

        if (selectedUserName.Customer_Id__c != null)
            cdbContactId = Long.valueOf(selectedUserName.Customer_Id__c);

        // Use the login name to get a token.
        WS_SSLCG.SoapSsoAuthServicePort obj = new WS_SSLCG.SoapSsoAuthServicePort();

/************************************************************/
        obj.inputHttpHeaders_x=new Map<String,String>();
        Blob headerValue = Blob.valueOf(system.label.WS_End_Point_UserName + ':' + system.label.WS_End_Point_Password);
        String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
        System.debug('Authorization - '+authorizationHeader);
        obj.inputHttpHeaders_x.put('Authorization',authorizationHeader);
/************************************************************/

        String token;
        if (oUtil.isUnitTesting)
            token = personHashId + cdbContactId;
        else {
            try {
                System.debug('call out parameters: ' + authLogin + ', ' + personHashId + ', ' + cdbContactId);
                token = obj.create(authLogin, personHashId, cdbContactId);
            } catch(Exception e) {
                token = obj.create(authLogin,'', 0);    
            }
        }
        
        // Construct the URL to redirect to using the returned token
        system.debug('token: '  + token);
        String CJTargetURL = system.Label.CJ_Target_URL;
        CJTargetURL = CJTargetURL.replace('[token]', token);
        CJTargetURL = CJTargetURL.replace('[relative uri]', '');
        System.debug('CJTargetURL: '  + CJTargetURL);
        return new PageReference(CJTargetURL);
    }
    
    public List<Username__c> LCJUserNames {get; private set;}

    static testmethod void testController_Customer_Journey() {
        oUtil.isUnitTesting = true;
        oUtil.mockResponse = 'Success1';

        RecordType personType = [select id, name from recordtype where name = 'Maritz' and sobjecttype = 'Account' limit 1];
        delete [Select id from Account where customer_id__c = '12345'];
        Account a = new Account(LastName = 'test', customer_id__c = '12345', RecordTypeId = personType.id);
        insert a;

        Username__c u = new Username__c(Customer_Name__c = a.Id, Name = 'myUserName', Portal_User_Name__c = 'myUserName', Person_Hash_ID__c ='PERSON_Gibberish=', Portal_Type__c = 'Leaf', Integration_Id__c = 'PERSON_Gibberish=Nissan Owner');
        insert u;

        Username__c u2 = new Username__c(Customer_Name__c = a.Id, Name = 'myUserName2', Portal_User_Name__c = 'myUserName2', Person_Hash_ID__c ='PERSON_Gibberish2=', Portal_Type__c = 'Leaf', Integration_Id__c = 'PERSON_Gibberish2=Nissan Owner');
        insert u2;

        Test.startTest();
        Controller_Customer_Journey rec = new Controller_Customer_Journey(new ApexPages.StandardController(a));
        system.assert(rec.LCJUserNames.size() == 2);
        rec.SelectedUserNameID = u.ID;

        PageReference p = rec.gotoCJTargetURL();
        Username__c selectedUser = [select Customer_ID__c, Person_Hash_ID__c from Username__c where ID = :u.ID];
        System.assert(EncodingUtil.urlDecode(p.getURL(),'UTF-8').contains(selectedUser.Person_Hash_ID__c + selectedUser.Customer_ID__c));
        Test.stopTest();
    }
}