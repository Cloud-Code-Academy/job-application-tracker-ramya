trigger EventTrigger on Event (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            // Prevent meetings on weekends
            EventTiggerHandler.calendarValidation(Trigger.new);
             // Prevent scheduling meetings simultaneously
            EventTiggerHandler.calendarWithinOverlapValidation(Trigger.new);
              // Prevent meetings overlap with existing events
            EventTiggerHandler.calendarExisitngOverlapValidation(Trigger.new);
        }
    }
}