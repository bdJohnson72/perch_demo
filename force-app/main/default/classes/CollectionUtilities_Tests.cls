/**
 * Created by brooks on 10/21/2022.
 */

@IsTest
public with sharing class CollectionUtilities_Tests {

    @IsTest
    static void itShouldBuildSet(){
        //given
        Account acc1 = new Account(Name = 'Test Acc1', Id = fflib_IDGenerator.generate(Account.SObjectType));
        Account acc2 = new Account(Name = 'Test Acc2', Id = fflib_IDGenerator.generate(Account.SObjectType));
        Account acc3 = new Account(Name = 'Test Acc3', Id = fflib_IDGenerator.generate(Account.SObjectType));
        //when
        Set<Id> accountIds = CollectionUtilities.buildIdsSet(new List<SObject>{acc1, acc2, acc3}, Account.Id);
        //then
        Assert.isTrue(accountIds.size() == 3, 'It should have built a set with 3 Ids');
    }

}