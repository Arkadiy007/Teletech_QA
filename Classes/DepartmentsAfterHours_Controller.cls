/**********************************************************************
Name: DepartmentsAfterHours_Controller
Copyright �� notice: Nissan Motor Company
======================================================
Purpose:
Controller for DepartmentsAfterHours page

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Anna Koseykina 7/8/2015 Created
***********************************************************************/
public class DepartmentsAfterHours_Controller {
    private ApexPages.StandardController controller { get; set; }
    public DepartmentsAfterHours_Controller(ApexPages.StandardController controller) {
        departments = new Map <ID, Department__c > ([SELECT Id,
                                                    After_Hours_Message__c,
                                                    Operation_Hours_Friday__c,
                                                    Operation_Hours_Monday__c,
                                                    Operation_Hours_Saturday__c,
                                                    Operation_Hours_Sunday__c,
                                                    Operation_Hours_Thursday__c,
                                                    Operation_Hours_Tuesday__c,
                                                    Operation_Hours_Wednesday__c,
                                                    Name
                                                    FROM Department__c 
                                                    ORDER BY Name ASC NULLS LAST]);
        this.controller = controller;
        if(!String.isEmpty(system.currentPageReference().getParameters().get('Id'))){
            depa = system.currentPageReference().getParameters().get('Id');
        }
    }

    public String depa {
        get;
        set;
    }
    public List <SelectOption > getItems() {
        List <SelectOption > op = new List <SelectOption > ();
		op.add(new SelectOption('--None--', '--None--'));
        for (Department__c dep : departments.values()) {
            op.add(new SelectOption(dep.Id, dep.Name));
        }

        return op;
    }
    private Map <Id, Department__c > departments { get; set; }

    public PageReference onPicklistChange() {
		try 
		{	        
		departments.get(depa);
			PageReference pageRef = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/DepartmentsAfterHours?id=' + depa);

			pageRef.setRedirect(true);
			return pageRef;
		}
		catch (Exception  e)
		{
			PageReference pageRef = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/DepartmentsAfterHours');

			pageRef.setRedirect(true);
			return pageRef;return null;
		}		
    }
	
	public void quicksave(){
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Changes are saved'));
		controller.save();
	}

}