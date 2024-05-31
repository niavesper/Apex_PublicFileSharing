/* It's my understanding that it's not possible in this case to test the scenario when a ContentVersion is created because when that happens,
ContentDocumentLink is created automatically, and there is no way to relate it to the Award__c record. When you add a file in the UI, you do it from the record's 
page, in the Files related list. This lets the system "know" which record's ID to put in the LinkedEntityId on the ContentDocumentLink. There's no way to simulate
this behavior via Apex, when the trigger is on ContentDocument, as far as I can tell. So by default, ContentDocumentLink gets related to the running user,
and that means the conditions for setting visibility to the desired values ("if (cdl.LinkedEntityId.getSObjectType() == Award__c.getSObjectType())") are not met.

*/

@isTest
public class ContentVersionTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        // Create test data for Award__c
        Award__c award = new Award__c();
        insert award;

        // Create test data for ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            Title = 'TestBudget',
            PathOnClient = 'TestBudget.csv',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Title = 'TestBudget'];

        // Create ContentDocumentLink to link ContentDocument to Award__c
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = documents[0].Id,
            LinkedEntityId = award.Id,
            ShareType = 'I', // Initial share type
            Visibility = 'InternalUsers'
        );
        insert cdl;
    }
    
    @isTest
    static void testMakeFilesPublicForAwardAfterUpdate() {
        // Retrieve the ContentVersion created in test setup
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

        // Update the ContentVersion to trigger the after update logic
        contentVersion.Title = 'TestBudget2';
        update contentVersion;

        // Verify that the ContentDocumentLink visibility has been updated
        ContentDocumentLink updatedLink = [
            SELECT Id, Visibility, ShareType
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :contentVersion.ContentDocumentId
            LIMIT 1
        ];

        System.assertEquals('AllUsers', updatedLink.Visibility, 'Visibility should be updated to AllUsers');
        System.assertEquals('V', updatedLink.ShareType, 'ShareType should be updated to V');
    }
}
