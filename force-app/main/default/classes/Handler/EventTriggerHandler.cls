public with sharing class EventTriggerHandler {
    // Prevent meetings on weekends
    public static void calendarWeekendValidation(List<Event> events)
    {
        try 
        {
            for(Event e : events)
            {
                // Skip if start/end is missing
                if (e.StartDateTime == null || e.EndDateTime == null) 
                {
                    continue;
                }
                Integer dayOfWeek = e.StartDateTime.toStartOfWeek().daysBetween(e.StartDateTime);
                if (dayOfWeek == 5 || dayOfWeek == 6) { // Saturday = 5, Sunday = 6
                    e.addError('Meetings cannot be scheduled on weekends.');
                }
            }
        }
        catch (Exception ex) 
        {
            LogError.debugException(ex);
            LogError.createErrorItem('Event', 'calendarWeekendValidation', ex.getMessage(), UserInfo.getUserId());        
        }
    }
    // Prevent scheduling meetings simultaneously
     public static void calendarWithinOverlapValidation(List<Event> events)
     {
        try 
        {
            
            for (Integer i = 0; i < events.size(); i++) 
            {
                Event currentEvent = events[i];
                if (currentEvent.StartDateTime == null || currentEvent.EndDateTime == null) {
                    continue; 
                }
                Long currentStart = currentEvent.StartDateTime.getTime() / 60000; //epoch
                Long currentEnd = currentEvent.EndDateTime.getTime() / 60000; // epoch
                for (Integer j = 0; j < events.size(); j++) 
                {
                    if (i == j) 
                    {
                        continue;
                    }
                    Event otherEvent = events[j];
                    // Must be for same recruiter and same recruiter candidate
                    if (currentEvent.OwnerId != otherEvent.OwnerId && currentEvent.WhoId != otherEvent.WhoId) 
                    {
                        continue;
                    }
                    if (otherEvent.StartDateTime == null || otherEvent.EndDateTime == null)
                    {
                        continue;
                    }
                    
                    Long otherStart = otherEvent.StartDateTime.getTime() / 60000; //epoch
                    Long otherEnd = otherEvent.EndDateTime.getTime() / 60000; //epoch
                    // Easy: Same start time
                    if (currentStart == otherStart) 
                    {
                        currentEvent.addError('Another event in this scheduled events has the same start time.');
                        break;
                    }
                    // Hard: Any overlap
                    if (currentStart <= otherEnd && otherStart <= currentEnd) 
                    {
                        currentEvent.addError('This event overlaps with another event in this scheduled events.');
                        break;
                    }                       
                }
            }
        }
        catch (Exception ex) 
        {
            LogError.debugException(ex);
            LogError.createErrorItem('Event', 'calendarWithinOverlapValidation', ex.getMessage(), UserInfo.getUserId());        
        }
    }
    // Prevent meetings overlap with existing events
    public static void calendarExisitngOverlapValidation(List<Event> events)
    {
        try 
        {
            Set<Id> ownerIds = new Set<Id>();
            for (Event e : events) {
                if (e.OwnerId != null) {
                    ownerIds.add(e.OwnerId);
                }
            }
            // Get existing events for affected users (excluding new events)
            List<Event> existingEvents = [
                SELECT Id, StartDateTime, EndDateTime, OwnerId
                FROM Event
                WHERE OwnerId IN :ownerIds
                AND StartDateTime != null
                AND EndDateTime != null
                AND Id NOT IN :events
            ];
        
            for (Integer i = 0; i < events.size(); i++) 
            {
                Event newEvent = events[i];

                if (newEvent.StartDateTime == null || newEvent.EndDateTime == null) {
                    continue; 
                }
                // Convert to epoch minutes
                Long eventStart = newEvent.StartDateTime.getTime() / 60000;
                Long eventEnd = newEvent.EndDateTime.getTime() / 60000;
            
                for (Event existingEvent : existingEvents) 
                {
                    // Must be for same recruiter and same recruiter candidate
                    if (existingEvent.OwnerId != newEvent.OwnerId && existingEvent.WhoId != newEvent.WhoId) 
                    {
                        continue;
                    }
                    // Convert to epoch minutes
                    Long existingStart = existingEvent.StartDateTime.getTime() / 60000;
                    Long existingEnd = existingEvent.EndDateTime.getTime() / 60000;
                    // Easy: Same start time
                    if (existingStart == newStart) {
                        newEvent.addError('Another event is already scheduled at this exact start time.');
                        break;
                    }
                    // Hard: Any overlap
                    if(newStart <= existingEnd && existingStart <= newEnd)
                    {
                        newEvent.addError('This meeting overlaps with another existing meeting.');
                        break;
                    }
                }
            }
        }
        catch (Exception ex) 
        {
            LogError.debugException(ex);
            LogError.createErrorItem('Event', 'calendarExisitngOverlapValidation', ex.getMessage(), UserInfo.getUserId());        
        }
   }
}