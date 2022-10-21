/**
 * Created by brooks on 10/20/2022.
 */

@IsTest
private class SubsriptionValidation_Test {
    @IsTest
    static void subscriptionWithPriorStartDateShouldThrowError() {
        //given
        Subscription__c newSub = new Subscription__c(Start_Date__c = Date.newInstance(2022, 10, 01),
                Expiration_Date__c = Date.newInstance(2022, 10, 31));
        Subscription__c oldSubscription = new Subscription__c(Start_Date__c = Date.newInstance(2022, 09, 01),
                Expiration_Date__c = Date.newInstance(2023, 11, 01));
        //when
        SubscriptionTriggerHandler.validateSubscriptionDatePriorStartDate(newSub, oldSubscription);
        //then
        Assert.isTrue(newSub.hasErrors() == true, 'It should have an error assigned to it');
    }

    @IsTest
    static void subscriptionWithPriorStartDateNoError(){
        //given
        Subscription__c newSubscription = new Subscription__c(Start_Date__c = Date.newInstance(2022, 10, 01),
                Expiration_Date__c = Date.newInstance(2022, 10, 31));
        Subscription__c oldSubscription = new Subscription__c(Start_Date__c = Date.newInstance(2022, 09, 01),
                Expiration_Date__c = Date.newInstance(2022, 09, 31));
        //when
        SubscriptionTriggerHandler.validateSubscriptionDatePriorStartDate(newSubscription, oldSubscription);
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
    static void getExistingSubscriptionsByCustomerAndFarmId(){
        //given
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact');
        Solar_Farm__c farm = new Solar_Farm__c();

        List<SObject> sobjs = new List<SObject>{contact, farm};
        insert sobjs;
        Subscription__c oldSubscription = new Subscription__c(Start_Date__c = Date.newInstance(2022, 10, 01),
                Expiration_Date__c = Date.newInstance(2022, 10, 31),
                Customer__c =contact.Id, Solar_Farm__c = farm.Id);
        System.debug(oldSubscription);
        insert oldSubscription;
        //when
        System.debug(SubscriptionSelector.getExistingSubscriptionsByCustomerAndFarmId(new Set<Id>{contact.Id}, new Set<Id>{farm.Id}));
        //then
    }
}