This code changes the default sharing setting for files uploaded to records of a custom object Award__c from private to public. The requirement was to make files uploaded by internal users visible to authenticated Experience Cloud users by default, since 99% of files uploaded by internal users must be visible to external users.

**MAIN BRANCH:**

The first attempt at building this functionality. The trigger is on the ContentVersion object. I kept experiencing trigger recursion error when running the test class, even when I changed the insert of test ContentVersion records to be in batches instead of all at once, which is why I tried to rebuild the functionality using the trigger on ContentDocumentLink.

*About the test class:*

We are testing only the scenario where we update ContentVersion records, not insert them. It's my understanding that testing insertion is not possible because during insertion of a ContentVerison, ContentDocumentLink is created automatically, and there is no way to relate it to the Award__c record via Apex. When you add a file in the UI, you do it from the record's page, in the Files related list. This lets the system "know" which record's ID to put in the LinkedEntityId on the ContentDocumentLink. There's no way to simulate this behavior via Apex, when the trigger is on ContentDocument, as far as I can tell. So by default, ContentDocumentLink gets related to the running user, and there is no way to make it related to Award__c records via Apex. All this prevents us from being able to test the change to file sharing settings upon ContentVersion creation.

**feature/contentDocumentLinkTrigger BRANCH**

The second attempt at building this functionality. The trigger is on the ContentDocumentLink object. I made the trigger fire only on CDL insert (and not update) because I didn't want it to reset sharing settings back to public when users manually set them to private.