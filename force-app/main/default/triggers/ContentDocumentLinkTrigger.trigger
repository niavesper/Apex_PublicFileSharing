trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    if (Trigger.isBefore) {
        ContentDocumentLinkTriggerHandler.handleBeforeInsertUpdate(Trigger.new);
    }
}