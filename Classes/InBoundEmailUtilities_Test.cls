@isTest private class InBoundEmailUtilities_Test {


  static testMethod void testMe() {
      
      Notor__c theNotorCase = new Notor__c();
        theNotorCase.Web_Email__c= 'test@test.com';
        theNotorCase.Web_Name__c = 'Test Test';
        theNotorCase.Status__c = 'New';
        theNotorCase.Case_Origin__c = 'Email Service';
        theNotorCase.Subject__c = 'notor test subject';
        theNotorCase.HTMLDescription__c = 'test';
        theNotorCase.Description__c = 'test';
        insert theNotorCase;

        Notor__c c = [Select id from Notor__c where web_email__c='test@test.com' limit 1];
       
      // create email
      Messaging.InboundEmail email = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      email.subject = 'Test Subject';
      email.fromname = 'Test Email';
      email.fromAddress = 'test@email.com';
      env.fromAddress = 'test@email.com';
      
      
      inboundEmailSettings__c ies = new inboundEmailSettings__c();
      ies.SetupOwnerId = Userinfo.getOrganizationId();
      ies.queueName__c = 'NOTOR';
      ies.sendAutoReplies__c = true;
      ies.emailReferenceIdString__c = 're';
      insert ies;
      
      // call the email service class and test it with the data in the testMethod
      EmailInboundHandler emailProcess = new EmailInboundHandler();
      emailProcess.handleInboundEmail(email, env);

      ies.sendAutoReplies__c = true;
      upsert ies;

      Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
      email2.subject = 'Test Subject ' + '[re:'+c.id + ':]';
      email2.fromname = 'Test Email';
      email2.fromAddress = 'test@email.com';
      env2.fromAddress = 'test@email.com';
      

      //EmailInboundHandler emailProcess = new EmailInboundHandler();
      emailProcess.handleInboundEmail(email2, env2);


      //System.assertEquals(contact.firstName,'FirstName');

   }
   
   
}