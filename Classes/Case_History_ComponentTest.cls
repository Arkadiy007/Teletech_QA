@isTest
private class Case_History_ComponentTest
{
	private static Account account;
	private static List<Case> cases;


	@isTest 
	static void AccountWithoutCases_ShouldHaveEmptyCasesList()
	{
		Test.startTest();
		getAccount();
		ApexPages.StandardController sc = new ApexPages.StandardController(account);
		Case_History_Component chController = new Case_History_Component(sc);

		System.assert(chController.cases.isEmpty());

		Test.stopTest();
	}

	@isTest
	static void AccountWithCases_ShouldHaveCasesListNotEmpty(){
		Test.startTest();
		getAccount();
		getCases();
		ApexPages.StandardController sc = new ApexPages.StandardController(account);
		Case_History_Component chController = new Case_History_Component(sc);

		System.assert(!chController.cases.isEmpty());
		System.assertEquals(1, chController.pageNumber);

		Test.stopTest();
	}

	@isTest
	static void getSetCon_ShouldBeNotNull(){
		Test.startTest();
		getAccount();
		getCases();
		ApexPages.StandardController sc = new ApexPages.StandardController(account);
		Case_History_Component chController = new Case_History_Component(sc);
		ApexPages.StandardSetController ssc = chController.setCon;
		
		System.assert(ssc != null);
		
		Test.stopTest();
	}

	@isTest
	static void getPreviousNext_ShouldWorkCorrectly(){
		Test.startTest();
			getAccount();
			getCases();
			
			ApexPages.StandardController sc = new ApexPages.StandardController(account);
			Case_History_Component chController = new Case_History_Component(sc);

			chController.first(); // should not throw any exception
			chController.last();  // should now throw any exception
			chController.next();  // should now throw any exception	
			chController.previous(); // should now throw any exception

			if(chController.hasNext){
				System.assert(chController.setCon.next() != null);
			}
			else{
				System.assert(!chController.setCon.getHasNext());
			}

			if(chController.hasPrevious){
				System.assert(chController.setCon.next() != null);	
			}
			else{
				System.assert(!chController.setCon.getHasPrevious());
			}
		Test.stopTest();
	}

	@isTest
	static void sortCol_shouldSetSortDirToAscIfSortfieldEqOldSortField(){
		Test.startTest();
		getAccount();
		getCases();

		ApexPages.StandardController sc = new ApexPages.StandardController(account);
		Case_History_Component chController = new Case_History_Component(sc);
		
		ApexPages.StandardSetController ssc = chController.setCon;
		chController.sortDir = 'Desc';
		chController.sortCol();
		System.assertEquals('Asc', chController.sortDir); // if OldSF equals to sortField -> sortDir should set to Asc

		Test.stopTest();
	}


	private static void getAccount() {
		if(account == null){
		RecordType personalAccRecordType = [select id from RecordType where SobjectType = 'Account' AND IsPersonType = True limit 1];
		account = new Account();
		account.Recordtypeid = personalAccRecordType.Id;
		account.firstName = 'Test1';
		account.lastName = 'test2';
		insert account;
		}
	}

	private static void getCases(){
		if(cases == null){
		cases = new List<Case>();
		Case c;
		
		for(Integer i = 0; i < 10; i++){
			c = new Case();
			c.AccountId = account.id;
			c.Subject = String.valueOf(i);
			cases.add(c);
		}

		insert cases;
		
		List<CaseComment> comments = new List<CaseComment>();
		CaseComment cc;


		for(Integer i = 0; i < 10; i++){
			cc = new CaseComment();
			cc.ParentId = cases.get(i).id;
			cc.CommentBody = String.valueOf(i*i);
			comments.add(cc);
		}

		insert comments;

		}


	}
}