trigger ContentVersionTrigger on ContentVersion (after insert, after update) {
    System.debug('ContentVersionTrigger: Trigger executed');
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            System.debug('ContentVersionTrigger: After Insert or Update');
            ContentVersionTriggerHandler.makePublicForAward(Trigger.new);
        }
    }
}
