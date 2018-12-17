try(destroyDialog lvtv_rollout)catch()
rollout lvtv_rollout "ListView - TreeView by denisT"
(
	fn vc c = (dotNetClass "System.Drawing.Color").fromARGB c.r c.g c.b

	dotNetControl lv "ListView" width:200 height:200 pos:[4,4]
	dotNetControl tv "TreeView" width:200 height:200 pos:[208,4]
	local drag_effect = dotNetclass "System.Windows.Forms.DragDropEffects"
	local tree_node = dotNetClass "System.Windows.Forms.TreeNode"
	local list_node = dotNetClass "System.Windows.Forms.ListViewItem"
	on lv dragOver s a do 
	(
		a.effect = if a.data.GetDataPresent tree_node then 
		(
			node = a.data.GetData tree_node
			if node.treeview.equals tv then drag_effect.move else drag_effect.none
		)
		else drag_effect.none
	)
	on tv dragOver s a do
	(
		a.effect = if a.data.GetDataPresent list_node then 
		(
			item = a.data.GetData list_node
			if item.listview.equals lv then drag_effect.move else drag_effect.none
		)
		else drag_effect.none
	)
	on lv ItemDrag a do tv.DoDragDrop a.item drag_effect.move
	on tv ItemDrag a do lv.DoDragDrop a.item drag_effect.move

	on lv DragDrop s a do
	(
		node = a.data.GetData tree_node
		p = lv.PointToClient (dotNetObject "System.Drawing.Point" a.x a.y)
		if (item = lv.GetItemAt p.x p.y) != undefined do
		(
			item.text = node.text
		)
	)
	on tv DragDrop s a do
	(
		item = a.data.GetData list_node
		p = tv.PointToClient (dotNetObject "System.Drawing.Point" a.x a.y)
		if (node = tv.GetNodeAt p.x p.y) != undefined do
		(
			node.text = item.text
		)
	)

	on lvtv_rollout open do
	( 
		lv.BeginUpdate()
		tv.BeginUpdate()
		lv.allowDrop = on
		lv.view = lv.view.Details
		lv.HideSelection = off
		lv.HeaderStyle = lv.HeaderStyle.None
		lv.Columns.add "" 180
		lv.backcolor = vc (color 230 230 200) 

		i = dotnetobject "ListViewItem" ""
		i.backcolor = lv.backcolor 
		seed 0
		items = for k=1 to 20 collect 
		(
			item = i.clone()
			item.text = bit.intashex (random -1e9 1e9)
			item
		)
		lv.items.addrange items
		tv.AllowDrop = on
		tv.ItemHeight = 14
		tv.HideSelection = off
		tv.backcolor = vc (color 200 230 230) 
		i = dotnetobject "TreeNode" ""
		items = for k=1 to 20 collect 
		(
			item = i.clone()
			item.text = bit.intashex (random -1e9 1e9)
			item
		)
		tv.nodes.addrange items
		lv.EndUpdate()
		lv.Refresh()
		tv.EndUpdate()
		tv.Refresh()
		ok
	)
)
createDialog lvtv_rollout 412 230