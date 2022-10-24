/**
 * Created by brooks on 10/21/2022.
 */

public with sharing class CollectionUtilities {
    /**
     * @param sObjects List of SOBject to filter
     * @param idField ID field field that will be added to the set
     *
     * @return Set of IDs
     */
    public static Set<Id> buildIdsSet(List<SObject> sObjects, SObjectField IdField){
        Set<Id> results = new Set<Id>();
        for(SObject sobj : sObjects){
            results.add((Id)sobj.get(IdField));
        }
        return results;
    }

}