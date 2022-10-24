/**
 * Created by brooks on 10/20/2022.
 */

@IsTest
private class SubscriptionTriggerHandler_Test {
    @IsTest
    static void subscriptionWithPriorStartDateShouldThrowError() {
        //given
        Subscription__c newSub = new Subscription__c(Start_Date__c = Date.newInstance(2022, 10, 01),
                Expiration_Date__c = Date.newInstance(2022, 10, 31));
        Subscription__c oldSubscription = new Subscription__c(Start_Date__c = Date.newInstance(2022, 09, 01),
                Expiration_Date__c = Date.newInstance(2023, 11, 01));
        //when
        SubscriptionTriggerHandler.validateSubscriptionDatePostStartDate(newSub, oldSubscription);
        //then
        Assert.isTrue(newSub.hasErrors() == true, 'It should have an error assigned to it');
    }

    @IsTest
    static void subscriptionWithPriorStartDateNoError(){
        //given
        Subscription__c newSubscription = new Subscription__c(Start_Date__c = Date.newInstance(2022, 10, 01),
                Expiration_Date__c = Date.newInstance(2022, 10, 31));
        Subscription__c oldSubscription = new Subscription__c(Start_Date__c = Date.newInstance(2022, 09, 01),
                Expiration_Date__c = Date.newInstance(2022, 09, 30));
        //when
        SubscriptionTriggerHandler.validateSubscriptionDatePostStartDate(newSubscription, oldSubscription);
        //then
        Assert.isFalse(newSubscription.hasErrors(), 'There should not be an error attached');
    }

    @IsTest
    static void subscriptionWithEarlierStartDateThrowError(){
        //given
        Subscription__c newSubscription = new Subscription__c(Start_Date__c = Date.newInstance(2022, 10, 01),
                Expiration_Date__c = Date.newInstance(2022, 10, 31));
        Subscription__c oldSubscription = new Subscription__c(Start_Date__c = Date.newInstance(2022, 10, 15),
                Expiration_Date__c = Date.newInstance(2022, 10, 31));
        //when
        SubscriptionTriggerHandler.validateSubscriptionPreStartDate(newSubscription, oldSubscription);
        //then
        Assert.isTrue(newSubscription.hasErrors(), 'It should have errors added');
    }

    @IsTest
    static void subscriptionWithEarlierStartDateNoError(){
        //given
        Subscription__c newSubscription = new Subscription__c(Start_Date__c = Date.newInstance(2022, 10, 01),
                Expiration_Date__c = Date.newInstance(2022, 10, 14));
        Subscription__c oldSubscription = new Subscription__c(Start_Date__c = Date.newInstance(2022, 10, 15),
                Expiration_Date__c = Date.newInstance(2022, 10, 31));
        //when
        SubscriptionTriggerHandler.validateSubscriptionPreStartDate(newSubscription, oldSubscription);
        //then
        Assert.isFalse(newSubscription.hasErrors(), 'It should not have errors added');
    }

    @IsTest
    static void getExistingSubscriptionsByCustomerAndFarmIdSingle(){
        //given
        Subscription__c newSubscription = new Subscription__c(Start_Date__c = Date.today(), Expiration_Date__c = Date.today().addDays(365),
                Customer__c = fflib_IDGenerator.generate(Contact.SObjectType),
                Solar_Farm__c = fflib_IDGenerator.generate(Solar_Farm__c.SObjectType));

        Subscription__c sub1 = new Subscription__c(Start_Date__c = Date.newInstance(2022, 10 , 01),
                Expiration_Date__c = Date.newInstance(2022, 10, 31),
                Customer__c = newSubscription.Customer__c, Solar_Farm__c = newSubscription.Solar_Farm__c);
        //when
        SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
        Map<Id, List<Subscription__c>> results = handler.buildSubscriptionMap(new List<Subscription__c>{sub1});
        //then
        Assert.isTrue(results.size() == 1);
        Assert.isTrue(results.containsKey(newSubscription.Customer__c), 'It should have the correct key set');
    }

