/**
 * Created by brooks on 10/20/2022.
 */

public with sharing class SubscriptionTriggerHandler extends TriggerHandler{

    //SubscriptionSelector subscriptionSelector = new SubscriptionSelector();

    protected override void beforeInsert() {
        Map<Id, Subscription__c> subscriptionsByCustomerId = new Map<Id, Subscription__c>();
        //TODO implementselector method

       // getExistingSubscriptionsByCustomerAndFarmId((List<Subscription__c>) Trigger.new);
        validateSubscriptionDates((List<Subscription__c>) Trigger.new,
                getExistingSubscriptionsByCustomerAndFarmId((List<Subscription__c>) Trigger.new));
    }

    private Map<Id, List<Subscription__c>> getExistingSubscriptionsByCustomerAndFarmId(List<Subscription__c> newSubscriptions){
        Map<Id, List<Subscription__c>> existingSubscriptionsBuCustomerId = new Map<Id, List<Subscription__c>>();
        Set<Id> customerIds = CollectionUtilities.buildIdsSet(newSubscriptions, Subscription__c.Customer__c);
        Set<Id>farmIds = CollectionUtilities.buildIdsSet(newSubscriptions, Subscription__c.Solar_Farm__c);
        List<Subscription__c> existingSubscriptions = SubscriptionSelector.getExistingSubscriptionsByCustomerAndFarmId(customerIds,farmIds);
        for(Subscription__c subscription : existingSubscriptions){
            if (existingSubscriptionsBuCustomerId.containsKey(subscription.Customer__c)) {
                List<Subscription__c> current = existingSubscriptionsBuCustomerId.get(subscription.Customer__c);
                current.add(subscription);
                existingSubscriptionsBuCustomerId.put(subscription.Customer__c, current);
            }else {
                existingSubscriptionsBuCustomerId.put(subscription.Customer__c, new List<Subscription__c>{subscription});
            }
        }
        return existingSubscriptionsBuCustomerId;
    }

    @TestVisible
    private void validateSubscriptionDates(List<Subscription__c> subscriptions, Map<Id, List<Subscription__c>> subscriptionsByCustomerId) {
        //TODO compare dates if start date is after new start date we check that the existing expiration is before the new expiration
        //TODO else if start date is before new start date we check that the existing expiration is before the new start dtate
        //TODO method to add error,

        for(Subscription__c subscription : subscriptions){
            if(subscriptionsByCustomerId.containsKey(subscription.Customer__c)){
                List<Subscription__c> existingSubscriptions = subscriptionsByCustomerId.get(subscription.Customer__c);
                for(Subscription__c existingSubscription : existingSubscriptions){
                    validateSubscriptionDatePriorStartDate(subscription, existingSubscription);
                    validateSubscriptionPreStartDate(subscription, existingSubscription);
                }
            }
        }
    }
    /**
     * @description  if the new subscription start date is after the current start date on
     * the existing subscription the existing subscription must expire before the new start dtate
     * @param newSubscription
     * @param oldSubscription
     */
    @TestVisible
    private static void validateSubscriptionDatePriorStartDate(Subscription__c newSubscription, Subscription__c oldSubscription) {
        if (newSubscription.Start_Date__c >= oldSubscription.Start_Date__c
                && newSubscription.Expiration_Date__c <= oldSubscription.Expiration_Date__c) {
            newSubscription.addError('These are overlapping dates please check subscription with ID ' + oldSubscription.Id);
        }
    }
    @TestVisible
    private static void validateSubscriptionPreStartDate(Subscription__c newSubscription, Subscription__c oldSubscription) {
        if(newSubscription.Start_Date__c <= oldSubscription.Start_Date__c
        && newSubscription.Expiration_Date__c >= oldSubscription.Start_Date__c ){
            newSubscription.addError('These are overlapping dates please check subscription with ID ' + oldSubscription.Id);
        }
    }
}