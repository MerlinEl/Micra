cursors = dotNetClass "System.Windows.Forms.Cursors"
cursor = dotNetClass "System.Windows.Forms.Cursor"
cursor.current = cursors.WaitCursor
cursor.current = cursors.Arrow
cursor.current = cursors.HSplit
cursor.current = cursors.SizeWE
cursor.current = cursors.PanWest
cursor.current = cursors.NoMoveVert
cursor.current = cursors.No
cursor.current = cursors.IBeam
cursor.current = cursors.Cross
cursor.current = cursors.Help
cursor.current = cursors.Hand
cursor.current = cursors.AppStarting
cursor.current = cursors.NoMove2D


cursors.Hand.tag = "C:\WINDOWS\Cursors\harrow.cur"
cursors.Hand.Current = cursor_hmove

cursor_harrow  = dotNetObject "System.Windows.Forms.Cursor" "C:\WINDOWS\Cursors\harrow.cur"
cursor_hmove   = dotNetObject "System.Windows.Forms.Cursor" "C:\WINDOWS\Cursors\hmove.cur"