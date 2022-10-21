/**
 * Created by brooks on 10/21/2022.
 */

public with sharing class SubscriptionSelector implements ISelector {

    public static List<Subscription__c> getExistingSubscriptionsByCustomerAndFarmId(Set<Id> customerIds, Set<Id> solarFarmIds) {
        return [SELECT Id, Expiration_Date__c, Start_Date__c, Customer__c
        FROM Subscription__c
                WHERE Customer__c IN: customerIds
                AND Solar_Farm__c IN: solarFarmIds
        ];
    }

    public List<SObject> query() {
        return null;
    }
}