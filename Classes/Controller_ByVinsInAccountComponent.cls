/**********************************************************************
Name: Controller_ByVinsInAccountComponent
Copyright ¬© notice: Nissan Motor Company
======================================================
Purpose:
Controller of Controller_ByVinsInAccountComponent Component

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 01/16/2012 Created
***********************************************************************/
public with sharing class Controller_ByVinsInAccountComponent {
	public Controller_ByVinsInAccount ByVinsInAccountController {get; set;}
    public String ResponseOutput { 
    	get {
    		return ByVinsInAccountController.ResponseOutput;
    	}
    	set {
    		ResponseOutput = ByVinsInAccountController.ResponseOutput;
    	}
    }
	
    public PageReference doSearch() {
    	ByVinsInAccountController.BatchNumber = BatchNumber;
        return ByVinsInAccountController.doSearch();
    }
    
    public Integer BatchNumber {get; set;}
}