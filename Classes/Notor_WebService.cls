/**********************************************************************
Name: Notor_WebService
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This Class queries data to return User Information to
Matriz for Notor
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Matt Starr         08/07/2014 Created
***********************************************************************/

@RestResource(urlMapping='/notorusers/*')
global with sharing class Notor_WebService {
    
    @HttpGet
    global static ReturnClass doget() {
    
    List<User> results = new List<User>();
    
    try{
        results = [Select Id, FirstName, LastName, Notor_Id__c  from User where Notor_Id__c != null];
         return new ReturnClass ('true', 'Query executed successfully.', results);
    	}
    Catch (exception e){
          return new ReturnClass('false', e.getMessage(), null);          
    	}
    }
    
    Global Class ReturnClass {
          
        global String success;
        global String message;
        global List<User> records;

  	global ReturnClass(String success, String message, List<User> records) {
  	this.success = success;
  	this.message = message;
  	this.records = records;  
          
      	}
      }

}