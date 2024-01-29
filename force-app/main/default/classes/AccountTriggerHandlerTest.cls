@isTest
private class AccountTriggerHandlerTest {

    @isTest static void testBeforeInsert() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };

        Test.startTest();
        // Insert accounts to trigger the logic
        insert testAccounts;
        Test.stopTest();

        // Verify that account names were modified correctly
        for (Account acc : [SELECT Name FROM Account WHERE Id IN :testAccounts]) {
            System.assert(acc.Name.endsWith(' - Adaptus'), 'Name should end with - Adaptus');
        }
    }

    @isTest static void testAfterInsert() {
        // Create and insert a test account
        Account testAccount = new Account(Name = 'Test Account');

        Test.startTest();
        insert testAccount;
        Test.stopTest();

        // Verify that a related contact was created
        List<Contact> relatedContacts = [SELECT Id, AccountId FROM Contact WHERE AccountId = :testAccount.Id];
        System.assertEquals(1, relatedContacts.size(), 'One contact should be created');
    }

    @isTest static void testAfterUpdate() {
        // Create, insert, and then update a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        testAccount.Name = 'Updated Test Account';
        
        Test.startTest();
        // Update the account to trigger the logic
        update testAccount;
        Test.stopTest();

        // Verify that a new contact was created related to the updated account
        List<Contact> relatedContacts = [SELECT Id, AccountId FROM Contact WHERE AccountId = :testAccount.Id];
        System.assertEquals(2, relatedContacts.size(), 'A new contact should be created for updated account');
    }

    @isTest static void testAfterDelete() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Get the initial count of tasks
        Integer initialTaskCount = [SELECT COUNT() FROM Task];
    
        Test.startTest();
        // Delete the account to trigger the logic
        delete testAccount;
        Test.stopTest();
    
        // Get the count of tasks after deletion
        Integer finalTaskCount = [SELECT COUNT() FROM Task];
    
        // Verify that a task was created for the deleted account
        System.assertEquals(initialTaskCount + 1, finalTaskCount, 'One task should be created for deleted account');
    }
    

}
