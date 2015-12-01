/* Used to add or remove survey takers from the database */
global without sharing class AddUsersController {
	//public List<Contact> allUsers	{get; set;}
	public String theList			{get; set;}
	public String surveyRef			{get; set;}
 
   /** Fills the list of contacts who are taking the survey
       specified in the url parameter.
    */ 
	public AddUsersController() {
		surveyRef = Apexpages.currentPage().getParameters().get('sId');
	}

//------------------------------------------------------------------------------//	
  	private static TestMethod void testAddUsersController(){
	  SurveyTestingUtil tu = new SurveyTestingUtil();
      AddUsersController sc = new AddUsersController();
      System.assert(sc!=null);
  	}  
//------------------------------------------------------------------------------//	

   /** Inserts a new Survey taker in the database
       param: userId	Contact ID as specified in the url parameter
       param: sId		Survey ID as specified in the url parameter
       return: boolean 	returns 'true' if no error
    */	
	static Webservice String addUser(String userId, String sId, String caId) {
		String CaseId;
	
		if(caId.toUpperCase() =='NONE'|| caId.length()<5)
		  caseId = null;
		else  
		  caseId = caId;  	
		
		if(userId.toUpperCase() == 'NONE'|| userId.length()<5)
		  userId = null;
		  
		List<SurveyTaker__c> check = [Select Contact__c, Survey__c, Case__c From SurveyTaker__c Where Contact__c=:userId and Survey__c=:sId and Case__c = :caseId];
		if(check != null && check.size()>0){
			return 'false';
			/* Check to see if contact is not already in the database */
  		}
		/* Add the contact to the database otherwise */
		SurveyTaker__c st = new SurveyTaker__c();
		List <Contact> c = [Select Id, FirstName, LastName, email From Contact Where Id=:userId];
		if(c == null || c.size()==0)
		  return 'false';
		st.Contact__c = userId;
		st.Survey__c = sId;
		st.Taken__c = 'false';
		st.Case__c = caseId;
		/*Profile profile = [SELECT Id FROM Profile WHERE 
			Name='System Administrator' limit 1];
		User thisUser = [SELECT Id FROM User WHERE ProfileId = :profile.Id limit 1];
		System.runAs(thisUser) {*/	
			insert st;
		//}
		return 'true';
	}

//------------------------------------------------------------------------------//	
  	private static TestMethod void testAddUser(){
    	SurveyTestingUtil tu = new SurveyTestingUtil();
    	System.assert(AddUsersController.addUser(tu.contactId2, tu.surveyId, 'none') == 'true');
    	System.assert(AddUsersController.addUser('arf','arf','arf')== 'false');
    	System.assert(AddUsersController.addUser(tu.contactId, tu.surveyId, 'none') == 'false');
  	}
//------------------------------------------------------------------------------//	


   /** Removes a survey taker from the database
       param: userId	Contact ID as specified in the url parameter
       return: boolean 	returns 'true' if no error
    */  	
	public static Webservice String removeUser(String userId) {
		List<SurveyTaker__c> st = [Select Id, Contact__c From SurveyTaker__c Where Contact__c=:userId];
		for(SurveyTaker__c s:st) 
			delete s;
		return 'true';
	}	
	
//------------------------------------------------------------------------------//	
	private static TestMethod void testRemoveUser() {
    	SurveyTestingUtil tu = new SurveyTestingUtil();
    	AddUsersController sc = new AddUsersController();	
    	System.assert(AddUsersController.addUser(tu.contactId2, tu.surveyId, 'none') == 'true');
    	System.assert(AddUsersController.removeUser(tu.contactId) == 'true');	
	}
//------------------------------------------------------------------------------//	
  public void InsertNewSurveyTaker(String contactId, String surveyId, String taken, String caseId){
    SurveyTaker__c st = new SurveyTaker__c();
    st.Contact__c = contactId;
    st.Survey__c = surveyId;
    st.Taken__c = taken;
    st.Case__c = caseId;
    insert st;
  }
  //------------------------------------------------------------------------------//
}