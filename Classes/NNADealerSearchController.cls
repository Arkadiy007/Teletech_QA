public class NNADealerSearchController {
  //--------------------------------------------------------------------------
  // Properties
    public String caseId {get; set;}
    public Boolean showResend {get; Set;}
    public Case cachedCase {get; Set;}
    public NNADealerSearchController() {
        showResend = false;
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        if(caseId == null) {
            caseId = '';
        }
    }

  //--------------------------------------------------------------------------
  // Methods
    public Pagereference updateCaseAndRedicect() {
        if(caseId != ''){
            insertCase();
        }
      
        // if case not valid, show error message, otherwise redirect to case layout
        if ((false == ApexPages.hasMessages(ApexPages.Severity.ERROR)) && false == (ApexPages.hasMessages(ApexPages.Severity.WARNING))) {
            Pagereference caseDetailsPage = new Pagereference('/' + caseId);
            caseDetailsPage.setRedirect(true);
            return caseDetailsPage;
        }

        return null;
    }

    // redirect to case record
    public Pagereference redirectToCase() {
        Pagereference caseDetailsPage = new Pagereference('/' + caseId);
    caseDetailsPage.setRedirect(true);
    return caseDetailsPage;
    }

  //--------------------------------------------------------------------------
  // Helpers
    @TestVisible private Case[] dynamicQueryCase(String caseId) {
        Set<String> fields = new Set<String> {
            'Id',
            'Case_GUID__c',
            'Case_Dealer_Disposition__c',
            'RecordType.DeveloperName',
            'RecordTypeId',
            'Consent_to_send_Pii__c',
            'Preferred_Dealer__c',
            'Preferred_Dealer__r.Internet_Certified__c',
            'Origin',
            'Dealer__c'
        };

    // at first query case RecordType developer name
    Case c = [SELECT Id, RecordType.DeveloperName FROM Case WHERE Id = :caseId];

        for (USW_Case_Mappings__c mapping : [SELECT SF_Field_Name__c FROM USW_Case_Mappings__c WHERE Case_Record_Type__c = :c.RecordType.DeveloperName]) {
            String field = mapping.SF_Field_Name__c;

            if (field != null && field.trim().length() != 0 && !field.startsWith('"')) {
                fields.add(field);
            }
        }
        

        return (Case[]) Database.query(
            String.format('SELECT {0}, (SELECT Id, Notes__c, Call_Type__c FROM Calls__r), (SELECT Id FROM LiveChatTranscripts) FROM Case WHERE Id = :caseId', new String[] { String.join(new List<String>(fields), ',') })
        );
    }

    @TestVisible private void insertCase(){
        try {
            if (!showResend){
                cachedCase = dynamicQueryCase(caseId)[0];
            }

            if (!String.isBlank(cachedCase.Case_GUID__c) && !showResend){
                showResend = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'Case was already sent to Urban Science Web Service. Press \'Resend\' button to resend case');
                ApexPages.addMessage(myMsg);
                return;
            }
            
            String xmlBody = UrbanScienceCaseMappingHelper.generateAdfXMLFromCase(cachedCase);
            if(String.isNotEmpty(xmlBody)){
                NNALeadServicesHandler.LeadApprovalResponse resp = NNALeadServicesHandler.callLeadService(xmlBody);
                System.debug(resp);
            
           
               
                // create attach
                if (Dealer_Backfeed_XML_Enabled__c.getInstance() != null &&  Dealer_Backfeed_XML_Enabled__c.getInstance().Enabled__c){
                     Attachment attach = createAttach(xmlBody, caseId); 
                    insert attach;
                }
               
    
                // update case fields
                cachedCase.Case_GUID__c = resp.LeadGUId;
                cachedCase.Case_Dealer_Disposition__c = resp.ResponseCode;
                cachedCase.Case_Dealer_Disposition_Information__c = resp.ResponceDetail;
                update cachedCase;
            }
            
            // run schedule job
            // NNALeadStatusScheduleJob.RunScheduleJob();
    } catch (System.QueryException ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(myMsg);
        } catch (UrbanScienceCaseMappingHelper.ValidationException ex) {
               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }

    // generate attachment and attach to case
    @TestVisible private Attachment createAttach(String xmlBody, Id caseId) {
        Attachment attach = new Attachment();
        attach.Body = Blob.valueOf(xmlBody);
        attach.Name = String.format('{0}_{1}.xml', new String[] { '' + caseId,  System.now().format('MM_dd_yyyy')});
        attach.IsPrivate = false;
        attach.ParentId = caseId;

        return attach;
    }
}