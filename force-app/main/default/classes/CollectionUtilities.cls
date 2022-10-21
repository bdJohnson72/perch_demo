/**
 * Created by brooks on 10/21/2022.
 */

public with sharing class CollectionUtilities {

    public static Set<Id> buildIdsSet(List<SObject> sObjects, SObjectField field){
        Set<Id> results = new Set<Id>();
        for(SObject sobj : sObjects){
            results.add((Id)sobj.get(field));
        }
        return results;
    }

}