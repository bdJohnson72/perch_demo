/**
 * Created by brooks on 10/21/2022.
 */

@IsTest
public with sharing class CollectionUtilities_Tests {

    @IsTest
    static void itShouldBuildSet(){
        //given
        Account acc1 = new Account(Name = 'Test Acc1');
        Account acc2 = new Account(Name = 'Test Acc2');
        Account acc3 = new Account(Name = 'Test Acc1');
        //when
        Set<Object> accNameSet = CollectionUtilities.buildSet(new List<SObject>{acc1, acc2, acc3}, Account.Name);
        //then
        System.debug(accNameSet);
        Assert.isTrue(accNameSet.size() == 2, 'It should remove the duplicate name');
    }


}