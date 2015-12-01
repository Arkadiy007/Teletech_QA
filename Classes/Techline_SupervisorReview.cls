/*
////////////////////////////////////////////////////////////////////////////////
Copywrite TeleTech 2012, All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

Class for managing the Supervisor review tasks and notifications.
When a Techline case has the 'Supervisor Review' field checked, a task and an 
email are sent to the Supervisors informed in 2 Custom Labels 

Class:              Techline_SupervisorReview
Author:             Rohdenburg S.
Date:               06/19/2014
Version:            1.0
Last Updated:       06/23/2014
    * 06/19/2014    SR - Created
    * 06/23/2014    SR - Implemented the Test code
*/

public class Techline_SupervisorReview
{
    // -------- Constants --------
    private final String RECORD_TYPE_TECH_LINE = 'TECH LINE';
    private final String TASK_SUBJECT = 'TECH LINE Case - ' + 
        'Supervisor Review needed';
    private final String TASK_STATUS_NOT_STARTED = 'Not Started';
    private final String TASK_PRIORITY = 'Normal';
    private final String TEMPLATE_SUPERVISOR = 'Supervisor_Review';
    
    // -------- Constructor --------
    public Techline_SupervisorReview(){}

    // -------- Variables --------
    private ValidationUtility datacheck = new ValidationUtility();
    private Techline_NotificationEmails tne = new 
        Techline_NotificationEmails();
    
    // -------- Properties --------
    // None
    
    // -------- Methods --------
    //It creates a task for each supervisor informed in the custom label, and
    // send an email notification to them
    public void createSupervisorTasks(String caseId, String caseNumber) {
        if (!datacheck.IsStringNullOrEmpty(
            System.Label.TECH_LINE_Supervisor_Id_1)) {
            createTask(System.Label.TECH_LINE_Supervisor_Id_1, caseId, 
                caseNumber);
        }
        
        if (!datacheck.IsStringNullOrEmpty(
            System.Label.TECH_LINE_Supervisor_Id_2)) {
            createTask(System.Label.TECH_LINE_Supervisor_Id_2, caseId,
                caseNumber);
        }
    }
    
    // It creates a task for the informed userId
    private void createTask(String userId, String caseId, String caseNumber){
        String taskTechlineId = RecordtypeUtil.getObjectRecordTypeId(
            Task.SObjectType, RECORD_TYPE_TECH_LINE);
            
        Task supervisorTask = new Task();
        supervisorTask.RecordTypeId = taskTechlineId;
        supervisorTask.OwnerId = userId;
        //supervisorTask.WhatId = caseId;
        supervisorTask.ActivityDate = Date.today();
        supervisorTask.Subject = TASK_SUBJECT;
        supervisorTask.Status = TASK_STATUS_NOT_STARTED;
        supervisorTask.Priority = TASK_PRIORITY;
        supervisorTask.Description = 'Case: ' + caseNumber;
        insert supervisorTask;
        
        sendEmailForTask(userId, caseId);
    }

    // It sends an email informing that a new task has been assigned
    private void sendEmailForTask(String userId, String caseId) {
        List<User> users = [SELECT Email
            FROM User
            WHERE Id = :userId];
        
        if (users != null && users.size() > 0) {
            List<String> toAddress = new List<String>();
            toAddress.add(users[0].Email);
            
            //TODO: Remove this and uncomment line above
            //toAddress.add('srohdenburg@teletech.com');
            /*toAddress.Add('sarahmccarter@teletech.com');
            sendNotificationEmail(toAddress);*/
            
            String templateId = tne.getTemplateId(TEMPLATE_SUPERVISOR);
            if (templateId != null && toAddress.size() > 0){
                tne.sendTechlineEmail(toAddress, caseId, templateId, null);
            }
        }
    }    
   
}