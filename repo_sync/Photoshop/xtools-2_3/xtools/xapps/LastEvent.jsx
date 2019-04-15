//
// LastEvent
// This script caches the last event created by PS.
// It adds the app.getLastEvent() that returns an object that looks like:
// ev = { eventID: 'setd', desc: edesc }
//
// $Id: LastEvent.jsx,v 1.2 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2009, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
try {
  function _main(args) {
    var last = new ActionDescriptor();
    var descID = app.charIDToTypeID('Desc');
    var eventID = app.charIDToTypeID('Evnt');

    last.putObject(descID, descID, args[0]);
    last.putInteger(eventID, args[1]);
    app.putCustomOptions(eventID, last, true);
  }

  _main(arguments);

} catch (e) {
  alert(e);
}

"LastEvent.jsx";
// EOF
