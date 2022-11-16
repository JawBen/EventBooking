@isTest
public class TestDataFactory {
    public static List<Account> createAccountsWithCases(Integer numAccts, Integer numCasesPerAcct) {
        List<Account> accts = new List<Account>();
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i);
            accts.add(a);
        }
        insert accts;
        //Create contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];
            // For each account just inserted, add Contacts
            for (Integer k=0;k<numCasesPerAcct;k++) {
                contacts.add(new Contacts(FirstName = 'test',
                                       LastName='test',
                                       email= 'test@test.com'
                                       RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId(),
                                       Language__c = 'EN',
                                       birthdate = Date.newInstance(1991, 09, 09),
                                       AccountId=acct.Id));
            }
        }

        insert contacts;

        List<Case> cases = new List<Case>();
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];
            Contact contactObj = contacts[j];
            // For each account just inserted, add Cases
            for (Integer k=0;k<numCasesPerAcct;k++) {
                cases.add(new Case(Name=acct.Name + ' Case ' + k,
                                       Status='Working',
                                       Origin='Phone',
                                       AccountId=acct.Id,
                                       ContactId = contactObj.Id));
            }
        }
        // Insert all Cases for all accounts.
        insert cases;
        return accts;
    }
}