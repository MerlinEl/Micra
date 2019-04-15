//
// RemoveAlphaChannels
//   Removes all of the alpha channels from a document
//
// $Id: RemoveAlphaChannels.jsx,v 1.2 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2007, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
function main() {
  if (app.documents.length == 0) {
    return;
  }

  var doc = app.activeDocument;

  var channels = doc.channels;
  var alphas = [];
  for (var i = 0; i < channels.length; i++) {
    var channel = channels[i];
    if (channel.kind == ChannelType.COMPONENT) {
      continue;
    }
    alphas.push(channel);
  }
  while (alphas.length) {
    var channel = alphas.pop();
    channel.remove();
  }
};

main();

"RemoveAlphaChannels.jsx";
// EOF
