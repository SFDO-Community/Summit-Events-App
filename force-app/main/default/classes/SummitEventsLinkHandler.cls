public class SummitEventsLinkHandler {
    
    // Inelegant, but schema introspection can't differentiate RTF from regular text fields
    private static final Set<String> RICHTEXT_FIELDS = new Set<String>{
        'Event_Full_Text__c', 'Event_Confirmation_Description__c',
        'Event_Additional_Questions_Description__c', 
        'Event_Appointment_Description__c', 'Event_Footer__c', 
        'Event_Submit_Description__c', 'Event_Cancel_Review_Description__c',
        'Event_Payment_Due_Description__c', 'Event_Payment_Received_Description__c',
        'Event_description__c', 'Donation_Description__c', 
        'Guest_Registration_Description__c'
    };

    private static final String namespace = SummitEventsNamespace.StrTokenNSPrefix('');


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
                String fieldName = namespace + s;
                String fieldVal = (String) se?.get(fieldName);
                if(!String.isBlank(fieldVal) && fieldVal.contains('<img src=')) {
                    sew.fieldsWithLinks.add(fieldName);
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
                    Id cvId;

                    Integer pathIdx = url.indexOf('/sfc/servlet.shepherd/version/download/');
                    if (pathIdx != -1) {
                        Integer idStart = pathIdx + '/sfc/servlet.shepherd/version/download/'.length();
                    
                        Integer i = idStart;
                        while (i < url.length()) {
                            String ch = url.substring(i, i + 1);
                            if ('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'.indexOf(ch) == -1) {
                                break;
                            }
                            i++;
                        }
                    
                        String possibleId = url.substring(idStart, i);
                    
                        if (possibleId.startsWith('068') && (possibleId.length() == 15 || possibleId.length() == 18)) {
                            try {
                                cvId = (Id) possibleId;
                            } catch (Exception e) {
                                System.debug(e.getMessage());
                            }
                        }
                    }
                
                    SummitFieldItem sfi = new SummitFieldItem();
                    sfi.url = url;
                    sfi.cvId = cvId;
                    itemList.add(sfi);
                
                    searchStart = urlEnd + 1;
                }
            
                if (!itemList.isEmpty()) {
                    tempMap.put(field, itemList);
                }
            }
        
            sew.fieldsToLinkMap = tempMap;
        }


        /*for(SummitEventWrapper sew : sewList) {
            Map<String,List<SummitFieldItem>> tempMap = new Map<String,List<SummitFieldItem>>();
            for(String s : sew.fieldsWithLinks) {
                List<SummitFieldItem> itemList = new List<SummitFieldItem>();
                String rtf = (String) sew.event.get(s);
                String url;
                **
                 * What follows is dirty and complex string surgery with
                 * oven mitts; could potentially be refactored to use Patterns
                 * and Matchers, but native Regex tools are insufficient
                 * on their own for index-based logic and Regex has significant
                 * overhead in time complexity.
                 *
                for (Integer i = rtf.indexOf('<img src='); i != -1; i = rtf.indexOf('<img src=')) {
                    SummitFieldItem sfi = new SummitFieldItem();
                    Integer length = rtf.length();
                    i += 11; // magic number; offset of image tag
                    rtf = rtf.substring(i, length - 1);
                    Integer nextQuote = rtf.indexOf('"');
                    url = rtf.substring(0,nextQuote);
                    sfi.url = url;
                    itemList.add(sfi);
                }
                if(!itemList.isEmpty()) {
                    tempMap.put(s, itemList);
                }
            }
            sew.fieldsToLinkMap = tempMap;
        }*/


        /**
         * Step 3: query ContentVersion and ContentDistribution against URLs,
         *         then set up some data we'll need
         */

        Set<Id> idSet = getIds(sewList);

        List<ContentVersion> cvList = [
            SELECT Id,
                   ContentUrl,
                   Title
            FROM ContentVersion
            WHERE ContentUrl IN :idSet
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
                    ContentVersion cv = urlToCVMap?.get(sfi?.url);
                    ContentDistribution cd = cvIdToCDMap?.get(cv?.Id);
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
        System.Assert.areNotEqual(null, refreshed, 'No ContentDistributions were created.');
        System.Assert.areEqual(cdInsertList.size(), refreshed.size(), 'Not all ContentDistributions were created.');
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
            System.debug('step 5: se.Id =' + se.Id);
            for(String field : sew.fieldsWithLinks) {
                String rtf = (String) sew.event.get(field);
                System.debug('step 5: rtf =' + rtf);
                for(SummitFieldItem sfi : sew.fieldsToLinkMap.get(field)) {
                    System.debug('step 5: sfi.url =' + sfi.url);
                
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
	    List<String> fields = new List<String>();
        for(String f : RICHTEXT_FIELDS) {
            fields.add(namespace + f);
        }
	    String fieldList = String.join(fields, ', ');
	    return 'SELECT ' + fieldList + ' FROM ' + namespace + 'Summit_Events__c WHERE Id IN :queryIds';
	}

    /**
     * Helper method to generate a set of all URLs found in RTFs
     */
    private static Set<Id> getIds(List<SummitEventWrapper> sewList) {
        Set<Id> returnSet = new Set<Id>();
        for(SummitEventWrapper sew : sewList) {
            for(String s : sew.fieldsToLinkMap.keySet()) {
                for(SummitFieldItem sfi : sew.fieldsToLinkMap.get(s)) {
                    returnSet.add(sfi.cvId);
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
        Id cvId;
        ContentVersion cv;
        ContentDistribution cd;
        private SummitFieldItem() {}
    }
}