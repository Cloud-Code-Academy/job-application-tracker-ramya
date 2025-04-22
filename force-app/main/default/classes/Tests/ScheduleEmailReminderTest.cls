@isTest
public with sharing class ScheduleEmailReminderTest {
        @TestSetup
        static void setupData(){
            // Create a user (Event owner)
            User u = new User(
                Alias = 'tuserss',
                Email = 'aramya.ten@gmail.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
                TimeZoneSidKey = 'Asia/Singapore',
                UserName = 'testusers'+DateTime.now().getTime()+'@example.com'
            );
            insert u;
             // Create Contact (Candidate)
            Contact con = new Contact(
                FirstName = 'tests',
                LastName = 'users',
                Email = 'vengatsoft88@gmail.com',
                Phone = '123-456-7890'
            );
            insert con;
             // Create Job Application
            Job_Application__c job = new Job_Application__c(
                Application_Date__c = Date.today(),
                Company_Name__c = 'Salesforce',
                Position_Title__c = 'Data Analyst',
                Location__c ='Virtual',
                Primary_Contact__c = con.Id,
                Status__c ='Applied'
            );
            insert job; 

            // Create an Event scheduled for tomorrow
            Event ev = new Event(
                OwnerId = u.Id,
                WhatId = job.Id,
                WhoId = con.Id,
                Subject = 'Salesforce Interview Meeting',
                StartDateTime = DateTime.now().addDays(1).addHours(0),
                EndDateTime = DateTime.now().addDays(1).addHours(10)
             );
            insert ev;
       }
        @isTest
       static void testScheduledEmailReminder()
       {
            Test.startTest();
            ScheduleEmailReminder scheduler = new ScheduleEmailReminder();
            scheduler.execute(null); 
            Test.stopTest();
       }
       
}