/**********************************************************************
Name: BuildSoqlUtil
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This is generic utility that builds a SELECT soql for the entire object.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Munawar Esmail 10/07/2011 Created
***********************************************************************/

public with sharing class BuildSoqlUtil {

// Returns a dynamic SOQL statement for the whole object, includes only creatable fields.    
	public static string getCreatableFieldsSOQL(String objectName, String whereClause)
	{           
		String sofields = '';                      
		
		// Get a map of field name and field token         
		Map<String, Schema.SObjectField> fMap = 
			Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();               

		if (fMap != null){             
		//create soql column list
		Integer i = 0;	
		for(Schema.SObjectField ssField : fMap.values()) {
	  		Schema.DescribeFieldResult result = ssField.getDescribe();
	  		//if(result.isUpdateable() && String.valueOf(ssField) != 'Name') {	  	
	      		if(i<1) {
	        		sofields =  String.valueOf(ssField);	        
	      		}
	      		else {
	        		sofields = sofields + ',' + String.valueOf(ssField);  
	      		}
	        	i++; 
	   		//}
		}         
		}           				
         
        if (whereClause == null || whereClause == '')
		{ 
			return 'SELECT ' + sofields + ' FROM ' + objectName; 
		}
		else
		{
			return 'SELECT ' + sofields + ' FROM ' + objectName + ' WHERE ' + whereClause; 
		}
	}

}