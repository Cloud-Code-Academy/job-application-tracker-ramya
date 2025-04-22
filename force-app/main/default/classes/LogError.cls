public with sharing class LogError {
    public static void  createErrorItem(String obj, String method, String description, Id ownerId) {
              description = description.length() > 131072 ? description.substring(0, 131072) : description;
              ErrorFromApex__c item = new ErrorFromApex__c(
                ObjectName__c = obj,
                ApexMethodName__c = method,
                Description__c = description,
                OwnerId = ownerId
            );
            insert item;
        }
        public static void debugException(Exception e) {
            System.debug(LoggingLevel.ERROR, '*** Exception occured!!***');
            System.debug(LoggingLevel.ERROR,'Exception Type caught: ' + e.getTypeName());
            System.debug(LoggingLevel.ERROR,'Message: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR,'Cause: ' + e.getCause());
            System.debug(LoggingLevel.ERROR,'Line Number: ' + e.getLineNumber());
            System.debug(LoggingLevel.ERROR,'Stack trace: ' + e.getStackTraceString());
        }
    
}