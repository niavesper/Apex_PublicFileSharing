public with sharing class ContentVersionTriggerHandler {
        // Static counter to track trigger execution
        private static Integer triggerExecutionCount = 0;
    
        public static void makeFilesPublicForAward(List<ContentVersion> records) {

        // Increment the counter each time the method is called
        triggerExecutionCount++;
        System.debug('Trigger execution count: ' + triggerExecutionCount);

        // If there are no records, then there is nothing to do.
        if (records == null || records.isEmpty()) {
            return;
        }

        Set<Id> cdIdSet = new Set<Id>();

        for (ContentVersion cv : records) {
            cdIdSet.add(cv.ContentDocumentId);
        }
        
        // Get a list of ContentDocumentLinks for the ContentDocuments for which we need to make
        // ContentDocumentLinks public.
        List<ContentDocumentLink> cdls = [
            SELECT Id, ContentDocumentId, Visibility, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :cdIdSet
            AND LinkedEntityId IN (SELECT Id FROM Award__c)
        ];

        // Loop through the ContentDocumentLinks and make them publicly viewable.
        List<ContentDocumentLink> existingLinks = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : cdls) {            
            cdl.Visibility = 'AllUsers';
            cdl.ShareType = 'V';
            existingLinks.add(cdl);
            }
        
        // If there are ContentDocumentLinks to update, then update them.
        if (!existingLinks.isEmpty()) {
            try {
                System.debug('~~~existingLinks: ' + existingLinks);
                System.debug('~~~existingLinks.size() from prod class/try-catch: ' + existingLinks.size());
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
