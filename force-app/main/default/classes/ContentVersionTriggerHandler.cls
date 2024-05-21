public with sharing class ContentVersionTriggerHandler {
    public static void makePublicForAward(List<ContentVersion> records) {
        Map<Id, ContentVersion> cvIdMap = new Map<Id, ContentVersion>();
        for (ContentVersion cv : records) {
            cvIdMap.put(cv.Id, cv);
        }
        
        System.debug('~~~makePublicForAward: ' + cvIdMap);
        Set<Id> cdIdSet = new Set<Id>();
        
        
        for (ContentVersion cv : cvIdMap.values()) {
            cdIdSet.add(cv.ContentDocumentId);
        }
        
        List<ContentDocumentLink> cdls = [
            SELECT Id, ContentDocumentId, Visibility, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :cdIdSet
        ];
        
        List<ContentDocumentLink> existingLinks = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : cdls) {
            if (cdl.LinkedEntityId.getSObjectType() == Award__c.getSObjectType()) {
                cdl.Visibility = 'AllUsers';
                cdl.ShareType = 'V';
                existingLinks.add(cdl);
            }
        }
        
        if (!existingLinks.isEmpty()) {
            System.debug('~~~existingLinks: ' + existingLinks);
            Database.update(existingLinks);
        }
    }
    
}
