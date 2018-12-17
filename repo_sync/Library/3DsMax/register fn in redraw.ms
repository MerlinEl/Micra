
fn redrawviews_p = print "Viewports Redrawn"
registerRedrawViewsCallback redrawviews_p
unRegisterRedrawViewsCallback redrawviews_p 


fn museTrackz = (if mouse.pos == [272,194] do print "zero")
registerRedrawViewsCallback museTrackz
unRegisterRedrawViewsCallback museTrack


fn dTrackz =
(
setDialogPos movetestDialog mouse.screenpos
)
registerRedrawViewsCallback dTrackz
unRegisterRedrawViewsCallback dTrackz


cui.commandPanelOpen=true