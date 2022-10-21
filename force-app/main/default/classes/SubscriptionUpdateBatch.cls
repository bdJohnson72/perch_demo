/**
 * Created by brooks on 10/21/2022.
 */

public with sharing class SubscriptionUpdateBatch implements Database.Batchable<SObject>{
    public static final String QUERY_STRING= 'SELECT Id, Status__c, Start_Date__c, Expiration_Date__c ' +
            'FROM Subscription__c ' +
            'WHERE Start_Date__c = TODAY '  +
            'OR Expiration_Date__c = TODAY';

    public void execute(Database.BatchableContext param1, List<Subscription__c> scope) {
        updateStatus(scope);
        update scope;
    }

    public void finish(Database.BatchableContext param1) {
    }

    public Iterable<SObject> start(Database.BatchableContext bc) {
        return Database.getQueryLocator(QUERY_STRING);
    }

    @TestVisible
    private void updateStatus(List<Subscription__c> subscriptions) {
        for(Subscription__c subscription : subscriptions) {
            if (subscription.Start_Date__c == Date.today()) {
                subscription.Status__c = 'Active';
            }else if (subscription.Expiration_Date__c == Date.today()) {
                subscription.Status__c = 'Expired';
            }
        }
    }
}