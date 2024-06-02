@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        
        // Create a test Award__c record
        Award__c award = new Award__c();
        insert award;

        // Create test ContentVersions. This will auto-create ContentDocuments,
        // which will later be queried by test methods.
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 100; i++) {
            ContentVersion contentVersion = new ContentVersion(
                Title = 'TestBudget' + i,
                PathOnClient = 'TestBudget' + i + '.csv',
                VersionData = Blob.valueOf('Test Data '),
                IsMajorVersion = true
            );
            contentVersions.add(contentVersion);
        }
        insert contentVersions;
    }

    @isTest
    static void testSingleContentDocumentLinkInsert() {
        
        // Retrieve the test Award__c record
        Award__c award = [SELECT Id FROM Award__c LIMIT 1];

        // Retrieve the test ContentDocument
        ContentDocument contentDocument = [SELECT Id FROM ContentDocument LIMIT 1];

        // Create a ContentDocumentLink
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocument.Id,
            LinkedEntityId = award.Id
        );

        Test.startTest();
        insert cdl;
        Test.stopTest();

        // Verify that the ContentDocumentLink visibility has been set to expected values
        ContentDocumentLink insertedCdl= [SELECT Id, Visibility, ShareType FROM ContentDocumentLink WHERE Id = :cdl.Id];
        System.assertEquals('AllUsers', insertedCdl.Visibility, 'Visibility should be updated to AllUsers');
        System.assertEquals('V', insertedCdl.ShareType, 'ShareType should be updated to V');
    }

    @isTest
    static void testBulkContentDocumentLinkInsert() {
        // Retrieve the test Award__c record
        Award__c award = [SELECT Id FROM Award__c LIMIT 1];

        // Retrieve test ContentDocuments
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];

        // Create ContentDocumentLinks   
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();     
        for(ContentDocument cd : contentDocuments) {
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = cd.Id,
                LinkedEntityId = award.Id
                );
                cdls.add(cdl);   
        }
 
        Test.startTest();
        insert cdls;
        Test.stopTest();

        // Verify that the ContentDocumentLink visibility has been set to expected values
        List<ContentDocumentLink> insertedCdls = [SELECT Id, Visibility, ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :award.Id];
        for (ContentDocumentLink insertedCdl : insertedCdls) {
            System.assertEquals('AllUsers', insertedCdl.Visibility, 'Visibility should be updated to AllUsers');
            System.assertEquals('V', insertedCdl.ShareType, 'ShareType should be updated to V');
        }
    }
}