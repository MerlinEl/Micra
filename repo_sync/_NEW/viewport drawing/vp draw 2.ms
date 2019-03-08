unregisterRedrawViewsCallback GW_displayObjectNames
fn GW_displayObjectNames =
(
  gw.setTransform (matrix3 1)
  for o in objects where not o.isHiddenInVpt do
    gw.text o.pos (o as string) color:yellow
  gw.enlargeUpdateRect #whole  
)
registerRedrawViewsCallback GW_displayObjectNames


UnregisterRedrawViewsCallback ViewportTextDisplay
cr = crowd pos:[0,0,0] name:"helper"
fn  ViewportTextDisplay =
(
gw.setTransform (Matrix3 1)
for obj in objects where obj.isselected == true do
(
gw.text obj.pos (obj.name as string) color:Yellow
)
)
RegisterRedrawViewsCallback ViewportTextDisplay
gw.UpdateScreen()
