/**
 * Created by brooks on 10/21/2022.
 */

@IsTest
private class SubscriptionUpdateBatch_Test {
    @IsTest
    static void ItShouldUpdateStartDateStatus() {
        //given
        Subscription__c newSubscription = new Subscription__c(Start_Date__c = Date.today());
        Subscription__c expiredSubscription = new Subscription__c(Expiration_Date__c = Date.today());
        //when
        SubscriptionUpdateBatch subscriptionUpdateBatch = new SubscriptionUpdateBatch();
        subscriptionUpdateBatch.updateStatus(new List<Subscription__c>{newSubscription, expiredSubscription});
        //then
        Assert.isTrue(newSubscription.Status__c == 'Active');
        Assert.isTrue(expiredSubscription.Status__c == 'Expired');
    }
    @IsTest
    static void ItShouldUpdateEndDateStatusIntegration() {
        //given
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact');
        Solar_Farm__c solarFarm = new Solar_Farm__c();
        insert new List<SObject>{contact, solarFarm};
        insert new Subscription__c(Start_Date__c = Date.newInstance(2021, 01, 01),
                Expiration_Date__c = Date.newInstance(2021, 12, 31),
                Customer__c = contact.Id, Solar_Farm__c = solarFarm.Id);

        Subscription__c newSubscription = new Subscription__c(Start_Date__c = Date.today(), Expiration_Date__c = Date.today().addDays(30),
                Customer__c = contact.Id, Solar_Farm__c = solarFarm.Id);
        Subscription__c expiredSubscription = new Subscription__c(Start_Date__c = Date.newInstance(2022, 01, 01),
                Expiration_Date__c =  Date.Today(), Customer__c = contact.Id, Solar_Farm__c   = solarFarm.Id);
        Subscription__c pendingSubscription = new Subscription__c(Start_Date__c = Date.today().addDays(365), Expiration_Date__c = Date.today().addDays(730),
                Customer__c = contact.Id, Solar_Farm__c = solarFarm.Id, Status__c = 'Pending');

        insert new List<Subscription__c>{newSubscription, expiredSubscription, pendingSubscription};
        //whenEx
        Test.startTest();
        new SubscriptionUpdateScheduler().execute(null);
        Test.stopTest();
        //then
        Map<Id, Subscription__c> updatedSubscriptionsById = new Map<Id, Subscription__c>([SELECT Id, Status__c FROM Subscription__c]);
        System.debug(updatedSubscriptionsById);
        Assert.isTrue(updatedSubscriptionsById.get(newSubscription.Id).Status__c == 'Active', 'Subscription should be ' +
                'updated to active');
        Assert.isTrue(updatedSubscriptionsById.get(expiredSubscription.Id).Status__c == 'Expired', 'Status should be set to expired');
        Assert.isTrue(updatedSubscriptionsById.get(pendingSubscription.Id).Status__c == 'Pending', 'Status should be set to pending');
    }
}