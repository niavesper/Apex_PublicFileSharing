trigger ContentVersionTrigger on ContentVersion (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            ContentVersionTriggerHandler.makeFilesPublicForAward(Trigger.new);
        }
    }
}