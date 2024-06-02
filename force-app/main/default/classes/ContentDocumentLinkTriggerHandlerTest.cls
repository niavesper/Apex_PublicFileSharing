@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        // Create a test Award__c record
        Award__c award = new Award__c();
        insert award;

        // Create a test ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            
            Title = 'TestVersion',
            PathOnClient = 'TestVersion.csv',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert contentVersion;
    }

    @isTest
    static void testContentDocumentLinkTrigger() {
        // Retrieve the test Award__c record
        Award__c award = [SELECT Id FROM Award__c LIMIT 1];

        // Retrieve the test ContentDocument
        ContentDocument contentDocument = [SELECT Id FROM ContentDocument LIMIT 1];

        // Create a ContentDocumentLink
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocument.Id,
            LinkedEntityId = award.Id,
            ShareType = 'I', // Initial share type
            Visibility = 'InternalUsers' // Initial visibility
        );

        Test.startTest();
        insert cdl;
        Test.stopTest();

        // Verify that the ContentDocumentLink visibility has been updated
        ContentDocumentLink updatedLink = [SELECT Id, Visibility, ShareType FROM ContentDocumentLink WHERE Id = :cdl.Id];
        System.assertEquals('AllUsers', updatedLink.Visibility, 'Visibility should be updated to AllUsers');
        System.assertEquals('V', updatedLink.ShareType, 'ShareType should be updated to V');
    }
}