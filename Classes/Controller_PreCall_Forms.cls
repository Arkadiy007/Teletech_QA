/**********************************************************************
Name: Controller_PreCall_Forms
Copyright �� notice: Nissan Motor Company
======================================================
Purpose:
Controller of PreCall_Forms page which lanches the PreCall Fom flow

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Arkadiy Sychev 12/30/2014 Created
***********************************************************************/
public with sharing class Controller_PreCall_Forms {
    public Flow.Interview.PreCall_Forms myflow { get; set; }
    public Sites_Daily_Limit__c limits { get; set; }

    private final static Integer DEFAULT_LIMIT = 1000; 
    /*
    public Controller_PreCall_Forms() {
        
    }
    */
    public PageReference limitsProcessing() {
        limits = Sites_Daily_Limit__c.getOrgDefaults();
        System.debug('limits = ' + limits);

        if ((null == limits) || (null == limits.id)) {
            limits = new Sites_Daily_Limit__c();
            limits.Pre_Call_Daily_Limit__c = DEFAULT_LIMIT;
            insert limits;
            limits = Sites_Daily_Limit__c.getOrgDefaults();
            System.debug('limits = ' + limits);
        }
        Integer i = Integer.valueOf(limits.Pre_Call_Daily_Limit__c.round());

        Integer countWC= database.countQuery('SELECT Count() FROM Warranty_Case__c WHERE CreatedDate = TODAY LIMIT : i');
        System.debug('countWC = ' + countWC);
        if (countWC >= i) {
            PageReference inMaintenancePage = Page.InMaintenance;
            inMaintenancePage.setRedirect(true);
            System.debug('inMaintenancePage = ' + inMaintenancePage);
            return inMaintenancePage;
        }
          
        return null;
    }

    public String getVarWarrantyCaseNumber() {
        
        if (myflow == null) { 
            return null; 
        }
        else {
            return string.valueOf(myflow.getVariableValue('varWarrantyCaseNumber'));
        }
    }

    public Boolean getVarWasExistedWarrantyCaseFound() {
        
        if (myflow == null) { 
            return false; 
        }
        else {
            Boolean b = Boolean.valueOf(myflow.getVariableValue('varWasExistedWarrantyCaseFound'));
            return (null == b) ? false : b;
        }
    }
    
    public PageReference getOID(){
    System.debug('********* getVarWasExistedWarrantyCaseFound = ' + getVarWasExistedWarrantyCaseFound());
    PageReference p = getVarWasExistedWarrantyCaseFound() ? new PageReference('/apex/PreCall_Forms') : new PageReference('/apex/PreCall_Forms_For_Attachment?id=' + getVarWarrantyCaseNumber());
    System.debug('********* p = ' + p);
    p.setRedirect(true);
    return p;
    }
}