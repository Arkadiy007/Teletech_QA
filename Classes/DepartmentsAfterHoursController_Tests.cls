/**********************************************************************
Name: DepartmentsAfterHoursController_Test
Copyright ¬© notice: Nissan Motor Company
======================================================
Purpose:
Test code of DepartmentsAfterHours_Controller

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Anna Koseykina 7/8/2015 Created
***********************************************************************/
@isTest
public class DepartmentsAfterHoursController_Tests { 
	static testMethod void testController() {
	List<Department__c> deps = new List<Department__c>();
		Department__c dep = new Department__c(After_Hours_Message__c = 'test',
		                                            Operation_Hours_Friday__c = '00:00-12:00',
		                                            Operation_Hours_Monday__c = '00:00-12:00',
		                                            Operation_Hours_Saturday__c = '00:00-12:00',
		                                            Operation_Hours_Sunday__c = '00:00-12:00',
		                                            Operation_Hours_Thursday__c = '00:00-12:00',
		                                            Operation_Hours_Tuesday__c = '00:00-12:00',
		                                            Operation_Hours_Wednesday__c = '00:00-12:00',
													URL_Parameter_Name__c = 'test',
													Name = 'test 1');
		
		deps.add(dep);
		Department__c dep2 = new Department__c(After_Hours_Message__c = 'test2',
		                                            Operation_Hours_Friday__c = '00:00-12:00',
		                                            Operation_Hours_Monday__c = '00:00-12:00',
		                                            Operation_Hours_Saturday__c = '00:00-12:00',
		                                            Operation_Hours_Sunday__c = '00:00-12:00',
		                                            Operation_Hours_Thursday__c = '00:00-12:00',
		                                            Operation_Hours_Tuesday__c = '00:00-12:00',
		                                            Operation_Hours_Wednesday__c = '00:00-12:00',
													URL_Parameter_Name__c = 'test2',
													Name = 'test 2');
		
		deps.add(dep2);
		insert deps;
		Test.startTest();
		
			PageReference objPageRef = Page.DepartmentsAfterHours;
			DepartmentsAfterHours_Controller objController;
			
			Test.setCurrentPage(objPageRef);
			
			objController = new DepartmentsAfterHours_Controller(new ApexPages.StandardController(dep));
			
			objController.depa = dep2.Id;
			objController.onPicklistChange();
			System.assertEquals(objController.depa, dep2.id);
			List <SelectOption > op = new List <SelectOption > ();
			op.add(new SelectOption('--None--', '--None--'));
			System.debug('** select option ' + deps);
			for (Department__c depar : deps) {
				op.add(new SelectOption(depar.Id, depar.Name));
				System.debug('** select option ' + depar.Id + ' ' + depar.Name);
			}

			objController.quicksave();

			System.assertEquals(objController.getItems(), op);
		
		Test.stopTest();
	}
}