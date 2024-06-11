// Date:    06/11/2024
// Author:  Ksenia Choate
// Created with help from AI.
// Description:   This code changes the default sharing setting for files uploaded
// to records of a custom object Award__c from private to public. The requirement was
// to make files uploaded by internal users visible to authenticated Experience Cloud users
// by default, since 99% of files uploaded by internal users must be visible to external users.
// See DTS Salesforce team Jira issue FORCE-656 / FORCE-672 for more context. 
// History:   V.1

public with sharing class ContentDocumentLinkTriggerHandler {
    private static final String AWARD_PREFIX = 'a0O'; // Three-digit prefix for the Award__c object
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