/**********************************************************************
  Name: DispositionUpdateScheduledJob
  Copyright © notice: Nissan Motor Company.
  ======================================================
  Purpose
  Schedule job, which will act as automated disposition update process.
  ======================================================
  History:

  VERSION AUTHOR DATE DETAIL
  1.0 - Vlad Martynenko 02/05/2015 Created 
  2.0 - Vlad Martynenko 03/13/2015 Dev done
  ***********************************************************************/
public class DispositionUpdateScheduledJob implements Schedulable {

	public void execute(SchedulableContext sc) {

		DispositionUpdateBatch dispositionBatch = new DispositionUpdateBatch();
		Database.executeBatch(dispositionBatch);
	}
}