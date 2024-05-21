public with sharing class ContentVersionTriggerHandler {
    private static Boolean isTriggerRunning = false;

    public static void handleContentVersion(List<ContentVersion> contentVersions) {
        System.debug('ContentVersionTriggerHandler: handleContentVersion called');
        if (isTriggerRunning) {
            System.debug('ContentVersionTriggerHandler: Trigger is already running, exiting');
            return;
        }

        try {
            isTriggerRunning = true;

            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
            Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>();

            for (ContentVersion cv : contentVersions) {
                System.debug('Processing ContentVersion: ' + cv.Id);
                // Add ContentVersion to map for additional settings
                contentVersionMap.put(cv.Id, cv);

                // Find the parent Award__c record
                if (cv.FirstPublishLocationId != null && cv.FirstPublishLocationId.getSObjectType() == Award__c.SObjectType) {
                    System.debug('cv.FirstPublishLocationId.getSObjectType() :' + cv.FirstPublishLocationId.getSObjectType());

                    // Check if the ContentDocumentLink already exists
                    List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink 
                                                               WHERE ContentDocumentId = :cv.ContentDocumentId 
                                                               AND LinkedEntityId = :cv.FirstPublishLocationId];

                    if (existingLinks.isEmpty()) {
                        System.debug('Creating new ContentDocumentLink for ContentDocumentId: ' + cv.ContentDocumentId);
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = cv.ContentDocumentId;
                        cdl.LinkedEntityId = cv.FirstPublishLocationId;
                        cdl.ShareType = 'V'; // Viewer access
                        cdl.Visibility = 'AllUsers'; // Customer Access toggle to "On"
                        contentDocumentLinks.add(cdl);
                    } else {
                        System.debug('ContentDocumentLink already exists for ContentDocumentId: ' + cv.ContentDocumentId);
                    }
                }
            }

            if (!contentDocumentLinks.isEmpty()) {
                insert contentDocumentLinks;
            }

            // Call method to set additional settings
            setAdditionalSettings(contentVersionMap);
        } finally {
            isTriggerRunning = false;
        }
    }

    public static void setAdditionalSettings(Map<Id, ContentVersion> contentVersions) {
        List<ContentDocument> contentDocumentsToUpdate = new List<ContentDocument>();
        List<ContentDistribution> contentDistributionsToUpdate = new List<ContentDistribution>();

        for (ContentVersion cv : contentVersions.values()) {
            ContentDocument cd = [SELECT Id, OwnerId FROM ContentDocument WHERE Id = :cv.ContentDocumentId LIMIT 1];

            if (cd != null) {
                cd.OwnerId = cv.CreatedById; // Set the Owner to the uploader
                contentDocumentsToUpdate.add(cd);
            }

            // Query related ContentDistribution records
            List<ContentDistribution> contentDistributions = [SELECT Id, PreferencesPasswordRequired 
                                                              FROM ContentDistribution 
                                                              WHERE ContentVersionId = :cv.Id];

            for (ContentDistribution cdistr : contentDistributions) {
                cdistr.PreferencesPasswordRequired = true; // Set PreferencesPasswordRequired to false
                contentDistributionsToUpdate.add(cdistr);
            }
        }

        if (!contentDocumentsToUpdate.isEmpty()) {
            update contentDocumentsToUpdate;
        }

        if (!contentDistributionsToUpdate.isEmpty()) {
            update contentDistributionsToUpdate;
        }

        // Implement additional settings updates here if required 
    }
}
