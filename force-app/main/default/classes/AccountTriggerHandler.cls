public with sharing class AccountTriggerHandler extends TriggerHandler {

    public AccountTriggerHandler() {
        // Constructor
    }

    protected override void beforeInsert() {
        List<Account> newAccounts = (List<Account>) Trigger.new;
        // Logic to modify account names before inserting
        for (Account acc : newAccounts) {
            String newName = acc.Name + ' - Adaptus';
            acc.Name = newName.length() > 80 ? newName.substring(0, 80) : newName;
        }
    }

    protected override void afterInsert() {
        List<Account> newAccounts = (List<Account>) Trigger.new;
        createContactsForAccounts(newAccounts);
    }

    protected override void afterUpdate() {
        List<Account> updatedAccounts = (List<Account>) Trigger.new;
        createContactsForAccounts(updatedAccounts);
    }

    private void createContactsForAccounts(List<Account> accounts) {
        List<Contact> contactsToCreate = new List<Contact>();
        for (Account acc : accounts) {
            Contact con = new Contact(
                FirstName = 'Candidate',
                LastName = acc.Name,
                AccountId = acc.Id,
                Email = 'candidate'+ acc.Id + '@adaptus.com'
            );
            contactsToCreate.add(con);
        }
        if (!contactsToCreate.isEmpty()) {
            Database.insert(contactsToCreate);
        }
    }

    protected override void afterDelete() {
        List<Account> deletedAccounts = (List<Account>) Trigger.old;
        // Logic to create tasks after deleting accounts
        List<Task> tasksToCreate = new List<Task>();
        for (Account acc : deletedAccounts) {
            Task task = new Task(
                Subject = 'Deleted Account ' + acc.Name,
                ActivityDate = Date.today()
            );
            tasksToCreate.add(task);
        }
        if (!tasksToCreate.isEmpty()) {
            Database.insert(tasksToCreate);
        }
    }
}
