public class Account_Agreement_Controller { 
    

        private final static String TEMPLATE_GROUP_NAME= 'Account_Agreement';

        public String accountId {get; set;} 
        public String accountName {get; set;} 
        public String contactId {get; set;}
        public String congaTemplate {get; set;}
        public String userName {get; set;}
        public String userPhone {get; set;}
        public boolean hasError {get; set;}
        public string abbrName {get; set;}
        public string quantityVal {get; set;}

        private APXTConga4__Conga_Template__c[] congaTemplates {get; set;}
        public SelectOption[] congaTemplateSO {get; set;}
        
        public SelectOption[] salutationSO {
                get {
                        if (null == salutationSO) {
                                salutationSO = new SelectOption[]{};
                                salutationSO.add(new SelectOption('Dr.', 'Dr.'));
                                salutationSO.add(new SelectOption('Miss', 'Miss'));
                                salutationSO.add(new SelectOption('Mr.', 'Mr.'));
                                salutationSO.add(new SelectOption('Mrs.', 'Mrs.'));
                                salutationSO.add(new SelectOption('Ms.', 'Ms.'));
                                salutationSO.add(new SelectOption('Rabbi', 'Rabbi'));
                                salutationSO.add(new SelectOption('Rev.', 'Rev.'));
                                salutationSO.add(new SelectOption('Prof.', 'Prof.'));
                                return salutationSO;
                        }
                        return salutationSO; 
                }
                set;
        }
        
        public String salutation {get; set;}
        
        public Account_Agreement_Controller(ApexPages.StandardController controller) {
                try{
                hasError = false;
                abbrName = '';
                quantityVal = '';       
                accountId =  ((Account)controller.getRecord()).Id;   //System.currentPagereference().getParameters().get('id');

                Account[] currentAccount = [SELECT Id, Name, Company_Abbr__c, Quantity__c, (SELECT Id FROM Contacts WHERE Primary_Flag__c = true Limit 1) FROM Account WHERE Id =: accountId LIMIT 1]; 
                
                accountId = currentAccount[0].Id;
                if(currentAccount[0].Contacts.size() <= 0){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, Label.Primary_Contact_Missing));            
                }else{
                        contactId = currentAccount[0].Contacts[0].Id;
                }
                
                accountName = currentAccount[0].Name;
                if(currentAccount[0].Company_Abbr__c != null && currentAccount[0].Company_Abbr__c == currentAccount[0].Name){
                        abbrName = currentAccount[0].Name;
                }else{
                        abbrName = currentAccount[0].Name + ' ("'+currentAccount[0].Company_Abbr__c+'")';
                }
                if(currentAccount[0].Quantity__c != null && currentAccount[0].Quantity__c != '' && currentAccount[0].Quantity__c.contains('(')){
                        String quant = currentAccount[0].Quantity__c;
                        quantityVal = quant.substring(quant.indexOf('(') +1, quant.indexof(')'));
                        System.debug('quantityVal:::'+quantityVal);
                }
                congaTemplates =[SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Template_Group__c =: TEMPLATE_GROUP_NAME];
                if (null != congaTemplates && congaTemplates.size() > 0) {
                        congaTemplateSO = new SelectOption[]{};
                        for (APXTConga4__Conga_Template__c t : congaTemplates) {
                                congaTemplateSO.add (new SelectOption(t.id, t.APXTConga4__Name__c));
                        }
                }

                userName = UserInfo.getFirstName().capitalize() + ' ' + UserInfo.getLastName().capitalize();
                String userId = UserInfo.getUserId();
                User[] currentUser = [SELECT Phone FROM User WHERE Id =: userId LIMIT 1];
                userPhone = currentUser[0].Phone;
                
                
                }catch(Exception ex){
                        hasError = true;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
                }
        }
        
        public PageReference generateAgreement() {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'sal = ' + salutation));
                return ApexPages.currentPage();
        }

        public PageReference back() {
                PageReference pgRef = new PageReference('/'+accountId);
                return pgRef;
        }
}