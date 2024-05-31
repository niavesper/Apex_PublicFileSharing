public with sharing class ContentVersionTriggerHandler {
    public static void makeFilesPublicForAward(List<ContentVersion> records) {
        // If there are no records, then there is nothing to do.
        if (records == null || records.isEmpty()) {
            return;
        }

        Map<Id, ContentVersion> cvIdMap = new Map<Id, ContentVersion>();
        Set<Id> cdIdSet = new Set<Id>();

        // Loop through ContentVersions passed from the trigger in order to (1) build a map
        // of their Ids and records; (2) build a set of add their ContentDocumentIds.
        for (ContentVersion cv : records) {
            cvIdMap.put(cv.Id, cv);
            cdIdSet.add(cv.ContentDocumentId);
        }

        System.debug('~~~makePublicForAward: ' + cvIdMap);

        // Get a list of ContentDocumentLinks for the ContentDocuments for which we need to make
        // ContentDocumentLinks public.
        List<ContentDocumentLink> cdls = [
            SELECT Id, ContentDocumentId, Visibility, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :cdIdSet
        ];

        // Loop through the ContentDocumentLinks and make them publicly viewable.
        List<ContentDocumentLink> existingLinks = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : cdls) {
            if (cdl.LinkedEntityId.getSObjectType() == Award__c.getSObjectType()) {
                cdl.Visibility = 'AllUsers';
                cdl.ShareType = 'V';
                existingLinks.add(cdl);
            }
        }

        // If there are ContentDocumentLinks to update, then update them.
        if (!existingLinks.isEmpty()) {
            try {
                System.debug('~~~existingLinks: ' + existingLinks);
                update existingLinks;
            } catch (DmlException e) {
                // Log the exception
                System.debug('Exception in makeFilesPublicForAward: ' + e.getMessage());
                System.debug('Failed records: ' + existingLinks);
                System.debug('Stack trace: ' + e.getStackTraceString());
            }
        }
    }
}
