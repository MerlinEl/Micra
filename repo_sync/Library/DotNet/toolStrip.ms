  .AddRange <System.Windows.Forms.ToolStripItemCollection>toolStripItems
  .AddRange <System.Windows.Forms.ToolStripItem[]>toolStripItems

itm_arr = #("a","b","c","d","e","f")
mnu = dotNetObject "ContextMenuStrip"
menu_items = dotnetObject "ToolStripItem[]" (itm_arr.count - 1)
for i = 0 to (itm_arr.count - 1) do 
(
	menu_items.SetValue itm_arr[i+1] i
)

indx = dotNetObject "System.Int32" 1
menu_items.SetValue "aaa" indx
menu_items.GetValue 1