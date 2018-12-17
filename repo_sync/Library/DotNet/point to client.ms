contextmenu.Show (s.PointToScreen (netDrPoint a.location))
 
 (s.PointToClient (netDrPoint a.location))
 
 
 Point = Me.DataGrid1.PointToClient(Cursor.Position)
Me.ContextMenu1.Show(Me.DataGrid1, Point)