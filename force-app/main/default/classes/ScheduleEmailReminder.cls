public with sharing class ScheduleEmailReminder implements Schedulable{
    public void execute(SchedulableContext sc) {
        EmailReminderHelper.sendInterviewReminders();
    }
}