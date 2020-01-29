# Summit Events App

Summit Events for the connected campus is an open source event management system for Salesforce. It was initially developed at the University of St. Thomas - Minnesota to facilitate admission events.

* The Events App focuses on providing an educational institution with a dynamic and 
configurable Event registration solution
* The Events App allows an institution to define an Event plus instances of the Event
* Each instance of an Event generates a unique QR code
* The Events App allows a university to define an Event Template, Event Home URL, 
Community Base URL, and an Event Instance Feed URL (the latter which uses a REST API JSON 
feed for use with dynamic updates to different web front ends)
* The Events App offers the ability to identify a count on the number of guests attending an event
* Includes: Matching Rules (hard matches + soft matches), REST API JSON feed for use with dynamic updates to 
different Web front ends, and Triggers


[1]: <docs/scatch-org-creation.md> "Setting up Summit Events App for Scratch org Development"
[2]: <docs/set-up.md> "How to set up Summit Events in Salesforce"
[3]: <docs/CumulusCI-notes.md> "Notes on using Cumulus CI"
[4]: <docs/GIT-notes.md> "Notes on using GIT"
[5]: <LICENSE.md> "License"
[6]: <https://www.stthomas.edu> "University of St. Thomas"
[7]: <docs/files/USTEvent_DOCS.zip> "Old Event Documentation"

## Getting Started

*Note: In the Salesforce Winter '20 release Guest User access is severely restricted. There are new instructions in the "Scratch Org Installation"
to address this new security.*
* [Scratch Org Installation][1]
* [Installation in Production Orgs][2]
* [CumulusCI Notes][3]
* [GIT Notes][4]
* [License][5]

## Legacy documentation

The [University of St. Thomas][6] has been running the Summit Events application (*under its former name UST Events*) in it's production org since September 6th, 2018. This running version is heavily integrated with their current admission application solution so diverges some in functionality from what you see in this repository. Part of the work to be done here is to bring back functionality that had to be cut and integrate the missing features with EDA and/or NPSP. All that being said, St. Thomas' running application has quite a bit of documentation (we're going to call it legacy documentation) that largely overlaps with this repository and could be helpful.

* [Legacy documentation (zip)][7]

## Working Togeter

*Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
Use of this source code is governed by a BSD Revised
license that can be found in the [LICENSE file][5].*
