trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update) {
    if (Trigger.isBefore) {
        ContentDocumentLinkTriggerHandler.handleBeforeInsertUpdate(Trigger.new);
    }
}