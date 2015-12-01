global class Schedule_D360_Summary implements Schedulable {
    global void execute(SchedulableContext SC) {
        
        Batch_D360_Delete D360BatchStart = new Batch_D360_Delete();
        Database.executeBatch(D360BatchStart);

}
}