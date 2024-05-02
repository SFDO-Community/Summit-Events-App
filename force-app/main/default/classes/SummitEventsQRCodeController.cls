/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 4/24/2024.
 */


public with sharing class SummitEventsQRCodeController {

    public String imageDataURL { get; set; }

    public PageReference redirectImage() {
        PageReference imageURL = null;
        if (String.isNotBlank(imageDataURL)) {
            imageURL = new PageReference(imageDataURL);
            imageURL.setRedirectCode(301);
            imageURL.setRedirect(false);
        }
        return imageURL;
    }
}