/**
 * Created by brooks on 10/20/2022.
 */

trigger Subscriptions on Subscription__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {

    new SubscriptionTriggerHandler().run();

}