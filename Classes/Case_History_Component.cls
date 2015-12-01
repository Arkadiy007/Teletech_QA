/*
Page Title: Case_History_Component
Author: Aaron Bessey
Description: Controller Class to control the case history component showed on Accounts
Dependencies: N/A
Create Date: 12/04/2014
Last Update: 12/04/2014
Updated By: Aaron Bessey

Revisions:
AAB - Initial Creation

*/

public class Case_History_Component {
    Public Account acc {get; set;}
    Public List<Case> cases {get; set;}
    Public Map<Id, List<CaseComment>> mapCaseComments {get;set;}
    Public Map<Id, Boolean> mapHasCaseComments {get;set;}
    Public Boolean showRefresh{get;set;}
    
    
    Public Boolean recordsFound {get; set;}
    Public List<Map<String, String>> lstColumns {get; set;}
    Public List<String> lstColumnNames {get;set;}
    Public Integer numColumns {get;set;}
    
    Public Integer noOfRecords{get; set;}
    Public Integer noOfPages{get;set;}
    Public Integer size{get;set;}
    Public String oldSortField {get;set;}
    
    Public Case_History_Component(ApexPages.StandardController stdController) 
    {
        acc = [Select Id, Name From Account where Id =: ((Account)stdController.getRecord()).Id];
        showRefresh = true;
        
        buildListColumns();
        
        
        cases = getAccountCases(acc.Id);
        if(cases!=null && cases.size()>0)
        {
            recordsFound = true;
        }
        
        
        
    }
    
    Public void buildListColumns()
    {
        lstColumns = new List<Map<String, String>>();
        lstColumnNames = new List<String>();
        Set<String> colNames = new Set<String>();
        Map<String, String> column = new Map<String, String>();
        colNames.Add('CaseNumber');
        lstColumnNames.Add('CaseNumber');
        column.put('name', 'CaseNumber');
        column.put('label', 'Case Number');
        column.put('namefield', 'true');
        column.put('type', 'String');
        lstColumns.Add(column);
        
        List<Schema.FieldSetMember> fields = SObjectType.Case.FieldSets.NCI_Case_History.getFields();
        
        SObjectType caseType;
		Map<String,Schema.SObjectField> mfields;
        caseType = Schema.getGlobalDescribe().get('Case');
		mfields = caseType.getDescribe().fields.getMap(); 
        Schema.SObjectField oField;
        Schema.DescribeFieldResult dfr;
        
        String fieldPath;
        for(Schema.FieldSetMember field : fields)
        {
            fieldPath = field.getFieldPath();
            if(colNames.contains(fieldPath))
            {
                continue;
            }
            
            oField = mFields.get(fieldPath);
            dfr = oField.getDescribe();           
            
            if(fieldPath=='CreatedBy__c')
            {
                lstColumnNames.Add('CreatedBy.Name');
                column = new Map<String, String>();
                column.put('name', 'CreatedBy.Name');
                column.put('label', 'Created By');
                column.put('namefield', 'false');
                column.put('type', 'String');
                lstColumns.Add(column);
                colNames.Add(fieldPath);
                continue;                
            }
            colNames.Add(fieldPath);
            
            lstColumnNames.Add(fieldPath);
            column = new Map<String, String>();
            column.put('name', fieldPath);
            column.put('label', field.getLabel());
            column.put('namefield', String.valueOf(dfr.isNameField()));
            column.put('type', String.valueOf(dfr.getType()));
            lstColumns.Add(column);
        } 
        
        numColumns = lstColumns.size();
    }
    
    Public List<Case> getAccountCases(Id accountId)
    {
        String sql = 'Select Id, ';
        sql += String.join(lstColumnNames, ',');
        sql += ', (Select Id, ParentId, IsPublished, CommentBody, CreatedBy.Name, CreatedById, ';
        sql += 'CreatedDate, SystemModstamp, LastModifiedDate, LastModifiedById, IsDeleted From CaseComments) ';
        sql += 'from Case ';
        sql += 'Where ';
        sql += 'AccountId=\'' + accountId + '\' ';
        sql += 'Order By ';
        sql += sortField + ' ' + sortDir;
        List<Case> oCases = Database.query(sql);
        
        mapCaseComments = new Map<Id, List<CaseComment>>();
        mapHasCaseComments = new Map<Id, Boolean>();
        List<CaseComment> lstCaseComments = new List<CaseComment>();
        for(Case c : oCases)
        {
            lstCaseComments = new List<CaseComment>();
            for(CaseComment cc : c.CaseComments)
            {
             	cc.CommentBody = cc.CommentBody.replaceAll('\n', '<br/>');
                lstCaseComments.Add(cc);
            }
            if(lstCaseComments.size()>0)
            {
                mapHasCaseComments.put(c.id, true);
            }
            else
            {
                mapHasCaseComments.put(c.id, false);
            }
            mapCaseComments.put(c.Id, lstCaseComments);
        }
        
        return oCases;
    }
    
    public void sortCol()
    {
        if(oldSortField == sortField)
        {
            sortDir = (sortDir == 'Asc') ? 'Desc' : 'Asc';            
        }
        else
        {
            sortDir = 'Asc';
        }
        
        PageReference pr = refresh();
    }
    
    public String sortDir {
        get  { return (sortDir == null) ? 'asc' : sortDir;}
        set;
    }
    
    // the current field to sort by. defaults to last name
    public String sortField {
        get  { return (sortField == null) ? 'CreatedDate' :sortField; }
        set {
            oldSortField = sortField; 
            sortField = value;}
    }
    
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                if(size==null)
                {
                    size = 10;
                    sortField = 'CreatedDate';
                    sortDir = 'Asc';
                }
                
                cases = getAccountCases(acc.Id);
                                           
                setCon = new ApexPages.StandardSetController(cases);
                
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
                noOfRecords = noOfRecords==null ? 0: noOfRecords;
                recordsFound = noOfRecords > 0 ? true: false;
                
                Double dSize = (double) size;
                Double dRecords = (double) noOfRecords;
                Double dPages = Math.Ceil(dRecords/dSize);                
                noOfPages = (Integer) dPages;
            }
            return setCon;
        }set;
    }
    
    Public List<Case> getCases(){
        List<Case> caseList = new List<Case>();
        for(Case c : (List<Case>) setCon.getRecords())
            caseList.add(c);
        return caseList;
    }
    
    Public PageReference refresh()
    {
        setCon = null;
        cases = getCases();
        setCon.setPageNumber(1);
        return null;
    }
    
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    
    public Integer pageNumber {
        get {
            
            return (setCon==null || setCon.getPageNumber()==null) ? 1: setCon.getPageNumber();
        }
        set;
    }
    
    public void first() {
        setCon.first();
        cases = getCases();
    }
    
    public void last() {
        setCon.last();
        cases = getCases();
    }
    
    public void previous() {
        setCon.previous();
        cases = getCases();
    }
    
    public void next() {
        setCon.next();
        cases = getCases();
    }
    
}