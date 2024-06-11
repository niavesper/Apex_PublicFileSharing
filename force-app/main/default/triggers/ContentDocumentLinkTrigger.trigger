// Date:    06/11/2024
// Author:  Ksenia Choate
// Created with help from AI.
// Description: Trigger created to trigger the ContentDocumentLinkTriggerHandler class.
// See DTS Salesforce team Jira issue FORCE-656 / FORCE-671 for more context. 
// History:   V.1

trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    if (Trigger.isBefore) {
        ContentDocumentLinkTriggerHandler.handleBeforeInsertUpdate(Trigger.new);
    }
}