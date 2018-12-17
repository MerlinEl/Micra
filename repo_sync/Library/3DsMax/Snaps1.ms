/*
Scripts File
Purposes:  
    
    Fucnction for Macros used to toggle snaps points
	
Revision History

	14 Juin 2004 Pierre-felix Breton
	
*/

-- Macro Scripts for Objects
--***********************************************************************************************
-- MODIFY THIS AT YOUR OWN RISK

Struct Snaps(

	fn ToggleSnap OSnap Item txt = (
		try (
				snapmode.setOSnapItemActive OSnap Item (not (snapmode.getOSnapItemActive OSnap Item)) --toggles the snap
				If ((snapmode.getOSnapItemActive OSnap Item) == true) do snapMode.Active = true -- enables snaps
			) catch ()
		), --end fn

fn IsSnapActive OSnap Item = (
	try (
		snapmode.getOSnapItemActive OSnap Item
	) catch (
		return false
	)
) --end fn
)

/* Default snap numbers
1: "NURBS"
   1: "CV"
   2: "Point"
   3: "Curve Center"
   4: "Curve Normal"
   5: "Curve Tangent"
   6: "Curve Edge"
   7: "Curve End"
   8: "Surf Center"
   9: "Surf Normal"
   10: "Surf Edge"
2: "Standard"
   1: "Grid Points"
   2: "Grid Lines"
3: "Standard"
   1: "Pivot"
   2: "Bounding Box"
4: "Standard"
   1: "Perpendicular"
   2: "Tangent"
5: "Standard"
   1: "Vertex"
   2: "Endpoint"
   3: "Edge"
   4: "Midpoint"
   5: "Face"
   6: "Center Face"
*/
