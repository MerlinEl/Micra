global rolFloater
global my_listView
fn uvc_updateListViewHeader lv:my_listView = if iskindof lv dotNetControl and  (lv.GetType()).ToString() == "System.Windows.Forms.ListView" do
(
-- uncomment "return" to break the update 
-- return()
 lv.beginUpdate() -- reduce flickering
 lv.HeaderStyle = lv.HeaderStyle.None
 lv.HeaderStyle = lv.HeaderStyle.Clickable
 lv.endUpdate()
)
rollout upRol "Upper"
(
 label lb "Upper Rollout"
 on upRol rolledup val do uvc_updateListViewHeader()
)
rollout lvRol "Main"
(
 dotNetControl lv "ListView" width:188 height:80 pos:[1,5]
 fn initListView lv:lv =
 (
  lv.view = lv.view.Details
  lv.HeaderStyle = lv.HeaderStyle.None
  lv.Columns.add "Nodes (Press for Update)" 180
  lv.HeaderStyle = lv.HeaderStyle.Clickable
  lv
 )
 on lvRol open do
 (
  my_listView = initListView()
 )
 on lvRol rolledup val do uvc_updateListViewHeader()
)
 
rollout dnRol "Lower"
(
 label lb "Lower Rollout"
 on dnRol rolledup val do uvc_updateListViewHeader()
)
 pos = [500,50]
 size = [205,230]
 try (closerolloutfloater rolFloater) catch()
 rolFloater = newRolloutFloater "LV Test by denisT" size[1] size[2] pos[1] pos[2]
 addRollout upRol rolFloater rolledUp:on
 addRollout lvRol rolFloater rolledUp:off
 addRollout dnRol rolFloater rolledUp:on
 uvc_updateListViewHeader() -- not necessary!
