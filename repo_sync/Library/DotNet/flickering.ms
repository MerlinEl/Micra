fn updateListViewHeader lv: = if iskindof lv dotNetControl and  (lv.GetType()).ToString() == "System.Windows.Forms.ListView" do -- simple double check
(
lv.beginUpdate() -- reducing flickering 
lv.HeaderStyle = lv.HeaderStyle.None
lv.HeaderStyle = lv.HeaderStyle.Clickable -- (or Nonclickable ... which one you use)
lv.endUpdate()
)
 
on <any_rollout> rolledUp state do updateListViewHeader lv:<list_view>