global class Screen_Util {

	/* Remove line breaks from multi-line street addresses to allow on-click Javascipt
	   from a custom button to work.  Expose as a web service to allow this to be called
	   from the Javascript in the custom button.
	*/
	WebService static String getPersonMailingStreet(String id) {
		Account acct = [select PersonMailingStreet from account where Id = :id];
		String street = acct.PersonMailingStreet;
		street = street.replaceAll('\n',' ');
		street = street.replaceAll('\r',' ');
		
		return street;
	}

	/* Using Case Secondary Reason and Severity, look up which email addresses should
	   be informed of the escalation.
	*/
	WebService static String getVCSEscalationEmails(String id) {
		// Get the fields we may be checking from the Case
		Case c = [select VCS_Validation__c, Severity__c
		          from case 
		          where Id = :id];

		String emailAddresses = null;
		
		if (c.VCS_Validation__c != null && c.Severity__c != null) {		
			// For the VCS Validation field on the Case, get the Code__c row that says which fields are required.		
			List<Code__c> emailAddressesCodeList =
                     [select Severity_1_Nissan__c, Severity_2_Nissan__c, Severity_3_Nissan__c,
                             Severity_4_Nissan__c
                      from Code__c
                      where Description__c = :c.VCS_Validation__c
                      and Type__c = 'VCS_Validation' limit 1];
            Code__c emailAddressesCode = null;

			if (emailAddressesCodeList != null && !emailAddressesCodeList.isEmpty()) {
				emailAddressesCode = emailAddressesCodeList[0];

				// Use Severity to determine correct email address list.				
				if (c.Severity__c == 'Level 1') {
					emailAddresses = emailAddressesCode.Severity_1_Nissan__c;
				} else if (c.Severity__c == 'Level 2') {
					emailAddresses = emailAddressesCode.Severity_2_Nissan__c;
				} else if (c.Severity__c == 'Level 3') {
					emailAddresses = emailAddressesCode.Severity_3_Nissan__c;
				} else if (c.Severity__c == 'Level 4') {
					emailAddresses = emailAddressesCode.Severity_4_Nissan__c;
				}
			}
		}		

		return emailAddresses;
	}
	
	WebService static String getVCSTemplateId(String id) {
        // Get the VCS_Validation__c
        Case currentCase = [SELECT VCS_Validation__c
                  FROM Case
                  WHERE Id = :id];

        String templateId = null;
        
        if (currentCase.VCS_Validation__c != null) {        
            // Obtain the email template ID     
            List<Code__c> codeList =
                     [SELECT Email_Template_ID__c
                      FROM Code__c
                      WHERE Description__c = :currentCase.VCS_Validation__c
                      AND Type__c = 'VCS_Validation' 
                      LIMIT 1];

            if (codeList != null && !codeList.isEmpty()) {
                templateId = codeList[0].Email_Template_ID__c;
            }
        }       

        return templateId;
    }
}