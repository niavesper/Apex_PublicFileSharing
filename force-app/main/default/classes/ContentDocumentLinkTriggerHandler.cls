public with sharing class ContentDocumentLinkTriggerHandler {
    public static void handleBeforeInsertUpdate(List<ContentDocumentLink> records) {
        // Prefix for Award__c records
        String awardPrefix = 'a0O';

        for (ContentDocumentLink cdl : records) {
            if (cdl.LinkedEntityId != null && String.valueOf(cdl.LinkedEntityId).substring(0, 3) == awardPrefix) {
                cdl.Visibility = 'AllUsers';
                cdl.ShareType = 'V';
            }
        }
    }
}