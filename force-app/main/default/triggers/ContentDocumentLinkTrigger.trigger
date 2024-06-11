// Date:    06/11/2024
// Created with help from AI.
// Description: Trigger created to trigger the ContentDocumentLinkTriggerHandler class. 
// History:   V.1

trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    if (Trigger.isBefore) {
        ContentDocumentLinkTriggerHandler.handleBeforeInsertUpdate(Trigger.new);
    }
}
