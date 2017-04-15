import SETTINGS from 'script/settings';
/*

  Google Analytics tracking.

*/

window.trackEvent = function(category, event, lbl) {
  // Abstraction for _gaq _trackEvent
  let label = `${ui.account}`;
  if (lbl != null) { label += `: ${lbl}`; }
  if (SETTINGS.PRODUCTION) {
    return _gaq.push(['_trackEvent', category, event, label]);
  }
  else {}
};
    //print "track", category, event, label

