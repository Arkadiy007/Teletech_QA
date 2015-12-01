/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

This class is for running wide shared evaluations, like checking if a string
is null or empty.

Class:              ValidationUtility
Author:				JJ Heldman
Date:               03/15/12
Version:            1
Last Updated:       06/03/13
    * Stubbed, Completed with string and date check for nulls / empty
    * Included the email format validation

*/

public with sharing class ValidationUtility
{
	// -------- Constants --------
	// None
	
	// -------- Constructor --------
    public ValidationUtility(){}

    // -------- Variables --------
	// None
	
	// -------- Properties --------
	// None
	
	// -------- Methods --------
	// Determine if a value is null or empty
   	public boolean IsStringNullOrEmpty(string value)
   	{
   		return (value == null || value == '') ?  true : false;
   	}
   	
   	// Determine if a datetime is null or empty
   	public boolean IsDateTimeNull(datetime value)
   	{
   		return (value == null) ? true : false;
   	}
   	
   	// Determine if an email has a valid format
   	public boolean IsEmailFormat(string value)
	{
		boolean result = false;
		
		string regEx = '[a-zA-Z0-9]+[a-zA-Z0-9\\.\\_]*[a-zA-Z0-9]' + 
			'+@[a-zA-Z0-9\\-]+(\\.[a-zA-Z]+)+';
				
		Pattern emailAddress = Pattern.compile(regEx);
		Matcher emailMatch = emailAddress.matcher(value);
		
		if(emailMatch.matches())
		{
			result = true;
		}
		
		return result;
	}
	
	// -------- Test --------
	static testMethod void ClassTest()
	{
		ValidationUtility testClass = new ValidationUtility();
		testClass.IsStringNullOrEmpty(null);
		testClass.IsStringNullOrEmpty('');
		testClass.IsStringNullOrEmpty('valid');
		
		Datetime testDateTime = datetime.newInstance(2008, 8, 8);
		testClass.IsDateTimeNull(null);
		testClass.IsDateTimeNull(testDateTime);
	}
}