_____                _   __  __        _    _  _____ _______
|  __ \              | | |  \/  |      | |  | |/ ____|__   __|
| |__) |___  __ _  __| | | \  / | ___  | |  | | (___    | |
|  _  // _ \/ _` |/ _` | | |\/| |/ _ \ | |  | |\___ \   | |
| | \ \  __/ (_| | (_| | | |  | |  __/ | |__| |____) |  | |
|_|  \_\___|\__,_|\__,_| |_|  |_|\___|  \____/|_____/   |_|

/*Thad Dahlberg 03/13/2018*/

Two files are modified for UST use:
* chosen.ust.jquery.js
* chosen.ust.jquery.min.js
The later is compressed using https://jscompress.com/

Modifications:

Line 349-351 of chosen.ust.jquery.js:
// escapedQuery modified by UST to allow word search to not be in order or complete
// escapedQuery = query.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
escapedQuery = query.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&").split('\\ ').filter(function(e) { return e.length > 0 }).join('(.)+');
Discussion here: https://github.com/harvesthq/chosen/issues/858


Line 960-961 of chosen.ust.jquery.js:
//Removed by UST to not clear search text field
//this.show_search_field_default();
Discussion here: https://github.com/harvesthq/chosen/issues/2602

That is all.
