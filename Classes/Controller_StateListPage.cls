/**********************************************************************
Name: Controller_StateListPage
Copyright © notice: Nissan Motor Company
======================================================
Purpose:
Controller for StateListPage.

Related Page : StateListPage 
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Bryan Fry	04/19/2011	Created                        
***********************************************************************/

public with sharing class Controller_StateListPage {
    public List<State__c> states {get;set;}
    
    public Controller_StateListPage(){        
        try {
			// Get List of State__c
			states = [select name, name__c, order__c from State__c order by order__c];
        } catch (QueryException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,system.label.States_List_Not_Found));
        }
    }
}