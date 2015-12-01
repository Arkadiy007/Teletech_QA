/**
* 
*/
public class DeleteOldRecordsJob implements  Database.Batchable<SObject>, Schedulable { 
  //--------------------------------------------------------------------------
  // Constants
  @TestVisible private final static Integer BATCH_SIZE = 200;

  @TestVisible private final static String PART_INCIDENT_REPORT_SOQL = 
    'SELECT ID FROM Part_Incident_Report__c WHERE PIR_Status__c = \'Closed\' AND CreatedDate < LAST_N_YEARS:5 AND Legal_Hold__c = false';
  
  @TestVisible private final static String SORTING_REPORT_SOQL = 
    'SELECT ID FROM Sorting_Report__c WHERE Status__c = \'Closed\' AND CreatedDate < LAST_N_YEARS:5 AND Legal_Hold__c = false';

  @TestVisible private final static String MONETARY_CLAIMS_SOQL = 
    'SELECT ID FROM Monetary_Claim__c WHERE Claim_Status__c = \'Closed\' AND CreatedDate < LAST_N_YEARS:5 AND Legal_Hold__c = false';

  //--------------------------------------------------------------------------
  // Properties
  private String query;

  //--------------------------------------------------------------------------
  // Methods
  public DeleteOldRecordsJob(String query) {
    this.query = query;
  }

	/** Schedulable method */
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new DeleteOldRecordsJob(query), BATCH_SIZE);
	}

  /** Database.Batchable method */
  public Database.QueryLocator start(Database.BatchableContext context) {
    return Database.getQueryLocator(query);
  }
  
  /** Database.Batchable method */
  public void execute(Database.BatchableContext context, List<SObject> scope) {
    delete scope;
  }
      
  /** Database.Batchable method */
  public void finish(Database.BatchableContext context) {
  }

  /** Run Schedule Batch Job */
  public static void Run(String name, Schema.SObjectType o) {
    // Is the job already running?
    CronTrigger[] jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime
                            FROM CronTrigger 
                           WHERE CronJobDetail.Name = :name];

    // If the job exists, it needs to be deleted
    if (jobs.size() > 0) {
      System.abortJob(jobs[0].Id);
    }

    if (o == Schema.Part_Incident_Report__c.SObjectType) {
      System.schedule(name, '0 0 0 * * ?', new DeleteOldRecordsJob(PART_INCIDENT_REPORT_SOQL));
    } else if (o == Schema.Sorting_Report__c.SObjectType) {
      System.schedule(name, '0 0 0 * * ?', new DeleteOldRecordsJob(SORTING_REPORT_SOQL));
    } else if (o == Schema.Monetary_Claim__c.SObjectType) {
      System.schedule(name, '0 0 0 * * ?', new DeleteOldRecordsJob(MONETARY_CLAIMS_SOQL));
    }
  }
}