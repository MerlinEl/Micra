f = dotnetObject "form"
f.backcolor = netDrColor yellow
tb = dotnetObject "toolbar"
tb.width = 100
tb.height = 50
tb.ButtonSize = netDrSize [24,24]
tb.backcolor = netDrColor green
tb.Divider = true
tb.DropDownArrows = true
tb.Margin = dotnetObject "Padding" 1
tb.TabIndex = 3
--tb.ImageList : <System.Windows.Forms.ImageList>
--.ImageSize : <System.Drawing.Size>, read-only
f.controls.add(tb)
f.show(WindowWrapper)