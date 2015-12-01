/**********************************************************************
Name: Schedule_Batch_SurveyGizmo_Load
Copyright © notice: Nissan Motor Company.
======================================================
Purpose:
This class schedules Techline Case Staging Dataload jobs to run.
Run at 8:30 pm MT:
System.schedule('Survey Gizmo, every hour', '0 0/60 * * * ?', new Schedule_Batch_SurveyGizmo_Load());
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - William Taylor 2/11/2014 Created
***********************************************************************/
global class Schedule_Batch_SurveyGizmo_Load implements Schedulable {
    global void execute(SchedulableContext SC) {
        // limit to 10 due to callouts
        Batch_SurveyGizmo_Load csd4 = new Batch_SurveyGizmo_Load();
        Database.executeBatch(csd4,10);
    }
}