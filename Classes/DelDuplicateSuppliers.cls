global class DelDuplicateSuppliers implements Database.Batchable<SObject> {
    
    private String query {get; set;}

    global DelDuplicateSuppliers() {
        query = 'SELECT Id, (SELECT Id FROM Parts__r LIMIT 3) FROM Account WHERE RecordType.DeveloperName = \'Supplier\'';
    }
    
    /**
     * @description gets invoked when the batch job starts
     * @param context contains the job ID
     * @returns the record set as a QueryLocator object that will be batched for execution
     */ 
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(query);
    }

    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */ 
    global void execute(Database.BatchableContext context, List<Account> scope) {
		List<Account> accsToDelete = new List<Account>();
        
		for(Account supplier : scope){
			if(supplier.Parts__r.isEmpty()){
				accsToDelete.add(supplier);
			}
        }

        delete accsToDelete;
    }
    
    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */ 
    global void finish(Database.BatchableContext context) {
        
    }


}