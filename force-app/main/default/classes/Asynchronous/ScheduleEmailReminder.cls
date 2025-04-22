public with sharing class ScheduleEmailReminder implements Schedulable{
    //sends an email reminder the day before an interview is scheduled
    public void execute(SchedulableContext sc) {
        EmailReminderHelper.sendInterviewReminders();
    }
}