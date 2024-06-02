public with sharing class ContentDocumentLinkTriggerHandler {
    private static final String AWARD_PREFIX = 'a0O'; // Replace with actual prefix for Award__c
    private static final String VISIBILITY_PUBLIC = 'AllUsers';
    private static final String SHARE_TYPE_VIEW = 'V';

    public static void handleBeforeInsertUpdate(List<ContentDocumentLink> records) {
        // If there are no records, then there is nothing to do.
        if (records == null || records.isEmpty()) {
            return;
        }

        // Loop through the ContentDocumentLinks and make them publicly viewable.
        for (ContentDocumentLink cdl : records) {
            if (cdl.LinkedEntityId != null && String.valueOf(cdl.LinkedEntityId).substring(0, 3) == AWARD_PREFIX) {
                cdl.Visibility = VISIBILITY_PUBLIC;
                cdl.ShareType = SHARE_TYPE_VIEW;
            }
        }
    }
}