    @IsTest
    static void getExistingSubscriptionsByCustomerAndFarmIdMultiple(){
        //given
        Subscription__c newSubscription = new Subscription__c(Start_Date__c = Date.today(), Expiration_Date__c = Date.today().addDays(365),
                Customer__c = fflib_IDGenerator.generate(Contact.SObjectType),
                Solar_Farm__c = fflib_IDGenerator.generate(Solar_Farm__c.SObjectType));

        Subscription__c sub1 = new Subscription__c(Start_Date__c = Date.newInstance(2022, 10 , 01),
                Expiration_Date__c = Date.newInstance(2022, 10, 31),
                Customer__c = newSubscription.Customer__c, Solar_Farm__c = newSubscription.Solar_Farm__c);
        Subscription__c sub2 = new Subscription__c(Start_Date__c = Date.newInstance(2021, 10 , 01),
                Expiration_Date__c = Date.newInstance(2021, 10, 31),
                Customer__c = newSubscription.Customer__c, Solar_Farm__c = newSubscription.Solar_Farm__c);

        //when
        SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
        Map<Id, List<Subscription__c>> results = handler.buildSubscriptionMap(new List<Subscription__c>{sub1, sub2});
        //then
        Assert.areEqual(results.get(newSubscription.Customer__c).size(), 2, 'It should have mapped two records');
        Assert.isTrue(results.containsKey(newSubscription.Customer__c), 'It should have the correct key set');
    }
    @IsTest
    static void itShouldFilterChangedRecords(){
        //given
        SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
        Subscription__c updatedRecord = new Subscription__c(Id = fflib_IDGenerator.generate(Subscription__c.SObjectType),
                Start_Date__c = Date.newInstance(2022, 10, 01),
                Expiration_Date__c = Date.newInstance(2022, 10, 31));

        Subscription__c oldSubscription = New Subscription__c(Id = updatedRecord.Id, Start_Date__c = updatedRecord.Start_Date__c,
                Expiration_Date__c = Date.newInstance(2022,10, 30));
        //when
        List<Subscription__c> filteredRecords = handler.filterForChangedSubscriptionDates(new List<Subscription__c>{updatedRecord},
                new Map<Id, Subscription__c>{oldSubscription.Id => oldSubscription});
        //then
        Assert.isTrue(filteredRecords.size() == 1, 'It should filter a changed record');
    }

    @IsTest
    static void itShouldNotFilterChangedRecords(){
        //given
        SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
        Subscription__c updatedRecord = new Subscription__c(Id = fflib_IDGenerator.generate(Subscription__c.SObjectType),
                Start_Date__c = Date.newInstance(2022, 10, 01),
                Expiration_Date__c = Date.newInstance(2022, 10, 31));

        Subscription__c oldSubscription = updatedRecord;
        //when
        List<Subscription__c> filteredRecords = handler.filterForChangedSubscriptionDates(new List<Subscription__c>{updatedRecord},
                new Map<Id, Subscription__c>{oldSubscription.Id => oldSubscription});
        //then
        Assert.isTrue(filteredRecords.size() == 0, 'It should not filter a changed record');
    }

    @IsTest
    static void itShouldInsertRecordIntegration(){
        //TODO implement flexible mechanism for bulk testing with custom metadata
        //integration test for the happy path
        //given
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact');
        Solar_Farm__c solarFarm = new Solar_Farm__c();
        insert new List<SObject>{contact, solarFarm};
        insert new Subscription__c(Start_Date__c = Date.newInstance(2021, 01, 01),
                Expiration_Date__c = Date.newInstance(2021, 12, 31),
                Customer__c = contact.Id, Solar_Farm__c = solarFarm.Id);
        //when
        Subscription__c newSubscription = new Subscription__c(Start_Date__c = Date.today(), Expiration_Date__c = Date.today().addDays(30),
                Customer__c = contact.Id, Solar_Farm__c = solarFarm.Id);
        insert newSubscription;
        // then
        Subscription__c updatedSubscription = [SELECT Id, Customer__c, Solar_Farm__c
        FROM Subscription__c
        WHERE Start_Date__c =: Date.today() LIMIT 1];
        Assert.isTrue(updatedSubscription.Customer__c == contact.Id, 'It should been inserted with the ' +
                'correct contact Id');
        Assert.isTrue(updatedSubscription.Solar_Farm__c == solarFarm.Id, 'It should have been inserted ' +
                'with the correct solar farm Id');
    }
    @IsTest
    static void itShouldNotUpdateRecordIntegration(){
        //integration test for the before update
        //given
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact');
        Solar_Farm__c solarFarm = new Solar_Farm__c();
        insert new List<SObject>{contact, solarFarm};
        insert new Subscription__c(Start_Date__c = Date.newInstance(2021, 01, 01),
                Expiration_Date__c = Date.newInstance(2021, 12, 31),
                Customer__c = contact.Id, Solar_Farm__c = solarFarm.Id);
        //when
        Subscription__c newSubscription = new Subscription__c(Start_Date__c = Date.today(), Expiration_Date__c = Date.today().addDays(30),
                Customer__c = contact.Id, Solar_Farm__c = solarFarm.Id);
        insert newSubscription;
        // then
        Subscription__c updatedSubscription = [SELECT Id, Customer__c, Solar_Farm__c
        FROM Subscription__c
        WHERE Start_Date__c =: Date.today() LIMIT 1];
        updatedSubscription.Start_Date__c = Date.newInstance(2021, 12, 30);
        try{
            update updatedSubscription;
            Assert.fail('We should never get here');
        }catch (Exception e){
            Assert.isInstanceOfType(e, DmlException.class, 'It should throw a DML Exception');
        }

    }

}