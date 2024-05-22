trigger ContentVersionTrigger on ContentVersion (after insert, after update) {
                ContentVersionTriggerHandler.makeFilesPublicForAward(Trigger.new);
        }