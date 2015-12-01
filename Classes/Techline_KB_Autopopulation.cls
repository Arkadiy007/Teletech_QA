public class Techline_KB_Autopopulation {
	private ValidationUtility datacheck = new ValidationUtility();
	
	public Techline_KB_Autopopulation(ApexPages.KnowledgeArticleVersionStandardController ctl) {
		Techline__kav article = (Techline__kav)ctl.getRecord();
		String sourceId = ctl.getSourceId();
		
		Case techlineCase = [SELECT Id, Component_Code_Category__c, 
            Component_Code_Issue__c, Description, DTC_1__c, DTC_2__c, DTC_3__c,
            Make__c, Model_Line__c, Model_Year__c, CaseNumber, Other_DTCs__c,
            Problem_Analysis__c, Project_Number__c, Solution_Description__c,
            Symptom_Code_Category__c, Symptom_Code_Issue__c, Subject,
            Model_Line_Series__c, Manufacturer_Date__c, Model_Code__c,
            Initial_Recommendation__c
            FROM Case
            WHERE Id = :sourceId];
        
        article.put('Case_Article_was_Created_from__c', techlineCase.Id);
        article.put('Component_Code_Category__c', techlineCase.Component_Code_Category__c);
        article.put('Component_Code_Issue__c', techlineCase.Component_Code_Issue__c);
        article.put('Description__c', techlineCase.Description);
        article.put('DTC_1__c', techlineCase.DTC_1__c);
        article.put('DTC_2__c', techlineCase.DTC_2__c);
        article.put('DTC_3__c', techlineCase.DTC_3__c);
		article.put('Make__c', techlineCase.Make__c);
        article.put('Model_Line__c', techlineCase.Model_Line__c);
        article.put('Model_Year__c', techlineCase.Model_Year__c);
		article.put('Original_Case_Number__c', techlineCase.CaseNumber);
		article.put('Other_DTCs__c', techlineCase.Other_DTCs__c);
		article.put('Problem_Analysis__c', techlineCase.Problem_Analysis__c);
		article.put('Project_Number__c', techlineCase.Project_Number__c);
		article.put('Summary', techlineCase.Solution_Description__c);
		article.put('Symptom_Code_Category__c', techlineCase.Symptom_Code_Category__c);
		article.put('Symptom_Code_Issue__c', techlineCase.Symptom_Code_Issue__c);
		article.put('UrlName', techlineCase.CaseNumber);
		article.put('Initial_Recommendation__c', techlineCase.Initial_Recommendation__c);
		
		List<CaseComment> comments = [SELECT CreatedDate, CommentBody
			FROM CaseComment
			WHERE ParentId = :sourceId];
		
        if (comments != null && comments.size() > 0) {
            String concatenatedComments = '';
            for (CaseComment cc : comments) {
                concatenatedComments += String.valueOf(cc.CreatedDate) + 
                	' - ' + cc.CommentBody;
                concatenatedComments += '\n\b';
            }
            article.put('Case_Comments__c', concatenatedComments);
        }
            
        String articleSubject;
        if (techlineCase.Subject == null || techlineCase.Subject.trim() == '') {
            articleSubject = techlineCase.CaseNumber;
        }
        else {
            articleSubject = techlineCase.Subject;
        }
        
        if (!datacheck.IsStringNullOrEmpty(techlineCase.DTC_1__c)) {
            articleSubject += ' - ' + techlineCase.DTC_1__c;
        }
        
        if (!datacheck.IsStringNullOrEmpty(techlineCase.DTC_2__c)) {
            articleSubject += ' - ' + techlineCase.DTC_2__c;
        }
        
        if (!datacheck.IsStringNullOrEmpty(techlineCase.DTC_3__c)) {
            articleSubject += ' - ' + techlineCase.DTC_3__c;
        }
        
        article.put('Title', articleSubject);
        
        article.put('Model_Line_Series__c', techlineCase.Model_Line_Series__c);
        article.put('Manufacturer_Date__c', techlineCase.Manufacturer_Date__c);
        article.put('Model_Code__c', techlineCase.Model_Code__c);  
        
        /*
        //article.put('title', 'From Case: ' + techlineCase.subject);  //this overrides the default behavior of pre-filling the title of the article with the subject of the closed case.
        //ctl.selectDataCategory('Geography','USA');  //Only one category per category group can be specified.
        //ctl.selectDataCategory('Topics','Maintenance');
        */   
    }   
}