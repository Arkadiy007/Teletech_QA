/**********************************************************************
Name: Controller_VehicleServiceContractComment 
Copyright © notice: Nissan Motor Company
======================================================
Purpose: 
This controller contains the logic to help display and save data
on the VehicleServiceContractComment.page.
======================================================
History: 

VERSION AUTHOR DATE DETAIL 
1.0 - Bryan Fry 10/04/2011 Created                                                 
***********************************************************************/

public with sharing class Controller_VehicleServiceContractComment {
    public static final Integer LINE_LENGTH = 72;
    public static final Integer MAX_LINES = 30;
    
    public Integer lineLength {
        get;set;
    }

    public Integer maxLines {
        get;set;
    }
    
    /* Vehicle Service Contract Salesforce Id */
    public Id vscId {
        get;set;
    }

    /* Return URL to forward to after Save or Cancel */
    public String retURL {
        get;set;
    }
    
    /* VIN of the vehicle */
    public String vin {
        get;set;
    }
    
    /* Existing comment lines at the load of the page */
    public List<Generic_Text__c> existingCommentLines {
        get;set;
    }
    
    /* Existing comment lines converted to a single string for display */
    public String existingComments {
        get;set;
    }
    
    /* Highest line number for one of the comments. New comment lines should be numbered from this point */
    public Integer lastLineNumber {
        get;set;
    }

    /* New comment string entered by user on the screen */
    public String newComments {
        get;set;
    }

    /* New comments entered by the user are parsed into comment lines in this list */
    public List<Generic_Text__c> newCommentLines {
        get;set;
    }
    
    /* Constructor to setup the initial data for the page */
    public Controller_VehicleServiceContractComment() {
        // Assign LINE_LENGTH to a variable that can be accessed from the VisualForce page.
        lineLength = LINE_LENGTH;
        
        // Assign MAX_LINES to a variable that can be accessed from the VisualForce page.
        maxLines = MAX_LINES;
                
        // Get the VSCId passed in. If it's not null, get the related Vehicle_Service_Contract__c object with
        // its VIN.  Then use the VIN to get a list of all Generic_Text__c comment lines for that VIN
        // and convert them into a single string for read-only display to the user.
        vscId = ApexPages.currentPage().getParameters().get('VSCId');
        if (vscId != null) {
            Vehicle_Service_Contract__c vsc = [select Id, VIN__c from Vehicle_Service_Contract__c where Id = :vscId];
            vin = vsc.VIN__c;
            existingCommentLines = [select Line_Number__c, Comment_Text__c from Generic_Text__c where VIN__c = :vin order by Line_Number__c];
            initializeComments();
        }
        
        // Get the retURL passed in.  If it's not null, set it and use it to determine where to
        // return after a save or cancel.
        retURL = ApexPages.currentPage().getParameters().get('retURL');
    }
    
    /* Convert a list of Generic_Text__c comments into a String for display in a text area to the user. */
    public void initializeComments() {
        // Clear the comment String and line number to start numbering new lines from.
        existingComments = '';
        lastLineNumber = 0;
        
        // Loop through the Generic_Text__c rows and construct a String with the line number and comment
        // text for each row on a separate line.  Get the highest Line_Number__c of the comments and make
        // that the starting point for numbering new lines.
        for(Generic_Text__c line: existingCommentLines) {
            existingComments = existingComments + line.Line_Number__c + '. ' + line.Comment_Text__c +'\n';
            if (line.Line_Number__c > lastLineNumber)
                lastLineNumber = Integer.valueOf(line.Line_Number__c);
        }
        
        // If the total number of lines is greater than or equal to MAX_LINES,
        // add an error message. 
        if (lastLineNumber >= MAX_LINES) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                 'Limit of ' + MAX_LINES + ' total comment lines allowed has been reached.  ' +
                                 'No further comments may be added.'));
        }
    }

    /* Convert a string of new comments into a numbered List of Generic_Text__c comment lines.
       The String is first broken apart on newline characters so that a newline always
       results in a new comment.  Then if any of the Strings resulting from this are longer than
       the LINE_LENGTH, they are broken down further to fit in that size.  The resulting list
       is numbered in order starting at 1 greater than the previous highest line number. */
    public void parseComments() {
        // Initialize variables
        newCommentLines = new List<Generic_Text__c>();
        Generic_Text__c commentLine;
        Integer lineCounter = lastLineNumber;

        if (newComments != null && newComments != '') {
	        // Split the input String on the newline character
	        List<String> lines = newComments.split('\n');

	        // For each portion of the full String after being split by newlines, create
	        // a Generic_Text__c object for each group of LINE_LENGTH characters.  If the
	        // String is very long, it will be split into many comment lines.  If it is
	        // less than LINE_LENGTH in size, it will be put into a single comment line.

	        for(String line: lines) {
	            // Handle splitting while the line is still longer than LINE_LENGTH,
	            // removing the split characters from the line each time through the loop
	            // to shorten it.
	            while (line.length() > LINE_LENGTH) {
	                commentLine = new Generic_Text__c();
	                commentLine.VIN__c = vin;
	                commentLine.Line_Number__c = ++lineCounter;
	                commentLine.Comment_Text__c = line.substring(0, LINE_LENGTH);
	                commentLine.Origination_Source__c = System.Label.Origination_Source_Salesforce;
	                commentLine.Origination_Type__c = System.Label.Origination_Type_VSC_Comments;
	                commentLine.Batch_Status__c = 'New';
	                newCommentLines.add(commentLine);
	                line = line.substring(LINE_LENGTH);
	            }
	            
	            // Handle the last portion of the line which is now under LINE_LENGTH in size.
	            commentLine = new Generic_Text__c();
	            commentLine.VIN__c = vin;
	            commentLine.Line_Number__c = ++lineCounter;
	            commentLine.Comment_Text__c = line;
	            commentLine.Origination_Source__c = System.Label.Origination_Source_Salesforce;
	            commentLine.Origination_Type__c = System.Label.Origination_Type_VSC_Comments;
	            commentLine.Batch_Status__c = 'New';
	
	            newCommentLines.add(commentLine);
	        }
        }
    }

    /* Parse the String input by the user and insert the generated comment lines. */
    public PageReference doSaveCommentLines() {
        try {
            parseComments();
            if (!ApexPages.hasMessages() && !newCommentLines.isEmpty()) {
System.debug('newCommentLines = ' + newCommentLines);
                insert newCommentLines;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }

        return getReturnPage();
    }
    
    /* Cancel the operation and return as directed */
    public PageReference doCancel() {
    	return getReturnPage();
    }   

	private PageReference getReturnPage() {
		PageReference returnPage;
		
        if (retURL != null) {
        	returnPage = new PageReference(retURL);
        } else {
        	returnPage = new ApexPages.StandardController(new Vehicle_Service_Contract__c(ID = vscId)).view();
        }
        
        return returnPage;
	}
}