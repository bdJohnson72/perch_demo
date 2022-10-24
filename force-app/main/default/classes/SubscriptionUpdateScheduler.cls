/**
 * Created by brooks on 10/21/2022.
 */

public with sharing class SubscriptionUpdateScheduler implements Schedulable{

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new SubscriptionUpdateBatch());
    }
}