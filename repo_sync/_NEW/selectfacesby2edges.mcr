
macroScript SelectFace_2Edges tooltip:"Select Faces By 2 Edges" Category:"BG Tools" buttonText:"SelFaceEdges" -- need icon 
( --Start Macro
/* 
******************************************************************************** 
Macro Scripts for Editable poly Stuff ( Build in max 2011 ) 
Select Faces By 2 Edges V 1.0 By Budi Gunawan
Start: 09/12/ 2013 
Last Updated: 09/14/ 2013

Feel free & Enjoy
Modify at your own risk 
******************************************************************************** 
What is this :
Select a Loop Faces between two selected Edges.

Usage:
Select two parallel Edges and apply to select all polygons 
between them using the shortest distance
-------------------------------------------------------------------------------------------------
*/
--local SelectFaces_Roll

fn setLoopBy1Face obj MyFaces edgelist getEdgeSel getFacesByEdge =
(
    local getEdgesByFace=polyop.getEdgesUsingFace, setEdgeSel=polyop.setEdgeSelection, \
	        setFaceSel=polyop.setFaceSelection
	local Edges, FaceRing
    Edges = getEdgesByFace obj MyFaces
    for i in edgelist do deleteItem Edges (findItem Edges i)
    setEdgeSel obj Edges 
	obj.SelectEdgeRing ()
    FaceRing = getFacesByEdge obj (getEdgeSel obj)
    setFaceSel obj FaceRing
	setEdgeSel obj edgelist -- set back to original Edges
)
fn SelectFacesBy2Edges_StepLoop obj OverFlow =
( 
  local edgelist=#()
  local getEdgeSel=polyop.getEdgeSelection 
  edgelist = (getEdgeSel obj) as array-- original
  if edgelist.count == 2 then
  (
	local getFaceCenter=polyop.getFaceCenter
	local getFacesByEdge=polyop.getFacesUsingEdge, setFaceSel=polyop.setFaceSelection  
	local EdgeFaces, i, x, facelist=#(), MyFaces=#()
   with redraw off 
   (
	EdgeFaces = for i in edgelist collect polyop.getEdgeFaces obj i
	for i in EdgeFaces do for x in i do append facelist x -- convert nested sub-array to array is Important !

	if facelist.count >2 then
	(
	   local num, f, TheDist
	   local CenterList=#(), DistList=#()
	   CenterList = for f in facelist collect getFaceCenter obj f
	   if facelist.count > 3 then
	   (
         for i=1 to 2 do ( for x=3 to 4 do append DistList (distance CenterList[i] CenterList[x]) )
	     if keyboard.altpressed then TheDist = amax DistList else TheDist = amin DistList
         for i=1 to 2 do
		 ( for x=3 to 4 where (distance CenterList[i] CenterList[x]) == TheDist do MyFaces=#(facelist[i],facelist[x])) 
		 format "4 faces processing - got Faces: % - Next..\n" MyFaces 
       ) else 
	   (
			  if EdgeFaces[1].count == 2 then (x=1; num=2; f=3) else  (x=2; num=3; f=1)
			  
			  for i=x to num do append DistList (distance CenterList[i] CenterList[f])
		      if keyboard.altpressed then TheDist = amax DistList else TheDist = amin DistList
		      for i=x to num where (distance CenterList[i] CenterList[f]) == TheDist do MyFaces=#(facelist[i],facelist[f])
			  format "3 faces processing - got Faces: % - Next..\n" MyFaces
	   ) -- end else
    ) else (format "2 faces processing - got Faces: % - Next..\n" facelist ; MyFaces=facelist)
	
	MyFaces =makeUniqueArray MyFaces -- if got the twin faces
	setFaceSel obj MyFaces
	  ------------------------------------------------------------------------
	  subobjectLevel = 4
	  -- The PolyToolsSelect is Available in 3ds Max 2010 and higher.
	  if MyFaces.count >1 do PolyToolsSelect.StepLoop keyboard.altpressed
	 
	    if OverFlow == 2 then 
		(
			if MyFaces.count >1 then PolytoolsSelect.Ring() else
            ( setLoopBy1Face obj MyFaces edgelist getEdgeSel getFacesByEdge )				
			format "OverFlow.. Done\n"
		) else ( format "Step Loop.. Done !\n" )
    ) -- with redraw off
  )--if edgelist.count
  else messagebox "Select Two Parallel Edges. "
) -- end fn

  on isEnabled return ( if selection.count == 1 and classof $ == Editable_Poly and subobjectLevel == 2 then true else false )
  on Execute do
  ( 
     try ( destroydialog ::SelectFaces_Roll ) catch()
     rollout SelectFaces_Roll "Select Faces By 2 Edges"
     (
	   group "Type :"
	   (
	    radiobuttons type ""  labels:#("Step Loop", "OverFlow") default:1 columns:1
	    button doit "Go" width:120 tooltip:"Select a Loop Faces between two Parallel selected Edges | Alt+Click for Longest Distance (ie: for Loop Cylinder)"
	   )
      ------------------------------------------------
      on doit pressed do
       (
          if selection.count == 1 and classof $ == Editable_Poly and subobjectLevel == 2 then
           ( undo "Select Faces" on SelectFacesBy2Edges_StepLoop $ type.state )
               else messagebox "Working on Sub-Object Level Edge Editable Poly" --; destroydialog SelectFaces_Roll
       )
     ) -- End Rollout
	createdialog SelectFaces_Roll width:150 style:#(#style_sysmenu, #style_toolwindow) --modal:true
  )--on Execute
) -- end Macro

messagebox(
	              " To get 'Select Faces By 2 Edges' just go to menu :\n Customize>> CustomizeUserinterface, Category: \"BG Tools\""
	            ) title:"  Installation scripts"