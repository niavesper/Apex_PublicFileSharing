@isTest
public class ContentVersionTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        
        // Create a test Award__c record
        Award__c award = new Award__c();
        insert award;

        // Create test ContentVersion records
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 100; i++) {
            ContentVersion contentVersionBulk = new ContentVersion(
                Title = 'TestBudget' + i,
                PathOnClient = 'TestBudget' + i + '.csv',
                VersionData = Blob.valueOf('Test Data ' + i),
                IsMajorVersion = true 
            );
            contentVersions.add(contentVersionBulk);
        }
        // Insert in batches to avoid DML limits
        if (contentVersions.size() == 50) { 
            insert contentVersions;
            contentVersions.clear(); // Empty the list for the next batch
        }

        // Insert any remaining records
        if (!contentVersions.isEmpty()) {
            insert contentVersions;
        }

        System.debug('contentVersions.size(): ' + contentVersions.size()); 

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title LIKE 'TestBudget%'];
        System.debug('documents.size(): ' + documents.size());

        // Create ContentDocumentLink to link ContentDocument to Award__c
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        for (ContentDocument doc : documents) {
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = doc.Id,
                LinkedEntityId = award.Id,
                ShareType = 'I', // Initial share type
                Visibility = 'InternalUsers' // Initial visibility
            );
            cdls.add(cdl);
        }
        insert cdls;
        System.debug('cdls: ' + cdls);
        System.debug('cdls.size(): ' + cdls.size());

    }
      
    @isTest
    static void testSingleContentVersionUpdate() {
        
         // Verify that test data is present
         List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId, Title FROM ContentVersion];
         System.debug('contentVersions in test method: ' + contentVersions);
        
        // Retrieve one of the ContentVersions created in test setup
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId, Title FROM ContentVersion LIMIT 1];
        

        Test.startTest();
        // Update the ContentVersion to trigger the after update logic
        contentVersion.Title = contentVersion.Title + 'Updated';
        update contentVersion;
        Test.stopTest();
        

        // Verify that the ContentDocumentLink visibility has been updated.
        // Filtering by LinkedEntityId is necessary because the system auto-creates
        // ContentDocumentLinks related to the running user, resulting in two
        // CDLs per ContentVersion.
        ContentDocumentLink updatedLink = [
            SELECT Id, Visibility, ShareType
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :contentVersion.ContentDocumentId
            AND LinkedEntityId IN (SELECT Id FROM Award__c)
            LIMIT 1
        ];
        

        System.assertEquals('AllUsers', updatedLink.Visibility, 'Visibility should be updated to AllUsers');
        System.assertEquals('V', updatedLink.ShareType, 'ShareType should be updated to V');
    }

    @isTest
    static void testBulkContentVersionUpdate() {
        
        // Retrieve the ContentVersions created in test setup
        List<ContentVersion> contentVersions = [SELECT Id, Title FROM ContentVersion WHERE Title LIKE 'TestBudget%'];
        System.debug('contentVersions: ' + contentVersions); 
        
        // Update the ContentVersions to trigger the after update logic
        for (ContentVersion contentVersion : contentVersions) {
            contentVersion.Title = contentVersion.Title + 'Updated';
        }

        Test.startTest();
        update contentVersions;
        System.debug('contentVersions after title update: ' + contentVersions); 
        Test.stopTest();

        // Verify that the ContentDocumentLink visibility has been updated for all records
        List<ContentVersion> contentVersionsBulk = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Title LIKE 'TestBudget%'
        ];
        System.debug('contentVersionsBulk: ' + contentVersionsBulk); 
        System.debug('contentVersionsBulk.size(): ' + contentVersionsBulk.size());

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentVersion cv : contentVersionsBulk) {
            contentDocumentIds.add(cv.ContentDocumentId);
        }
        System.debug('contentDocumentIds: ' + contentDocumentIds); 
        System.debug('contentDocumentIds.size(): ' + contentDocumentIds.size()); 

        List<ContentDocumentLink> updatedLinks;

        // Verify that the ContentDocumentLink visibility has been updated.
        // Filtering by LinkedEntityId is necessary because the system auto-creates
        // ContentDocumentLinks related to the running user, resulting in two
        // CDLs per ContentVersion.    
        updatedLinks = [
            SELECT Id, Visibility, ShareType, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :contentDocumentIds AND LinkedEntityId IN (SELECT Id FROM Award__c)
        ];
        System.debug('updatedLinks: ' + updatedLinks);
        System.debug('updatedLinks.size(): ' + updatedLinks.size()); 

        for (ContentDocumentLink updatedLink : updatedLinks) {
            System.assertEquals('AllUsers', updatedLink.Visibility, 'Visibility should be updated to AllUsers');
            System.assertEquals('V', updatedLink.ShareType, 'ShareType should be updated to V');
        }
    }
}
