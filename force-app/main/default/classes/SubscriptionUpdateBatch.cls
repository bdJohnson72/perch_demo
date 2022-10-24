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
        doInsert(scope);
    }

    public void finish(Database.BatchableContext param1) {
        // email results
    }

    public Iterable<SObject> start(Database.BatchableContext bc) {
        return Database.getQueryLocator(QUERY_STRING);
    }

    @TestVisible
    private  void updateStatus(List<Subscription__c> subscriptions) {
        for(Subscription__c subscription : subscriptions) {
            if (subscription.Start_Date__c == Date.today()) {
                subscription.Status__c = Constants.SUBSCRIPTION_ACTIVE;
            }else if (subscription.Expiration_Date__c == Date.today()) {
                subscription.Status__c = Constants.SUBSCRIPTION_EXPIRED;
            }
        }
    }

    @TestVisible
    private static void doInsert(List<Subscription__c> recordsToUpdate){
        //TODO  implement actual DML or UOW for mocking
        try {
            update recordsToUpdate;
        } catch (Exception e) {
            //TODO implement error handling framework
            System.debug('Exception in batch ' + e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }
}