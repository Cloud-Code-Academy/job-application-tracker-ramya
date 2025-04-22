public with sharing class EmailReminderHelper {
    //Send emails to both candidate (To) and the recruiter (CC)
    public static void sendInterviewReminders() 
    {
        try 
        {
            DateTime tomorrow = DateTime.now().addDays(1);
           
            List<Event> interviewEvents = [SELECT Id, Subject, StartDateTime, Location, 
                                           Description,
                                           WhoId, OwnerId, WhatId
                                           FROM Event
                                           WHERE StartDateTime >= :tomorrow
                                           AND WhoId != null
                                           AND WhatId != null
                                           AND What.Type = 'Job_Application__c'
                                           ];

    
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
            for (Event evt : interviewEvents) {
                String recipientEmail = getEmailFromWhoId(evt.WhoId);
                String ownerEmail = getEmailFromOwnerId(evt.OwnerId);

                if (String.isBlank(recipientEmail)) continue;
    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { recipientEmail });

                if (!String.isBlank(ownerEmail)) {
                    mail.setCcAddresses(new String[] { ownerEmail });
                }

                mail.setSubject('Interview Reminder: ' + evt.StartDateTime.format());
                
                String body = 'Hi,\n\n'
                            + 'This is a reminder that you have an interview scheduled.\n\n'
                            + 'Subject: ' + evt.Subject + '\n'
                            + 'Date & Time: ' + evt.StartDateTime.format() + '\n'
                            + 'Location: ' + evt.Location + '\n'
                            + 'Description: ' + evt.Description + '\n\n'
                            + 'Thank you,\nRecruitment Team';
                
                mail.setPlainTextBody(body);
                emails.add(mail);
            }
    
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
        catch (Exception ex) {
            LogError.debugException(ex);
            LogError.createErrorItem('Event', 'sendInterviewReminders', ex.getMessage(), UserInfo.getUserId());        
        }
    }
    // Since there is lookups to two objects (contact,lead)
    private static String getEmailFromWhoId(Id whoId) 
    {
        if (whoId.getSObjectType() == Contact.SObjectType) 
        {
            Contact c = [SELECT Email FROM Contact WHERE Id = :whoId LIMIT 1];
            return c.Email;
        } 
        else if (whoId.getSObjectType() == Lead.SObjectType) 
        {
            Lead l = [SELECT Email FROM Lead WHERE Id = :whoId LIMIT 1];
            return l.Email;
        }
        return null;
    }
    // Since there is lookups to two objects (user,calendar)
    private static String getEmailFromOwnerId(Id ownerId) 
    {
        if (ownerId.getSObjectType() == User.SObjectType) 
        {
            User u = [SELECT Email FROM User WHERE Id = :ownerId LIMIT 1];
            return u.Email;
        } 
        return null;
    }
    
}