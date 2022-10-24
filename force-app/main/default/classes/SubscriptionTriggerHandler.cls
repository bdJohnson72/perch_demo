/**
 * Created by brooks on 10/20/2022.
 * Domain class for the Subscription__c SObject Type
 */

public with sharing class SubscriptionTriggerHandler extends TriggerHandler {

    private SubscriptionSelector subscriptionSelector;
    private static final String ERROR_MESSAGE = 'These are overlapping dates please check subscription with ID ';

    public SubscriptionTriggerHandler() {
        this.subscriptionSelector = new SubscriptionSelector();
    }

    public override void validateBeforeInsert() {
        List<Subscription__c> existingSubscriptions = this.subscriptionSelector.getExistingSubscriptionsByCustomerAndFarmId(
                CollectionUtilities.buildIdsSet(Trigger.new, Subscription__c.Customer__c),
                CollectionUtilities.buildIdsSet(Trigger.new, Subscription__c.Solar_Farm__c)
        );
        if (!existingSubscriptions.isEmpty()) {
            validateSubscriptionDates((List<Subscription__c>) Trigger.new, buildSubscriptionMap(existingSubscriptions));
        }
    }


    public override void validateBeforeUpdate() {
        List<Subscription__c> recordsToProcess = filterForChangedSubscriptionDates((List<Subscription__c>) Trigger.new,
                (Map<Id, Subscription__c>) Trigger.oldMap);
        if (!recordsToProcess.isEmpty()) {
            List<Subscription__c> existingSubscriptions = this.subscriptionSelector.getExistingSubscriptionsByCustomerAndFarmId(
                    CollectionUtilities.buildIdsSet(recordsToProcess, Subscription__c.Customer__c),
                    CollectionUtilities.buildIdsSet(recordsToProcess, Subscription__c.Solar_Farm__c));

            if (!existingSubscriptions.isEmpty()) {
                validateSubscriptionDates(recordsToProcess, buildSubscriptionMap(existingSubscriptions));
            }
        }
    }

    @TestVisible
    private Map<Id, List<Subscription__c>> buildSubscriptionMap(List<Subscription__c> existingSubscriptions) {
        Map<Id, List<Subscription__c>> existingSubscriptionsBuCustomerId = new Map<Id, List<Subscription__c>>();
        for (Subscription__c subscription : existingSubscriptions) {
            if (existingSubscriptionsBuCustomerId.containsKey(subscription.Customer__c)) {
                List<Subscription__c> current = existingSubscriptionsBuCustomerId.get(subscription.Customer__c);
                current.add(subscription);
                existingSubscriptionsBuCustomerId.put(subscription.Customer__c, current);
            } else {
                existingSubscriptionsBuCustomerId.put(subscription.Customer__c, new List<Subscription__c>{
                        subscription
                });
            }
        }
        return existingSubscriptionsBuCustomerId;
    }

    @TestVisible
    private void validateSubscriptionDates(List<Subscription__c> subscriptions, Map<Id, List<Subscription__c>> existingSubscriptionsByCustomerId) {
        //Iterating over different data structures O(n  * m)
        for (Subscription__c subscription : subscriptions) {
            if (existingSubscriptionsByCustomerId.containsKey(subscription.Customer__c)) {
                List<Subscription__c> existingSubscriptions = existingSubscriptionsByCustomerId.get(subscription.Customer__c);
                for (Subscription__c existingSubscription : existingSubscriptions) {
                    if (existingSubscription?.Id != subscription.Id) {
                        validateSubscriptionDatePostStartDate(subscription, existingSubscription);
                        validateSubscriptionPreStartDate(subscription, existingSubscription);
                    }
                }
            }
        }
    }

    /**
     * @description  if the new subscription start date is after the current start date on
     * the existing subscription the existing subscription must expire before the new start dtate
     * @param newSubscription newSubscription subscription being inserted or edited
     * @param oldSubscription existing subscription in the database
     */
    @TestVisible
    private static void validateSubscriptionDatePostStartDate(Subscription__c newSubscription, Subscription__c oldSubscription) {
        if (newSubscription.Start_Date__c >= oldSubscription.Start_Date__c
                && oldSubscription.Expiration_Date__c > newSubscription.Start_Date__c) {

            newSubscription.addError(ERROR_MESSAGE + oldSubscription.Id);
        }
    }
    /**
     * @description if the new subscription start date is before the existing subscription start date
     * the new subscription must expire before the existing subscription start dtate
    * @param newSubscription subscription being inserted or edited
    * @param oldSubscription existing subscription in the database
    */

    @TestVisible
    private static void validateSubscriptionPreStartDate(Subscription__c newSubscription, Subscription__c oldSubscription) {
        if (newSubscription.Start_Date__c <= oldSubscription.Start_Date__c
                && newSubscription.Expiration_Date__c > oldSubscription.Start_Date__c) {
            newSubscription.addError(ERROR_MESSAGE + oldSubscription.Id);
        }
    }
    @TestVisible
    private List<Subscription__c> filterForChangedSubscriptionDates(List<Subscription__c> recordsToFilter, Map<Id, Subscription__c> oldMap) {
        List<Subscription__c> recordsWithChanges = new List<Subscription__c>();
        for (Subscription__c subscription : recordsToFilter) {
            Subscription__c oldSubscription = oldMap.get(subscription.Id);
            if (subscription.Start_Date__c != oldSubscription.Start_Date__c ||
                    subscription.Expiration_Date__c != oldSubscription.Expiration_Date__c) {
                recordsWithChanges.add(subscription);
            }
        }
        return recordsWithChanges;
    }
}