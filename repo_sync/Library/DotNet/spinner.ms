f = dotNetObject "form"
n = dotNetObject "NumericUpDown"
n.borderStyle = n.borderStyle.FixedSingle
n.DecimalPlaces = 2
n.AllowDrop = true
n.BackColor = netDrColor green
n.ForeColor = netDrColor yellow
fn onMouseUp s a = 
(
	s.cursor = netCursors.Arrow
)
fn onMouseDown s a =
(
	--mcsystem.show s
	case a.button of
	(
		(a.button.left ):
		(
			s.cursor = netCursors.SizeNS
		)
		(a.button.right ):(s.value = netDecimal 0)
	)
)
fn onDragOver s a = print "drag"

dotNet.addEventHandler n "MouseUp" onMouseUp
dotNet.addEventHandler n "MouseDown" onMouseDown
dotNet.addEventHandler n "DragEnter" onDragOver
f.controls.add n
f.show()



/*
   on <control_name> DragDrop <System.Windows.Forms.DragEventArgs>e do ( ... )
   on <control_name> DragEnter <System.Windows.Forms.DragEventArgs>e do ( ... )
   on <control_name> DragLeave <System.EventArgs>e do ( ... )
   on <control_name> DragOver <System.Windows.Forms.DragEventArgs>e do ( ... )
*/