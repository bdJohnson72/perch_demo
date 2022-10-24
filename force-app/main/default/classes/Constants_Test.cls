/**
 * Created by brooks on 10/24/2022.
 */

@IsTest
private class Constants_Test {
    @IsTest
    static void itShouldReturnConstants() {
        Assert.areEqual('Active', Constants.SUBSCRIPTION_ACTIVE, 'It should return the active status');
        Assert.areEqual('Pending', Constants.SUBSCRIPTION_PENDING, 'It should return the pending status');
        Assert.areEqual('Expired', Constants.SUBSCRIPTION_EXPIRED, 'It should return the expired status');
    }
}