public class SummitEventsLinkHandler {
    
    // Inelegant, but schema introspection can't differentiate RTF from regular text fields
    private static final Set<String> RICHTEXT_FIELDS = new Set<String>{
        'Event_Full_Text__c', 'Event_Confirmation_Description__c',
        'Event_Additional_Questions_Description__c', 
        'Event_Appointment_Description__c', 'Event_Footer__c', 
        'Event_Submit_Description__c', 'Event_Cancel_Review_Description__c',
        'Event_Payment_Due_Description__c', 'Event_Payment_Received_Description__c',
        'Event_Description__c', 'Event_Donation_Description__c', 
        'Event_Guest_Registration_Description__c'
    };

    public static void run(Map<Id,SObject> newmap) {
        List<Id> idList = new List<Id>(newmap.keySet());
        newmap = null;
        replaceLinks(idList);
    }

    public static void replaceLinks(List<Id> newlist) {
        
        List<SummitEventWrapper> sewList = new List<SummitEventWrapper>();
        List<Summit_Events__c> seList = populateEvents(newlist);

        /**
         * Step 1: filter for Summit Events with RTF links and wrap them
         */

        for(Summit_Events__c se : seList) {
            SummitEventWrapper sew = new SummitEventWrapper();
            for (String s : RICHTEXT_FIELDS) {
                String fieldVal = (String) se?.get(s);
                if(!String.isBlank(fieldVal) && fieldVal.contains('<img src=')) {
                    sew.fieldsWithLinks.add(s);
                }
            }
            if(!sew.fieldsWithLinks.isEmpty()) {
                sew.event = se;
                sewList.add(sew);
            }
        }
        seList = null; // optimistically make unused events available for GC

        /**
         * Step 2: scan fields; capture indices and URLs
         */

        for (SummitEventWrapper sew : sewList) {
            Map<String, List<SummitFieldItem>> tempMap = new Map<String, List<SummitFieldItem>>();

            for (String field : sew.fieldsWithLinks) {
                String rtf = (String) sew.event.get(field);
                List<SummitFieldItem> itemList = new List<SummitFieldItem>();
            
                Integer searchStart = 0;
                while (true) {
                    Integer imgStart = rtf.indexOf('<img src="', searchStart);
                    if (imgStart == -1) {
                        break;  // no more images
                    }

                    Integer urlStart = imgStart + '<img src="'.length();
                    Integer urlEnd = rtf.indexOf('"', urlStart);
                    if (urlEnd == -1) {
                        break;  // malformed tag, bail
                    }

                    String url = rtf.substring(urlStart, urlEnd);
                
                    SummitFieldItem sfi = new SummitFieldItem();
                    sfi.url = url;
                    itemList.add(sfi);
                
                    // advance search past this tag
                    searchStart = urlEnd + 1;
                }
            
                if (!itemList.isEmpty()) {
                    tempMap.put(field, itemList);
                }
            }
        
            sew.fieldsToLinkMap = tempMap;
        }

        /**
         * Step 3: query ContentVersion and ContentDistribution against URLs,
         *         then set up some data we'll need
         */

        Set<String> urlSet = getURLs(sewList);

        List<ContentVersion> cvList = [
            SELECT Id,
                   ContentUrl,
                   Title
            FROM ContentVersion
            WHERE ContentUrl IN :urlSet
        ];

        Map<String, ContentVersion> urlToCVMap = new Map<String, ContentVersion>();
        Set<Id> cvIds = new Set<Id>();

        for (ContentVersion cv : cvList) {
            urlToCVMap.put(cv.ContentUrl, cv);
            cvIds.add(cv.Id);
        }

        List<ContentDistribution> cdList = [
            SELECT Id,
                   DistributionPublicUrl,
                   Name,
                   ContentVersionId
            FROM ContentDistribution
            WHERE ContentVersionId IN :cvIds
        ];

        Map<Id, ContentDistribution> cvIdToCDMap = new Map<Id, ContentDistribution>();
        for (ContentDistribution cd : cdList) {
            cvIdToCDMap.put(cd.ContentVersionId, cd);
        }

        /**
         * Step 4: create ContentDistributions for every URL found which:
         *           -has a CV
         *           -has no CD
         */

        //List<ContentVersion> cvsWithoutCds = new List<ContentVersion>();
        List<ContentDistribution> cdInsertList = new List<ContentDistribution>();

        for(SummitEventWrapper sew : sewList) {
            for(String s : sew.fieldsToLinkMap.keySet()) {
                for(SummitFieldItem sfi : sew.fieldsToLinkMap.get(s)) {
                    ContentVersion cv = urlToCVMap.get(sfi.url);
                    ContentDistribution cd = cvIdToCDMap.get(cv.Id);
                    if(cd == null && cv != null) {
                        ContentDistribution newCd = new ContentDistribution();
                        newCd.name = cv.Title + '__SHARE';
                        newCd.ContentVersionId = cv.Id;
                        cdInsertList.add(newCd);
                        //cvsWithoutCds.add(cv);
                        sfi.cd = newCd;
                        sfi.cv = cv;
                    }
                }
            }
        }

        try {
            insert cdInsertList;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        

        /**
         * Step 5: replace old URLs with new public links attached to a CD
         *         and update SummitEvents
         */

        List<ContentDistribution> refreshed = [
            SELECT Id, Name, DistributionPublicUrl
            FROM ContentDistribution
            WHERE Id IN :cdInsertList 
        ];
        Map<Id,ContentDistribution> cdIdMap = new Map<Id,ContentDistribution>(refreshed);

        /**
         * What follows is purposeful DML in a loop. Given the problem space
         * and realistic use expectations, orgs are unlikely to be pushing
         * large amounts of system-generated Summit Events records. We must instead
         * deal with potentially massive, heap-busting objects with large RTFs.
         * As such, we trade heap safety and near-guaranteed tx success for
         * theoretical but unlikely bulk-unsafe DML ops. Alternatives are async,
         * which adds potential end-user friction as they must wait for records
         * to push to the database when saving via GUI. 
         */
        for(SummitEventWrapper sew : sewList) {
            Summit_Events__c se = new Summit_Events__c();
            se.Id = sew.event.Id;
            for(String field : sew.fieldsWithLinks) {
                String rtf = (String) sew.event.get(field);
                for(SummitFieldItem sfi : sew.fieldsToLinkMap.get(field)) {
                    rtf = rtf.replace(sfi.url, cdIdMap.get(sfi.cd.Id).DistributionPublicUrl);
                }
                se.put(field,rtf);
            }
            try {
                update se;
            } catch (Exception e) {
                System.debug(e);
            }
        }


        
    }
    /**
     * Helper method to generate a list of SummitEvents from IDs 
     * passed in the trigger context. This is necessary because 
     * heap size is a significant constaint here in theory. We 
     * deal with potentially massive objects. IDs are passed in
     * so we can rig the garbage collector in our favor -- we want
     * as few explicit references to large objects as we can, but 
     * since records passed by trigger.new are immutable, we must 
     * also query a new set. This method accepts those IDs and 
     * returns, as obliquely as possible, a set of records whose
     * references we can hopefully null later if they are unneeded.
     */
    private static List<Summit_Events__c> populateEvents(List<Id> queryIds) {
        return Database.query(generateQuery());
    }

    /**
     * Helper method to generate query dynamically. As such, for
     * updates to the Summit_Events__c object's RTFs, all is required is
     * to add or delete members from the global RICHTEXT_FIELDS set above
     */
    private static String generateQuery() {
        List<String> fieldList = new List<String>(RICHTEXT_FIELDS);
        String fullQuery = 'SELECT ' + fieldList.remove(0);
        for(Integer i = fieldList.size() - 1; i >= 0; i--) {
            fullQuery += ', ' + fieldList.remove(i);
        }
        fullQuery += ' FROM Summit_Events__c WHERE Id in :queryIds';
        return fullQuery;
    }

    /**
     * Helper method to generate a set of all URLs found in RTFs
     */
    private static Set<String> getURLs(List<SummitEventWrapper> sewList) {
        Set<String> returnSet = new Set<String>();
        for(SummitEventWrapper sew : sewList) {
            for(String s : sew.fieldsToLinkMap.keySet()) {
                for(SummitFieldItem sfi : sew.fieldsToLinkMap.get(s)) {
                    returnSet.add(sfi.url);
                }
            }
        }
        return returnSet;
    }

    // Simple wrapper to aggregate relevant values we'll use
    private class SummitEventWrapper {
        Summit_Events__c event;
        Set<String> fieldsWithLinks;
        Map<String,List<SummitFieldItem>> fieldsToLinkMap;

        private SummitEventWrapper() { 
            this.fieldsWithLinks = new Set<String>(); 
            this.fieldsToLinkMap = new Map<String,List<SummitFieldItem>>();
        }

        private SummitEventWrapper(Summit_Events__c event) {
            this.event = event;
            this.fieldsWithLinks = new Set<String>(); 
            this.fieldsToLinkMap = new Map<String,List<SummitFieldItem>>();
        }
    }

    private class SummitFieldItem {
        String url;
        ContentVersion cv;
        ContentDistribution cd;
        private SummitFieldItem() {}
    }
}