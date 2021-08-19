/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 8/18/2021.
 */


@IsTest
private class SummitEventsRegisterGuests_TEST {
    @IsTest
    static void noDataController() {
        Test.startTest();
        SummitEventsRegisterGuestsController guestController = new SummitEventsRegisterGuestsController();
        System.assertEquals(JSON.serialize(guestController.eventInformation), '{"registrationId":null,"instanceId":null,"eventId":null,"dt":null,"audience":null}');
        Test.stopTest();
    }
}