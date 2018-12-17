if (classOf $ == Editable_Poly) != true then --check if poly == true
	(
	convertToPoly $
	)
	else (messagebox "yes")

-------------------------------------------------------------------------------------------
/* Ignore_backfacing_toogle */

(
	if (selection.count == 1) and (classof $.baseobject == Editable_Poly)
		then $.baseobject.ignorebackfacing = not $.baseobject.ignorebackfacing
	
-------------------------------------------------------------------------------------------	
$.GetEPolySelLevel()
	


  .selByVertex (Select_By_Vertex) : boolean
  .ignoreBackfacing (Ignore_Backfacing_in_Selections) : boolean
  .selectByAngle (Select_by_Angle) : boolean
  .selectAngle (Selection_Angle) : angle
  .useSoftSel (Use_Soft_Selection) : boolean
  .ssUseEdgeDist (Use_Edge_Distance) : boolean
  .ssEdgeDist (Edge_Distance) : integer
  .affectBackfacing (Affect_Backfacing) : boolean
  .falloff : worldUnits
  .pinch : worldUnits
  .bubble : worldUnits
  .lockSoftSel (Lock_Soft_Selection) : boolean
  .paintSelMode (Paint_Mode) : integer
  .paintSelValue (Selection_Value) : float
  .paintSelSize (Brush_Size) : worldUnits
  .paintSelStrength (Brush_Strength) : float
  .constrainType (Vertex_Constraint_Type) : integer
  .deleteIsolatedVerts (Delete_Isolated_Vertices) : boolean
  .fullyInteractive (Fully_Interactive) : boolean
  .showCage (Show_Cage) : boolean
  .split : boolean
  .preserveUVs (Preserve_UVs) : boolean
  .surfSubdivide (Subdivide_Surface) : boolean
  .subdivSmoothing (Smooth_Subdivision_Result) : boolean
  .isolineDisplay (Isoline_Display) : boolean
  .iterations : integer
  .surfaceSmoothness (Surface_Smoothness) : float
  .useRenderIterations (Use_Render_Iterations) : boolean
  .renderIterations (Render_Iterations) : integer
  .useRenderSmoothness (Use_Render_Smoothness) : boolean
  .renderSmoothness (Render_Smoothness) : float
  .sepByMats (Separate_by_Material_ID) : boolean
  .sepBySmGroups (Separate_by_Smoothing_Groups) : boolean
  .update (Update_Type) : integer
  .vertSelectionColor (Vertex_Selection_Color) : RGB color
  .vertSelectBy (Select_Vertex_By) : integer
  .vertSelectionRedRange (Select_by_color__Red_Range) : integer
  .vertSelectionGreenRange (Select_by_color__Green_Range) : integer
  .vertSelectionBlueRange (Select_by_color__Blue_Range) : integer
  .autoSmoothThreshold (Autosmooth_angle_threshold) : angle
  .useSubdivisionDisplacement (Use_Displacement_Subdivision) : boolean
  .displaceSplitMesh (Displacement_Split_Mesh) : boolean
  .displaceMethod (Displacement_Method) : integer
  .displaceSteps (Displacement_Steps) : integer
  .displaceEdge (Displacement_Edge) : float
  .displaceDistance (Displacement_Distance) : float
  .displaceAngle (Displacement_Angle) : angle
  .viewDependent (View_Dependent) : boolean
  .displaceStyle (Displacement_Style) : integer
  .displaceMinLevels (Displacement_Min_Levels) : integer
  .displaceMaxLevels (Displacement_Max_Levels) : integer
  .displaceMaxTris (Displacement_Max_Triangles) : integer
  .extrusionType (Type_of_Extrusion) : integer
  .bevelType (Bevel_Type) : integer
  .faceExtrudeHeight (Face_Extrude_Height) : worldUnits
  .vertexExtrudeHeight (Vertex_Extrude_Height) : worldUnits
  .edgeExtrudeHeight (Edge_Extrude_Height) : worldUnits
  .vertexExtrudeWidth (Vertex_Extrude_Width) : float
  .edgeExtrudeWidth (Edge_Extrude_Width) : float
  .bevelHeight (Bevel_Height) : worldUnits
  .bevelOutline (Bevel_Outline) : worldUnits
  .outlineAmount (Outline_Amount) : worldUnits
  .insetAmount (Inset_amount) : worldUnits
  .insetType (Inset_Type) : integer
  .vertexChamfer (Vertex_Chamfer_Amount) : worldUnits
  .edgeChamfer (Edge_Chamfer_Amount) : worldUnits
  .vertexBreak (Vertex_Break) : worldUnits
  .weldThreshold (Vertex_Weld_Threshold) : worldUnits
  .edgeWeldThreshold (Edge_Weld_Threshold) : worldUnits
  .weldPixels (Weld_Pixel_Threshold) : integer
  .smoothness : float
  .separateBySmoothing (Separate_by_Smoothing_Groups) : boolean
  .separateByMaterial (Separate_by_Material_ID) : boolean
  .tesselateBy (Tessellate_By) : integer
  .tessTension (Tessellation_Tension) : float
  .connectEdgeSegments (Connect_Edge_Segments) : integer
  .extrudeAlongSplineNode (Extrude_Along_Spline_Node) : node
  .extrudeAlongSplineSegments (Extrude_Along_Spline_Segments) : integer
  .extrudeAlongSplineTaper (Extrude_Along_Spline_Taper_Amount) : float
  .extrudeAlongSplineTaperCurve (Extrude_Along_Spline_Taper_Curve) : float
  .extrudeAlongSplineTwist (Extrude_Along_Spline_Twist) : angle
  .extrudeAlongSplineRotation (Extrude_Along_Spline_Rotation) : angle
  .extrudeAlongSplineAlign (Extrude_Along_Spline_Align) : boolean
  .hingeAngle (Hinge_From_Edge_Angle) : angle
  .hinge : index
  .hingeSegments (Hinge_From_Edge_Segments) : integer
  .paintDeformMode (Paint_Mode) : integer
  .paintDeformValue (Deformation_Value) : float
  .paintDeformSize (Deformation_Size) : worldUnits
  .paintDeformStrength (Deformation_Strength) : float
  .paintDeformAxis (Push_Pull_Direction) : integer
  .cutStartLevel (Cut_Start_SO_Level) : integer
  .cutStartIndex (Cut_Start_Index) : index
  .cutStartCoords (Cut_Start_Coordinates) : point3
  .cutEndCoords (Cut_End_Coordinates) : point3
  .cutNormal (Cut_Normal_Direction) : point3
  .bridgeSegments (Bridge_Segments) : integer
  .bridgeTaper (Bridge_Taper) : float
  .bridgeBias (Bridge_Bias) : float
  .bridgeSmoothThreshold (Bridge_Smooth_Threshold) : angle
  .bridgeSelected (Bridge_Selected) : integer
  .bridgeTwist1 (Bridge_Twist_1) : integer
  .bridgeTwist2 (Bridge_Twist_2) : integer
  .bridgeTarget1 (Bridge_Target_1) : integer
  .bridgeTarget2 (Bridge_Target_2) : integer
  .relaxAmount (Relax_Amount) : float
  .relaxIterations (Relax_Iterations) : integer
  .relaxHoldBoundaryPoints (Relax_Hold_Boundary_Points) : boolean
  .relaxHoldOuterPoints (Relax_Hold_Outer_Points) : boolean
  .vertexChamferOpen (Open_Chamfer) : boolean
  .edgeChamferOpen (Open_Chamfer) : boolean
  .bridgeAdjacentAngle (Bridge_Adjacent) : angle
  .bridgeReverseTriangle (Reverse_Triangle) : integer
  .connectEdgePinch (Connect_Edge_Pinch) : integer
  .connectEdgeSlide (Connect_Edge_Slide) : integer
  .cageColor (Cage_Color) : point3
  .selectedCageColor (Selected_Cage_Color) : point3