global class Batch_Techline_KB_Publish_Articles implements Database.Batchable<sObject> {
	private final String CATEGORY_BRAND = 'Brand';
    private final String CATEGORY_MODEL = 'Make_Model';
    private final String CATEGORY_YEAR = 'Model_Year';
    private final String CATEGORY_X_CHAR = 'X';
    private final String CATEGORY_MODEL_OLD =  'X1999_and_older';
	
	global String query;
	
	Map<String,String> categoryBrands;
    Map<String,String> categoryModels;
    Map<String,String> categoryYears;
    List<Techline__DataCategorySelection> listCategories;
    
    private ValidationUtility datacheck = new ValidationUtility();
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		query = '';
		query += 'SELECT Id, Original_Case_Number__c, ';
        query += 'Make__c, Model_Line__c, Model_Year__c ';
        query += 'FROM Techline__kav  ';
        query += 'WHERE PublishStatus = \'Draft\' ';
        query += 'AND Language = \'en_US\' ';
        query += 'AND CreatedBy.Name = \'Sebastian Rohdenburg\' ';
        
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Techline__kav> techlineArticles){
		if (techlineArticles.size() > 0) {
			getExistingCategories();
			listCategories = new List<Techline__DataCategorySelection>();
			
			for (Techline__kav art : techlineArticles) {
	            setArticleCategories(art);
	        }
	        
	        //insert listArticles;
	        Database.SaveResult[] lstCSIns = Database.insert(listCategories, false);
	        
	        if (lstCSIns.size() > 0) {
                for (integer x = 0; x < listCategories.size(); x++) {
                	if (lstCSIns[x].isSuccess()) {
                    	System.debug('SR - Successful DML operation');
                    } 
                    else {
                        Database.Error err = lstCSIns[x].getErrors()[0];      
                        System.debug('SR - FAILED DML operation' + err.getMessage());                        
                    }
                }
            }
		}
    }

	global void finish(Database.BatchableContext BC){
	}
	
	public void getExistingCategories() {
        List <DataCategoryGroupSobjectTypePair> pairs = 
              new List<DataCategoryGroupSobjectTypePair>();
        
        DataCategoryGroupSobjectTypePair pair1 = 
              new DataCategoryGroupSobjectTypePair();
        pair1.setSobject('KnowledgeArticleVersion');
        pair1.setDataCategoryGroupName(CATEGORY_BRAND);
        
        DataCategoryGroupSobjectTypePair pair2 = 
              new DataCategoryGroupSobjectTypePair();
        pair2.setSobject('KnowledgeArticleVersion');
        pair2.setDataCategoryGroupName(CATEGORY_MODEL);
        
        DataCategoryGroupSobjectTypePair pair3 = 
              new DataCategoryGroupSobjectTypePair();
        pair3.setSobject('KnowledgeArticleVersion');
        pair3.setDataCategoryGroupName(CATEGORY_YEAR);
        
        pairs.add(pair1);
        pairs.add(pair2);
        pairs.add(pair3);
        
        List<Schema.DescribeDataCategoryGroupStructureResult> results = 
              Schema.describeDataCategoryGroupStructures(pairs, false);
              
        categoryBrands = new Map<String,String>();
        categoryModels = new Map<String,String>();
        categoryYears = new Map<String,String>();
        
        for (Integer i = 0; i < results.size(); i++) {
            DataCategory[] topCategories = results[i].getTopCategories();
            for (DataCategory dc : topCategories) {
                for (DataCategory children : dc.ChildCategories) {
                    if (results[i].getName() == CATEGORY_BRAND) {
                        categoryBrands.put(children.getLabel().toUpperCase(), children.getName());
                    }
                    
                    if (results[i].getName() == CATEGORY_MODEL) {
                        for (DataCategory children2 : children.ChildCategories) {
                            categoryModels.put(children2.getLabel().toUpperCase(), children2.getName());
                        }
                    } 
                    
                    if (results[i].getName() == CATEGORY_YEAR) {
                        categoryYears.put(children.getLabel().toUpperCase(), children.getName());
                    } 
                }
            }
        }
	}
	
	private void setArticleCategories(Techline__kav article) {
        try 
        {
            if (!datacheck.IsStringNullOrEmpty(article.Make__c)) {
                if (categoryBrands.containsKey(article.Make__c.toUpperCase())) {
                    Techline__DataCategorySelection brandCategory = 
                        new Techline__DataCategorySelection();
                    brandCategory.ParentId = article.Id;
                    brandCategory.DataCategoryGroupName = CATEGORY_BRAND;
                    brandCategory.DataCategoryName = categoryBrands.get(article.Make__c.toUpperCase());
                    listCategories.add(brandCategory);  
                }
            }
            
            if (!datacheck.IsStringNullOrEmpty(article.Model_Line__c)) {
                if (categoryModels.containsKey(article.Model_Line__c.toUpperCase())) {
                    Techline__DataCategorySelection modelCategory = 
                        new Techline__DataCategorySelection();
                    modelCategory.ParentId = article.Id;
                    modelCategory.DataCategoryGroupName = CATEGORY_MODEL;
                    modelCategory.DataCategoryName = categoryModels.get(article.Model_Line__c.toUpperCase());
                    listCategories.add(modelCategory);  
                }
            }
                
            if (!datacheck.IsStringNullOrEmpty(article.Model_Year__c)) {
                if (categoryYears.containsKey(article.Model_Year__c.toUpperCase())) {
                    Techline__DataCategorySelection yearCategory = 
                        new Techline__DataCategorySelection();
                    yearCategory.ParentId = article.Id;
                    yearCategory.DataCategoryGroupName = CATEGORY_YEAR;
                    
                    /*if (Integer.valueOf(article.Model_Year__c) > 1999) {
                        yearCategory.DataCategoryName = CATEGORY_X_CHAR + 
                            article.Model_Year__c;
                    }
                    else {
                        yearCategory.DataCategoryName = CATEGORY_MODEL_OLD;
                    }*/
                    
                    yearCategory.DataCategoryName = categoryYears.get(article.Model_Year__c.toUpperCase());
                    
                    listCategories.add(yearCategory);
                }
            }
        }
        catch (Exception ex) {
        }
    }
}