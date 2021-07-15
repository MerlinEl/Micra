-------------------------------------------------------------------------------
-- objectPainter.ms
-- By Neil Blevins (neil@soulburn3d.com)
-- v 1.22
-- Created On: 02/19/08
-- Modified On: 10/18/20
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- This script lets you paint objects (geometry, splines, lights, helpers, 
-- etc) onto a piece of geometry. Like for example, you can make 10 different 
-- rocks, and then paint them in a random fashion onto a terrain.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make a plane with many segments, apply a noise modifier to make it hilly. 
-- Create a sphere, a cylinder and a box. Run the UI version of the script.
-- Select the plane, click the "Add Selection To Paint On List" Button. The
-- plane is added to the list. Select the 3 other objects, click the 
-- "Add Selection To Paint With List" button. Those 3 objects get added to 
-- the second list. Now click the "Paint" button", and start painting with the
-- mouse on the plane, and your 3 pieces of geometry will appear on the surface.
-- To turn off, click the Paint button again. To delete your last painted
-- objects, undo or hit the Delete button.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- 1) There's a known max8 crash bug with the painter system and the undo system. 
-- So if you're using max8 and this script, be careful using undo. The problem 
-- does not exist in max 2008. 
-- 2) Scattering does not work properly on objects that overlap themselves. If 
-- scattering isn't doing what you want, turn off that option and paint 
-- manually. 
-- 3) This script misbehaves if used on scenes that have duplicate object 
-- names. If the script refuses to paint even though you have everything setup 
-- correctly, check to see if any objects in your scene have duplicate names. 
-- Fixing the names will allow the script to function properly.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added delete buttons to remove items from the 2 lists.
--
-- v 1.02 Fixed a bug when trying to remove objects from the 2 lists. Added 
-- weights to paint with objects. Increase the weight of an object to have it 
-- chosen more frequently. Added scatter, so now your brushsize can determine
-- the distance an object can be scattered. Added group support.
--
-- v 1.03 Added a way to rename the splines.
--
-- v 1.04 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.05 You can now align your object based on stroke direction. Thanks to 
-- Dubbie for some code!
--
-- v 1.06 In case you have a slow computer, you can now have your painted 
-- objects appear in box mode. Cleaned up interface some, it was getting too long.
--
-- v 1.07 Added a place mode, instead of painting a series of objects on the 
-- surface, it will place a single object at the spot you initial touch.
--
-- v 1.08 Fixed a bug that occured if you renamed your Paint With object. Now 
-- you can specify an initial size multiplier for your Paint With objects.
--
-- v 1.09 Some code added to copy user props to new instanced meshes, thanks
-- to Shawn Olson.
--
-- v 1.10 You now have the option of painting on all scene objects instead of
-- just specific objects. Warning, this can get slow, so use with caution.
--
-- v 1.11 Added ability to limit random rotation to multiples of 90 degrees.
--
-- v 1.12 Now when you instance geometry it copies over the Object ID
-- of the original object.
--
-- v 1.13 Disposed of a gc() that was interfereing with undo. However, now
-- it's possible that painting using the option "Paint On All Scene Objects?"
-- may be slightly more unstable. Use with caution.
--
-- v 1.20 Added a "Straight Line" mode that places objects on your surface
-- in a straight line. Click a start point, drag and release the mouse at the
-- end point, and it will connect those two points on the surface with your
-- "Paint With" objects. Great for stuff like rivets on a plane fuselage.
--
-- v 1.21 Defaults now to no Prefix on newly created objects. Now you can have
-- the new objects created on the active layer, or have them keep their original
-- layer. If you choose Actve layer, the script now gives you an error if you 
-- try and create objects on a hidden layer. If you REALLY want to paint objects 
-- on a hidden layer, unhide the layer, hit the "Paint" button in the UI, then 
-- rehide the layer to circumvent the system.
--
-- v 1.22 Fixed a bug where it was constantly renaming the painted objects
-- with a name whose number was incresing by 2.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global objectPainterDefaults
global objectPainterUI

global oPACloseOpenUI

global oPAstartStroke
global oPApaintStroke
global oPAendStroke
global oPAcancelStroke
global oPAsystemEnd

global oPAPutObject

global oPAHelp
global oPALoadDef
global oPASaveDef

global oPADefineUI
global oPARolloutObjs
global oPARolloutOptions
global oPARolloutRand
global oPARolloutTools
global oPAFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global oPADupModeValue = 1
global oPAAlignValue = true
global oPAAlignYValue = true
global oPABrushSizeValue = 10
global oPABrushSizeScatterValue = false
global oPADensityValue = 25
global oPAPaintWithObjectSizeValue = 1.0
global oPAPrefixValue = ""
global oPABoxModeValue = false
global oPAUserPropValue = false
global oPAOriginalLayerValue = true
global oPAPositionValue = false
global oPAMinXPosValue = 0
global oPAMaxXPosValue = 0
global oPAMinYPosValue = 0
global oPAMaxYPosValue = 0
global oPAMinZPosValue = 0
global oPAMaxZPosValue = 0
global oPARotationValue = true
global oPAMinXRotValue = 0
global oPAMaxXRotValue = 0
global oPAMinYRotValue = 0
global oPAMaxYRotValue = 0
global oPAMinZRotValue = -90
global oPAMaxZRotValue = 90
global oPAScaleValue = true
global oPAMinXScaleValue = 50
global oPAMaxXScaleValue = 150
global oPAMinYScaleValue = 100
global oPAMaxYScaleValue = 100
global oPAMinZScaleValue = 100
global oPAMaxZScaleValue = 100
global oPARotLimitValue = false
global oPAScaleUniValue = true
global oPAFlipXValue = false
global oPAFlipYValue = false
global oPAFlipZValue = false
global oPAModeValue = 1
global oPAOnAllObjsValue = false

global oPAPaintOnList = #()
global oPAPaintWithList = #()
global oPAPaintWithListNames = #()
global oPALastPaintWithObjs = #()

global oPALastPoint = [0,0,0]
global oPALastNormal = Point3 0 0 0
global oPAPaintedFirst = false

oPAPosValue = [85,90]

-- Functions

fn objectPainterDefaults = 
	(
	oPALoadDef()
	)

fn objectPainterUI = 
	(
	oPALoadDef()
	oPACloseOpenUI oPAPosValue
	)
	
fn oPACloseOpenUI pos = 
	(
	if oPAFloater != undefined then CloseRolloutFloater oPAFloater
	oPADefineUI()
	oPAFloater = newRolloutFloater "objectPainter v1.22" 210 816 pos.x pos.y
	addRollout oPARolloutObjs oPAFloater
	addRollout oPARolloutOptions oPAFloater
	addRollout oPARolloutRand oPAFloater rolledUp:true
	addRollout oPARolloutTools oPAFloater
	)

fn oPAstartStroke = 
	(
	thePainterInterface.undoStart()
	thePainterInterface.minSize = oPABrushSizeValue
	thePainterInterface.maxSize = oPABrushSizeValue
	
	oPALastPoint = [0,0,0]
	oPALastNormal = Point3 0 0 0
	oPAPaintedFirst = false

	if oPAOnAllObjsValue == false then oPAPaintOnObjList = for i in oPAPaintOnList collect (getNodeByName i)
	else oPAPaintOnObjList = $*

	thePainterInterface.initializeNodes 0 oPAPaintOnObjList
	)

fn oPApaintStroke = 
	(
	if oPAModeValue == 1 or (oPAModeValue == 2 and oPAPaintedFirst == false) then
		(
		-- Variables
		localHit = Point3 0 0 0;localNormal = Point3 0 0 0;worldHit = Point3 0 0 0;worldNormal = Point3 0 0 0;str = 0.0f;radius = 0.0f

		-- Get Hit Point
		thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal &radius &str 0

		-- Choose final point
		if oPABrushSizeScatterValue == false then 
			(
			FinalPoint = worldHit
			FinalNormal = worldNormal
			)
		else
			(
			-- Calculate Bounding Box
			BB = sLibGetCollectionBBox $*
			lengths = #((abs(BB[1].x) + abs(BB[2].x)), (abs(BB[1].y) + abs(BB[2].y)), (abs(BB[1].z) + abs(BB[2].z)))
			bBMax = amax lengths
			-- Choose Paint On Objects
			if oPAOnAllObjsValue == false then oPAPaintOnObjList = for i in oPAPaintOnList collect (getNodeByName i)
			else oPAPaintOnObjList = $*
			-- find surface point above surface
			abovePoint = worldHit + ((bBMax + radius + 100)*normalize(worldNormal))
			-- scatter the point
			randRad = random 0 radius
			randDir = [(random -1.0 1.0),(random -1.0 1.0),(random -1.0 1.0)]
			scatterPoint = abovePoint + (randRad*normalize(randDir))
			-- find intersection with mesh		
			local r	
			for obj in oPAPaintOnObjList do
				(
				r = intersectray obj (ray scatterPoint [(-1)*(worldNormal.x),(-1)*(worldNormal.y),(-1)*(worldNormal.z)])
				if r != undefined then exit
				)
			if r == undefined then (FinalPoint = undefined;FinalNormal = undefined)
			else (FinalPoint = r.pos;FinalNormal = r.dir)
			)

		if FinalPoint != undefined then
			(
			-- Density
			if oPAModeValue == 1 and (((random 1 99) + (oPADensityValue - 50)) < 50) then exit
			else 
				(
				oPAPutObject FinalPoint FinalNormal
				)
			)
		)
	if oPAModeValue == 3 then
		(
		if oPALastPoint == [0,0,0] then
			(
			-- Variables
			localHit = Point3 0 0 0;localNormal = Point3 0 0 0;worldHit = Point3 0 0 0;worldNormal = Point3 0 0 0;str = 0.0f;radius = 0.0f

			-- Get Hit Point
			thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal &radius &str 0

			oPALastPoint = worldHit
			oPALastNormal = worldNormal
			)
		)
	)

fn oPAendStroke = 
	(
	--See note about v 1.13
	--gc()
	thePainterInterface.undoAccept()
	if oPAModeValue == 3 then
		(
		-- Variables
		localHit = Point3 0 0 0;localNormal = Point3 0 0 0;worldHit = Point3 0 0 0;worldNormal = Point3 0 0 0;str = 0.0f;radius = 0.0f

		-- Get Hit Point
		thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal &radius &str 0

		-- Calculate Bounding Box
		BB = sLibGetCollectionBBox $*
		lengths = #((abs(BB[1].x) + abs(BB[2].x)), (abs(BB[1].y) + abs(BB[2].y)), (abs(BB[1].z) + abs(BB[2].z)))
		bBMax = amax lengths

		-- Line Variables
		pos1 = oPALastPoint
		norm1 = oPALastNormal
		pos2 = worldHit
		norm2 = worldNormal
		myvec = pos2-pos1
		myvecnorm = normalize((normalize(norm1))+(normalize(norm2)))
		mydist = length myvec

		mysteps = (0.1*(oPADensityValue/25)*mydist) as integer
		mypos = pos1
		for i = 1 to (mysteps+1) do
			(
			-- Choose Paint On Objects
			if oPAOnAllObjsValue == false then oPAPaintOnObjList = for i in oPAPaintOnList collect (getNodeByName i)
			else oPAPaintOnObjList = $*
			-- find surface point above surface
			abovePoint = mypos + ((bBMax + radius + 100)*normalize(myvecnorm))
			-- find intersection with mesh		
			local r	
			for obj in oPAPaintOnObjList do
				(
				r = intersectray obj (ray abovePoint [(-1)*(normalize(myvecnorm)).x,(-1)*(normalize(myvecnorm)).y,(-1)*(normalize(myvecnorm)).z])
				if r != undefined then exit
				)
			if r == undefined then (FinalPoint = undefined;FinalNormal = undefined)
			else (FinalPoint = r.pos;FinalNormal = r.dir)

			if FinalPoint != undefined then 
				(
				if i == 1 then (oPALastPoint = pos2;oPALastNormal = norm2)
				oPAPutObject FinalPoint FinalNormal
				)
			mypos += (1.0/(mysteps as float))*myvec
			)
		completeRedraw()
		)
	)

fn oPAcancelStroke = 
	(
	thePainterInterface.undoCancel()
	)

fn oPAsystemEnd = 
	(
	)
	
fn oPAPutObject FinalPoint FinalNormal = 
	(
	-- Choose Object
	oPAPaintWithListFinal = #()
	for i in oPAPaintWithList do (for v = 1 to i[2] do append oPAPaintWithListFinal i[1])
	rand = random 1 oPAPaintWithListFinal.count
	MyObj = (getNodeByName oPAPaintWithListFinal[rand])
	if MyObj != undefined then
		(
		-- Duplicate Object
		-- if group
		if (isGroupHead MyObj) == true then 
			(
			if oPADupModeValue == 1 then maxops.clonenodes MyObj cloneType:#instance actualNodeList:&Origobj newNodes:&Newobj
			else maxops.clonenodes MyObj cloneType:#copy actualNodeList:&Origobj newNodes:&Newobj	
			myindex = findItem Origobj MyObj
			obj = Newobj[myindex]
			)
		-- if object
		else
			(
			if oPADupModeValue == 2 then obj = copy MyObj
			else obj = instance MyObj
			obj.wirecolor = MyObj.wirecolor
			)
		
		-- Align To Normal
		if oPAAlignValue == true then
			(
			tm = matrix3 1 
			tm = matrixFromNormal FinalNormal
			obj.rotation = inverse tm.rotationpart
			)

		-- Align To Direction
		if oPAAlignYValue == true then
			(
			DirVector = [(FinalPoint[1] - oPALastPoint[1]),(FinalPoint[2] - oPALastPoint[2]),(FinalPoint[3] - oPALastPoint[3])]
			a = cross (normalize FinalNormal) (normalize DirVector)
			b = -(cross (normalize a) (normalize FinalNormal))
			theMatrix = matrix3 a b FinalNormal FinalPoint
			objScale = obj.scale
			obj.transform = theMatrix
			obj.scale = objScale
			)

		-- Move
		obj.pos = FinalPoint

		-- Initial Scale
		obj.scale = oPAPaintWithObjectSizeValue*obj.scale

		-- Random Position
		if oPAPositionValue == true then
			(
			obj.pos += [(random oPAMinXPosValue oPAMaxXPosValue),(random oPAMinYPosValue oPAMaxYPosValue),(random oPAMinZPosValue oPAMaxZPosValue)]
			)

		-- Random Rotation
		if oPARotationValue == true then
			(
			if oPARotLimitValue == true then
				(
				-- x
				xValue = random (oPAMinXRotValue-45) (oPAMaxXRotValue+45)
				newxValue = (xValue as float)/90
				newestxValue = newxValue as integer
				finalxValue = newestxValue * 90
				-- y
				yValue = random (oPAMinYRotValue-45) (oPAMaxYRotValue+45)
				newyValue = (yValue as float)/90
				newestyValue = newyValue as integer
				finalyValue = newestyValue * 90
				--z
				zValue = random (oPAMinZRotValue-45) (oPAMaxZRotValue+45)
				newzValue = (zValue as float)/90
				newestzValue = newzValue as integer
				finalzValue = newestzValue * 90
				)	
			else
				(
				finalxValue = random oPAMinXRotValue oPAMaxXRotValue
				finalyValue = random oPAMinYRotValue oPAMaxYRotValue
				finalzValue = random oPAMinZRotValue oPAMaxZRotValue
				)
			in coordsys local rotate obj (EulerAngles finalxValue finalyValue finalzValue)
			)

		-- Random Scale
		if oPAScaleValue == true then
			(
			if oPAScaleUniValue == true then
				(
				rand = (random oPAMinXScaleValue oPAMaxXScaleValue)*0.01
				obj.scale *= [rand,rand,rand]
				)
			else obj.scale *= [(random oPAMinXScaleValue oPAMaxXScaleValue)*0.01,(random oPAMinYScaleValue oPAMaxYScaleValue)*0.01,(random oPAMinZScaleValue oPAMaxZScaleValue)*0.01]
			)

		-- Box Mode
		if oPABoxModeValue == true then obj.boxMode = true

		-- Random Flip
		if oPAFlipXValue == true then if (random 0 100) > 50 then scale obj [-1,1,1]
		if oPAFlipYValue == true then if (random 0 100) > 50 then scale obj [1,-1,1]
		if oPAFlipZValue == true then if (random 0 100) > 50 then scale obj [1,1,-1]

		obj.gbufferchannel = MyObj.gbufferchannel
		if oPAUserPropValue == true then 
			(
			oldBuffer = getUserPropBuffer MyObj
			if oldBuffer != undefined then setUserPropBuffer obj oldBuffer
			)

		-- Layers
		if oPAOriginalLayerValue == true then sLibCopyAndPasteLayerFromNodeToNode MyObj obj
		
		-- Rename
		obj.name = "temp"
		obj.name = uniquename (oPAPrefixValue + MyObj.name)
		
		-- Add To List
		append oPALastPaintWithObjs obj
		oPALastPoint = FinalPoint
		oPALastNormal = FinalNormal
		oPAPaintedFirst = true
		)
	else print "The script can't find one of your Paint With objects, could you have deleted or renamed the object?"
	)
	
fn oPAHelp = 
	(
	sLibSSPrintHelp "objectPainter"
	)
	
fn oPALoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	oPAInputFilename = presetDir + "objectPainter.ini"
	if (sLibFileExist oPAInputFilename == true) then
		(
		oPADupModeValue = execute (getINISetting oPAInputFilename "objectPainter" "oPADupModeValue")
		oPAAlignValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAAlignValue")
		oPAAlignYValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAAlignYValue")
		oPABrushSizeValue = execute (getINISetting oPAInputFilename "objectPainter" "oPABrushSizeValue")
		oPABrushSizeScatterValue = execute (getINISetting oPAInputFilename "objectPainter" "oPABrushSizeScatterValue")
		oPADensityValue = execute (getINISetting oPAInputFilename "objectPainter" "oPADensityValue")
		oPAPaintWithObjectSizeValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAPaintWithObjectSizeValue")
		oPAPrefixValue = getINISetting oPAInputFilename "objectPainter" "oPAPrefixValue"
		oPABoxModeValue = execute (getINISetting oPAInputFilename "objectPainter" "oPABoxModeValue")
		oPAUserPropValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAUserPropValue")
		oPAOriginalLayerValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAOriginalLayerValue")
		oPAPositionValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAPositionValue")
		oPAMinXPosValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMinXPosValue")
		oPAMaxXPosValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMaxXPosValue")
		oPAMinYPosValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMinYPosValue")
		oPAMaxYPosValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMaxYPosValue")
		oPAMinZPosValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMinZPosValue")
		oPAMaxZPosValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMaxZPosValue")
		oPARotationValue = execute (getINISetting oPAInputFilename "objectPainter" "oPARotationValue")
		oPAMinXRotValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMinXRotValue")
		oPAMaxXRotValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMaxXRotValue")
		oPAMinYRotValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMinYRotValue")
		oPAMaxYRotValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMaxYRotValue")
		oPAMinZRotValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMinZRotValue")
		oPAMaxZRotValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMaxZRotValue")
		oPAScaleValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAScaleValue")
		oPAMinXScaleValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMinXScaleValue")
		oPAMaxXScaleValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMaxXScaleValue")
		oPAMinYScaleValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMinYScaleValue")
		oPAMaxYScaleValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMaxYScaleValue")
		oPAMinZScaleValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMinZScaleValue")
		oPAMaxZScaleValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAMaxZScaleValue")
		oPARotLimitValue = execute (getINISetting oPAInputFilename "objectPainter" "oPARotLimitValue")
		oPAScaleUniValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAScaleUniValue")
		oPAFlipXValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAFlipXValue")
		oPAFlipYValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAFlipYValue")
		oPAFlipZValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAFlipZValue")
		oPAModeValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAModeValue")
		oPAOnAllObjsValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAOnAllObjsValue")
		oPAPosValue = execute (getINISetting oPAInputFilename "objectPainter" "oPAPosValue")
		
		if oPADupValue == OK then oPADupValue = 1
		if oPAAlignValue == OK then oPAAlignValue = true
		if oPAAlignYValue == OK then oPAAlignYValue = true
		if oPABrushSizeValue == OK then oPABrushSizeValue = 10
		if oPABrushSizeScatterValue == OK then oPABrushSizeScatterValue = false
		if oPADensityValue == OK then oPADensityValue = 25
		if oPAPaintWithObjectSizeValue == OK then oPAPaintWithObjectSizeValue = 1.0
		if oPAPrefixValue == OK then oPAPrefixValue = ""
		if oPABoxModeValue == OK then oPABoxModeValue = false
		if oPAUserPropValue == OK then oPAUserPropValue = false
		if oPAOriginalLayerValue == OK then oPAOriginalLayerValue = true
		if oPAMinXPosValue == OK then oPAMinXPosValue = 0
		if oPAMaxXPosValue == OK then oPAMaxXPosValue = 0
		if oPAMinYPosValue == OK then oPAMinYPosValue = 0
		if oPAMaxYPosValue == OK then oPAMaxYPosValue = 0
		if oPAMinZPosValue == OK then oPAMinZPosValue = 0
		if oPAMaxZPosValue == OK then oPAMaxZPosValue = 0
		if oPARotationValue == OK then oPARotationValue = true
		if oPAMinXRotValue == OK then oPAMinXRotValue = 0
		if oPAMaxXRotValue == OK then oPAMaxXRotValue = 0
		if oPAMinYRotValue == OK then oPAMinYRotValue = 0
		if oPAMaxYRotValue == OK then oPAMaxYRotValue = 0
		if oPAMinZRotValue == OK then oPAMinZRotValue = -90
		if oPAMaxZRotValue == OK then oPAMaxZRotValue = 90
		if oPAScaleValue == OK then oPAScaleValue = true
		if oPAMinXScaleValue == OK then oPAMinXScaleValue = 50
		if oPAMaxXScaleValue == OK then oPAMaxXScaleValue = 150
		if oPAMinYScaleValue == OK then oPAMinYScaleValue = 100
		if oPAMaxYScaleValue == OK then oPAMaxYScaleValue = 100
		if oPAMinZScaleValue == OK then oPAMinZScaleValue = 100
		if oPAMaxZScaleValue == OK then oPAMaxZScaleValue = 100
		if oPARotLimitValue == OK then oPARotLimitValue = false
		if oPAScaleUniValue == OK then oPAScaleUniValue = true
		if oPAFlipXValue == OK then oPAFlipXValue = false
		if oPAFlipYValue == OK then oPAFlipYValue = false
		if oPAFlipZValue == OK then oPAFlipZValue = false
		if oPAModeValue == OK then oPAModeValue = 1
		if oPAOnAllObjsValue  == OK then oPAOnAllObjsValue  = false
		if oPAPosValue == OK then oPAPosValue = [85,90]
		)
	else
		(
		oPADupValue = 1
		oPAAlignValue = true
		oPAAlignYValue = true
		oPABrushSizeValue = 10
		oPABrushSizeScatterValue = false
		oPADensityValue = 25
		oPAPaintWithObjectSizeValue = 1.0
		oPAPrefixValue = ""
		oPABoxModeValue = false
		oPAUserPropValue = false
		oPAOriginalLayerValue = true
		oPAPositionValue = false
		oPAMinXPosValue = 0
		oPAMaxXPosValue = 0
		oPAMinYPosValue = 0
		oPAMaxYPosValue = 0
		oPAMinZPosValue = 0
		oPAMaxZPosValue = 0
		oPARotationValue = true
		oPAMinXRotValue = 0
		oPAMaxXRotValue = 0
		oPAMinYRotValue = 0
		oPAMaxYRotValue = 0
		oPAMinZRotValue = -90
		oPAMaxZRotValue = 90
		oPAScaleValue = true
		oPAMinXScaleValue = 50
		oPAMaxXScaleValue = 150
		oPAMinYScaleValue = 100
		oPAMaxYScaleValue = 100
		oPAMinZScaleValue = 100
		oPAMaxZScaleValue = 100
		oPARotLimitValue = false
		oPAScaleUniValue = true
		oPAFlipXValue = false
		oPAFlipYValue = false
		oPAFlipZValue = false
		oPAModeValue = 1
		oPAOnAllObjsValue = false
		oPAPosValue = [85,90]
		)
	)

fn oPASaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	oPAOutputFilename = presetDir + "objectPainter.ini"
	if (sLibFileExist oPAOutputFilename == true) then deleteFile oPAOutputFilename
	setINISetting oPAOutputFilename "objectPainter" "oPADupModeValue" (oPADupModeValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAAlignValue" (oPAAlignValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAAlignYValue" (oPAAlignYValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPABrushSizeValue" (oPABrushSizeValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPABrushSizeScatterValue" (oPABrushSizeScatterValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPADensityValue" (oPADensityValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAPaintWithObjectSizeValue" (oPAPaintWithObjectSizeValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAPrefixValue" (oPAPrefixValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPABoxModeValue" (oPABoxModeValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAUserPropValue" (oPAUserPropValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAOriginalLayerValue" (oPAOriginalLayerValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAPositionValue" (oPAPositionValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMinXPosValue" (oPAMinXPosValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMaxXPosValue" (oPAMaxXPosValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMinYPosValue" (oPAMinYPosValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMaxYPosValue" (oPAMaxYPosValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMinZPosValue" (oPAMinZPosValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMaxZPosValue" (oPAMaxZPosValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPARotationValue" (oPARotationValue as string)	
	setINISetting oPAOutputFilename "objectPainter" "oPAMinXRotValue" (oPAMinXRotValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMaxXRotValue" (oPAMaxXRotValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMinYRotValue" (oPAMinYRotValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMaxYRotValue" (oPAMaxYRotValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMinZRotValue" (oPAMinZRotValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMaxZRotValue" (oPAMaxZRotValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAScaleValue" (oPAScaleValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMinXScaleValue" (oPAMinXScaleValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMaxXScaleValue" (oPAMaxXScaleValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMinYScaleValue" (oPAMinYScaleValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMaxYScaleValue" (oPAMaxYScaleValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMinZScaleValue" (oPAMinZScaleValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAMaxZScaleValue" (oPAMaxZScaleValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPARotLimitValue" (oPARotLimitValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAScaleUniValue" (oPAScaleUniValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAFlipXValue" (oPAFlipXValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAFlipYValue" (oPAFlipYValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAFlipZValue" (oPAFlipZValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAModeValue" (oPAModeValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAOnAllObjsValue" (oPAOnAllObjsValue as string)
	setINISetting oPAOutputFilename "objectPainter" "oPAPosValue" (oPAFloater.pos as string)
	)

-- UI

fn oPADefineUI = 
	(
	rollout oPARolloutObjs "Paint On Paint With"
		(
		group "Paint On"
		(
		button oPAPaintOnButton "Add Sel To Paint On List" toolTip:"Add Selection To Paint On List" width:153 align:#left across:2
		button oPAPaintOnDelButton "-" toolTip:"Delete Choosen Object From Paint On List" width:15 align:#right
		listbox oPAPaintOnListbox "Paint On List:" items:oPAPaintOnList height:6
		checkbox oPAOnAllObjsCheckbox "Paint On All Scene Objects?" checked:oPAOnAllObjsValue align:#center
		)
		on oPAPaintOnButton pressed do 
			(
			oPAPaintOnList = #()
			error = false
			for i in selection do
				(
				if (sLibGeometryFilter i) == false then error = true
				else append oPAPaintOnList i.name
				)
			if error == true then (MessageBox "One of your objects to be painted on is not a piece of geometry and was removed from your list." title:"objectPainter")
			curPos = oPAFloater.pos
			oPACloseOpenUI curPos
			)
		on oPAPaintOnDelButton pressed do 
			(
			if oPAPaintOnList.count != 0 then 
				(
				deleteItem oPAPaintOnList oPAPaintOnListbox.selection
				curPos = oPAFloater.pos
				oPACloseOpenUI curPos
				)
			)
		on oPAOnAllObjsCheckbox changed state do 
			(
			oPAPaintOnButton.enabled = not state
			oPAPaintOnDelButton.enabled = not state
			oPAPaintOnListbox.enabled = not state
			oPAOnAllObjsValue = state
			)

		group "Paint With"
		(			
		dropdownlist oPADupModeDropdown "" items:#("Instance", "Copy") selection:oPADupModeValue width:170 align:#center
		button oPAPaintWithButton "Add Sel To Paint With List" toolTip:"Add Selection To Paint With List" width:153 align:#left across:2
		button oPAPaintWithDelButton "-" toolTip:"Delete Choosen Object From With List" width:15 align:#right
		listbox oPAPaintWithListbox "Paint With List:" items:oPAPaintWithListNames height:6
		spinner oPAWeightSpinner "Weight: " range:[1,999,1] fieldWidth:40 type:#integer align:#right
		)
		on oPADupModeDropdown selected i do oPADupModeValue = i
		on oPAPaintWithButton pressed do 
			(
			oPAPaintWithList = #()
			oPAPaintWithListNames = #()
			for i in selection do
				(
				error = false
				if (isGroupMember i) == true then 
					(
					if (isGroupHead i) == false then error = true
					)
				if error == false then
					(
					append oPAPaintWithList #(i.name,1)
					append oPAPaintWithListNames (i.name + " (1)")					
					)
				)
			curPos = oPAFloater.pos
			oPACloseOpenUI curPos
			)
		on oPAPaintWithDelButton pressed do 
			(
			if oPAPaintWithList.count != 0 then
				(
				deleteItem oPAPaintWithList oPAPaintWithListbox.selection
				deleteItem oPAPaintWithListNames oPAPaintWithListbox.selection
				curPos = oPAFloater.pos
				oPACloseOpenUI curPos
				)
			)
		on oPAPaintWithListbox selected item do 
			(
			oPAWeightSpinner.value = oPAPaintWithList[oPAPaintWithListbox.selection][2]
			)
		on oPAWeightSpinner changed val do 
			(
			curSel = oPAPaintWithListbox.selection
			oPAPaintWithList[curSel][2] = val
			oPAWeightSpinner.value = val
			oPAPaintWithListNames[curSel] = (oPAPaintWithList[curSel][1] + " (" + (oPAPaintWithList[curSel][2] as string) +")")
			oPAPaintWithListbox.items = oPAPaintWithListNames
			)
		
		on oPARolloutObjs open do
			(
			if oPAPaintWithList.count == 0 then oPAWeightSpinner.value = 1 else oPAWeightSpinner.value = oPAPaintWithList[oPAPaintWithListbox.selection][2]
			if oPAOnAllObjsValue == true then
				(
				oPAPaintOnButton.enabled = not oPAOnAllObjsValue
				oPAPaintOnDelButton.enabled = not oPAOnAllObjsValue
				oPAPaintOnListbox.enabled = not oPAOnAllObjsValue
				)
			)	
		)

	rollout oPARolloutOptions "Options"
		(
		checkbox oPAAlignCheckbox "Align Z Axis To Normal?" checked:oPAAlignValue align:#right
		checkbox oPAAlignYCheckbox "Align Y Axis To Direction?" checked:oPAAlignYValue align:#right
		spinner oPABrushSizeSpinner "Brush Size: " range:[0,9999999,oPABrushSizeValue] fieldWidth:40 type:#float align:#right
		checkbox oPABrushSizeScatterCheckbox "Brush Size Controls Scatter" checked:oPABrushSizeScatterValue align:#right	
		spinner oPADensitySpinner "Brush Density: " range:[0,100,oPADensityValue] fieldWidth:40 type:#float align:#right
		spinner oPAPaintWithObjectSizeSpinner "Paint With Obj Scale Mult: " range:[0,100,oPAPaintWithObjectSizeValue] fieldWidth:40 type:#float align:#right
		edittext oPAPrefixEditText "Prefix:" fieldWidth:110 text:oPAPrefixValue align:#right
		checkbox oPABoxModeCheckbox "Display Paint With as Boxes?" checked:oPABoxModeValue align:#right
		checkbox oPAUserPropCheckbox "Keep User Defined Properties" checked:oPAUserPropValue align:#right	
		checkbox oPAOriginalLayerCheckbox "Keep Original Layer" checked:oPAOriginalLayerValue align:#right
		button oPASelectObjsButton "Select" width:80 align:#center toolTip:"Select Previous Painted Objects" across:2
		button oPADeleteObjsButton "Delete" width:80 align:#center toolTip:"Delete Previous Painted Objects"
		
		on oPAAlignCheckbox changed state do oPAAlignValue = state
		on oPAAlignYCheckbox changed state do oPAAlignYValue = state
		on oPABrushSizeSpinner changed val do oPABrushSizeValue = val
		on oPABrushSizeScatterCheckbox changed state do oPABrushSizeScatterValue = state
		on oPADensitySpinner changed val do oPADensityValue = val
		on oPAPaintWithObjectSizeSpinner changed val do oPAPaintWithObjectSizeValue = val
		on oPAPrefixEditText changed text do oPAPrefixValue = oPAPrefixEditText.text
		on oPABoxModeCheckbox changed state do oPABoxModeValue = state
		on oPAUserPropCheckbox changed state do oPAUserPropValue = state
		on oPAOriginalLayerCheckbox changed state do oPAOriginalLayerValue = state

		on oPASelectObjsButton pressed do 
			(
			undo "objectPainter" on
				(
				oPALastPaintWithObjsWhoExist = #()
				myerror = false
				for o in oPALastPaintWithObjs do
					(
					if (IsValidNode o) == true then append oPALastPaintWithObjsWhoExist o
					else myerror = true 
					)
				if myerror == true then (MessageBox "At least one 'Paint With' object no longer exists. Selecting any objects that still exist." title:"objectPainter")
				if oPALastPaintWithObjsWhoExist.count != 0 then (select oPALastPaintWithObjsWhoExist)
				completeRedraw()
				)
			)
			
		on oPADeleteObjsButton pressed do 
			(
			undo "objectPainter" on
				(
				oPALastPaintWithObjsWhoExist = #()
				myerror = false
				for o in oPALastPaintWithObjs do
					(
					if (IsValidNode o) == true then append oPALastPaintWithObjsWhoExist o
					else myerror = true 
					)
				if myerror == true then (MessageBox "At least one 'Paint With' object no longer exists. Deleting any objects that still exist." title:"objectPainter")
				for o in oPALastPaintWithObjsWhoExist do delete o
				oPALastPaintWithObjs = #()
				oPALastPaintWithObjsWhoExist = #()
				completeRedraw()
				)
			)
		)
		
	rollout oPARolloutRand "Random Variation"
		(		
		checkbox oPAPositionCheckbox "Position:" checked:oPAPositionValue align:#left
		spinner oPAMinXPosSpinner "Min X: " range:[-9999999,9999999,oPAMinXPosValue] fieldWidth:40 type:#float align:#left across:2 offset:[-4,0]
		spinner oPAMaxXPosSpinner "Max X: " range:[-9999999,9999999,oPAMaxXPosValue] fieldWidth:40 type:#float align:#right offset:[4,0]
		spinner oPAMinYPosSpinner "Min Y: " range:[-9999999,9999999,oPAMinYPosValue] fieldWidth:40 type:#float align:#left across:2 offset:[-4,0]
		spinner oPAMaxYPosSpinner "Max Y: " range:[-9999999,9999999,oPAMaxYPosValue] fieldWidth:40 type:#float align:#right offset:[4,0]
		spinner oPAMinZPosSpinner "Min Z: " range:[-9999999,9999999,oPAMinZPosValue] fieldWidth:40 type:#float align:#left across:2 offset:[-4,0]
		spinner oPAMaxZPosSpinner "Max Z: " range:[-9999999,9999999,oPAMaxZPosValue] fieldWidth:40 type:#float align:#right offset:[4,0]

		checkbox oPARotationCheckbox "Rotation:" checked:oPARotationValue align:#left
		spinner oPAMinXRotSpinner "Min X: " range:[-360,360,oPAMinXRotValue] fieldWidth:40 type:#float align:#left across:2 offset:[-4,0]
		spinner oPAMaxXRotSpinner "Max X: " range:[-360,360,oPAMaxXRotValue] fieldWidth:40 type:#float align:#right offset:[4,0]
		spinner oPAMinYRotSpinner "Min Y: " range:[-360,360,oPAMinYRotValue] fieldWidth:40 type:#float align:#left across:2 offset:[-4,0]
		spinner oPAMaxYRotSpinner "Max Y: " range:[-360,360,oPAMaxYRotValue] fieldWidth:40 type:#float align:#right offset:[4,0]
		spinner oPAMinZRotSpinner "Min Z: " range:[-360,360,oPAMinZRotValue] fieldWidth:40 type:#float align:#left across:2 offset:[-4,0]
		spinner oPAMaxZRotSpinner "Max Z: " range:[-360,360,oPAMaxZRotValue] fieldWidth:40 type:#float align:#right offset:[4,0]

		checkbox oPAScaleCheckbox "Scale:" checked:oPAScaleValue align:#left
		spinner oPAMinXScaleSpinner "Min X: " range:[0,9999999,oPAMinXScaleValue] fieldWidth:40 type:#float align:#left across:2 offset:[-4,0]
		spinner oPAMaxXScaleSpinner "Max X: " range:[0,9999999,oPAMaxXScaleValue] fieldWidth:40 type:#float align:#right offset:[4,0]
		spinner oPAMinYScaleSpinner "Min Y: " range:[0,9999999,oPAMinYScaleValue] fieldWidth:40 type:#float align:#left across:2 offset:[-4,0]
		spinner oPAMaxYScaleSpinner "Max Y: " range:[0,9999999,oPAMaxYScaleValue] fieldWidth:40 type:#float align:#right offset:[4,0]
		spinner oPAMinZScaleSpinner "Min Z: " range:[0,9999999,oPAMinZScaleValue] fieldWidth:40 type:#float align:#left across:2 offset:[-4,0]
		spinner oPAMaxZScaleSpinner "Max Z: " range:[0,9999999,oPAMaxZScaleValue] fieldWidth:40 type:#float align:#right offset:[4,0]
		checkbox oPARotLimitCheckbox "Limit Rot to 90 Deg Intervals?" checked:oPARotLimitValue align:#left
		checkbox oPAScaleUniCheckbox "Scale Uniformly?" checked:oPAScaleUniValue align:#left
		label flipLabel "Flip:" across:4
		checkbox oPAFlipXCheckbox "X" checked:oPAFlipXValue
		checkbox oPAFlipYCheckbox "Y" checked:oPAFlipYValue
		checkbox oPAFlipZCheckbox "Z" checked:oPAFlipZValue
		
		on oPAPositionCheckbox changed state do 
			(
			oPAPositionValue = state
			oPAMinXPosSpinner.enabled = state
			oPAMaxXPosSpinner.enabled = state
			oPAMinYPosSpinner.enabled = state
			oPAMaxYPosSpinner.enabled = state
			oPAMinZPosSpinner.enabled = state
			oPAMaxZPosSpinner.enabled = state
			)
		on oPAMinXPosSpinner changed val do oPAMinXPosValue = val
		on oPAMaxXPosSpinner changed val do oPAMaxXPosValue = val
		on oPAMinYPosSpinner changed val do oPAMinYPosValue = val
		on oPAMaxYPosSpinner changed val do oPAMaxYPosValue = val
		on oPAMinZPosSpinner changed val do oPAMinZPosValue = val
		on oPAMaxZPosSpinner changed val do oPAMaxZPosValue = val

		on oPARotationCheckbox changed state do 
			(
			oPARotationValue = state
			oPAMinXRotSpinner.enabled = state
			oPAMaxXRotSpinner.enabled = state
			oPAMinYRotSpinner.enabled = state
			oPAMaxYRotSpinner.enabled = state
			oPAMinZRotSpinner.enabled = state
			oPAMaxZRotSpinner.enabled = state
			)
		on oPAMinXRotSpinner changed val do oPAMinXRotValue = val
		on oPAMaxXRotSpinner changed val do oPAMaxXRotValue = val
		on oPAMinYRotSpinner changed val do oPAMinYRotValue = val
		on oPAMaxYRotSpinner changed val do oPAMaxYRotValue = val
		on oPAMinZRotSpinner changed val do oPAMinZRotValue = val
		on oPAMaxZRotSpinner changed val do oPAMaxZRotValue = val

		on oPAScaleCheckbox changed state do 
			(
			oPAScaleValue = state
			if state == true then
				(
				oPAScaleUniCheckbox.enabled = true
				if oPAScaleUniCheckbox.checked == true then
					(
					oPAMinXScaleSpinner.caption = "Min:"
					oPAMaxXScaleSpinner.caption = "Max:"
					oPAMinXScaleSpinner.enabled = true
					oPAMaxXScaleSpinner.enabled = true
					oPAMinYScaleSpinner.enabled = false
					oPAMaxYScaleSpinner.enabled = false
					oPAMinZScaleSpinner.enabled = false
					oPAMaxZScaleSpinner.enabled = false				
					)
				else 
					(
					oPAMinXScaleSpinner.caption = "Min X:"
					oPAMaxXScaleSpinner.caption = "Max X:"
					oPAMinXScaleSpinner.enabled = true
					oPAMaxXScaleSpinner.enabled = true
					oPAMinYScaleSpinner.enabled = true
					oPAMaxYScaleSpinner.enabled = true
					oPAMinZScaleSpinner.enabled = true
					oPAMaxZScaleSpinner.enabled = true				
					)
				)
			else
				(
				oPAScaleUniCheckbox.enabled = false
				if oPAScaleUniCheckbox.checked == true then
					(
					oPAMinXScaleSpinner.caption = "Min:"
					oPAMaxXScaleSpinner.caption = "Max:"
					oPAMinXScaleSpinner.enabled = false
					oPAMaxXScaleSpinner.enabled = false
					oPAMinYScaleSpinner.enabled = false
					oPAMaxYScaleSpinner.enabled = false
					oPAMinZScaleSpinner.enabled = false
					oPAMaxZScaleSpinner.enabled = false				
					)
				else 
					(
					oPAMinXScaleSpinner.caption = "Min X:"
					oPAMaxXScaleSpinner.caption = "Max X:"
					oPAMinXScaleSpinner.enabled = false
					oPAMaxXScaleSpinner.enabled = false
					oPAMinYScaleSpinner.enabled = false
					oPAMaxYScaleSpinner.enabled = false
					oPAMinZScaleSpinner.enabled = false
					oPAMaxZScaleSpinner.enabled = false				
					)
				)
			)
			
		on oPAMinXScaleSpinner changed val do oPAMinXScaleValue = val
		on oPAMaxXScaleSpinner changed val do oPAMaxXScaleValue = val
		on oPAMinYScaleSpinner changed val do oPAMinYScaleValue = val
		on oPAMaxYScaleSpinner changed val do oPAMaxYScaleValue = val
		on oPAMinZScaleSpinner changed val do oPAMinZScaleValue = val
		on oPAMaxZScaleSpinner changed val do oPAMaxZScaleValue = val
		on oPARotLimitCheckbox changed state do oPARotLimitValue = state
		on oPAScaleUniCheckbox changed state do 
			(
			oPAScaleUniValue = state
			if state == true then
				(
				oPAMinXScaleSpinner.caption = "Min:"
				oPAMaxXScaleSpinner.caption = "Max:"
				)
			else 
				(
				oPAMinXScaleSpinner.caption = "Min X:"
				oPAMaxXScaleSpinner.caption = "Max X:"
				)
			oPAMinYScaleSpinner.enabled = not state
			oPAMaxYScaleSpinner.enabled = not state
			oPAMinZScaleSpinner.enabled = not state
			oPAMaxZScaleSpinner.enabled = not state
			)
		on oPAFlipXCheckbox changed state do oPAFlipXValue = state
		on oPAFlipYCheckbox changed state do oPAFlipYValue = state
		on oPAFlipZCheckbox changed state do oPAFlipZValue = state
		
		on oPARolloutRand open do
			(
			oPAMinXPosSpinner.enabled = oPAPositionValue
			oPAMaxXPosSpinner.enabled = oPAPositionValue
			oPAMinYPosSpinner.enabled = oPAPositionValue
			oPAMaxYPosSpinner.enabled = oPAPositionValue
			oPAMinZPosSpinner.enabled = oPAPositionValue
			oPAMaxZPosSpinner.enabled = oPAPositionValue

			oPAMinXRotSpinner.enabled = oPARotationValue
			oPAMaxXRotSpinner.enabled = oPARotationValue
			oPAMinYRotSpinner.enabled = oPARotationValue
			oPAMaxYRotSpinner.enabled = oPARotationValue
			oPAMinZRotSpinner.enabled = oPARotationValue
			oPAMaxZRotSpinner.enabled = oPARotationValue

			if oPAScaleValue == true then
				(
				oPAScaleUniCheckbox.enabled = true
				if oPAScaleUniValue == true then
					(
					oPAMinXScaleSpinner.caption = "Min:"
					oPAMaxXScaleSpinner.caption = "Max:"
					oPAMinXScaleSpinner.enabled = true
					oPAMaxXScaleSpinner.enabled = true
					oPAMinYScaleSpinner.enabled = false
					oPAMaxYScaleSpinner.enabled = false
					oPAMinZScaleSpinner.enabled = false
					oPAMaxZScaleSpinner.enabled = false				
					)
				else 
					(
					oPAMinXScaleSpinner.caption = "Min X:"
					oPAMaxXScaleSpinner.caption = "Max X:"
					oPAMinXScaleSpinner.enabled = true
					oPAMaxXScaleSpinner.enabled = true
					oPAMinYScaleSpinner.enabled = true
					oPAMaxYScaleSpinner.enabled = true
					oPAMinZScaleSpinner.enabled = true
					oPAMaxZScaleSpinner.enabled = true				
					)
				)
			else
				(
				oPAScaleUniCheckbox.enabled = false
				if oPAScaleUniValue == true then
					(
					oPAMinXScaleSpinner.caption = "Min:"
					oPAMaxXScaleSpinner.caption = "Max:"
					oPAMinXScaleSpinner.enabled = false
					oPAMaxXScaleSpinner.enabled = false
					oPAMinYScaleSpinner.enabled = false
					oPAMaxYScaleSpinner.enabled = false
					oPAMinZScaleSpinner.enabled = false
					oPAMaxZScaleSpinner.enabled = false				
					)
				else 
					(
					oPAMinXScaleSpinner.caption = "Min X:"
					oPAMaxXScaleSpinner.caption = "Max X:"
					oPAMinXScaleSpinner.enabled = false
					oPAMaxXScaleSpinner.enabled = false
					oPAMinYScaleSpinner.enabled = false
					oPAMaxYScaleSpinner.enabled = false
					oPAMinZScaleSpinner.enabled = false
					oPAMaxZScaleSpinner.enabled = false				
					)
				)
			)
		)
		
	rollout oPARolloutTools "Tools"
		(
		dropdownlist oPAModeDropdown items:#("Brush", "Place", "Straight Line") width:100 align:#center selection:oPAModeValue
		on oPAModeDropdown selected i do oPAModeValue = i
		
		checkbutton oPAOnOrOffButton "Paint" checked:false align:#center width:150
		on oPAOnOrOffButton changed state do 
			(
			if state == false then 
				(
				oPAOnOrOffButton.text = "Paint"
				thePainterInterface.endPaintSession()
				)
			else 
				(
				-- are you creating geometry on a hidden layer?
				if oPAOriginalLayerValue == false and LayerManager.current.isHidden == true then 
					(
					Messagebox "Active Layer is hidden, please unhide so you can see your newly created objects, or make an unhidden layer active." title:"objectPainter"
					oPAOnOrOffButton.checked = false
					)
				else
					(
					if oPAPaintWithList.count == 0 then
						(
						MessageBox "Please add objects to the 'Paint With' List" title:"objectPainter"
						oPAOnOrOffButton.checked = false
						)
					else
						(
						if (oPAMinXRotValue > oPAMaxXRotValue) or (oPAMinYRotValue > oPAMaxYRotValue) or (oPAMinZRotValue > oPAMaxZRotValue) then
							(
							MessageBox "Your random rotation min values are larger than your max values. Please fix this before proceeding." title:"objectPainter"
							oPAOnOrOffButton.checked = false
							)
						else
							(
							oPAOnOrOffButton.text = "Stop Paint"
							thePainterInterface.endPaintSession()
							oPALastPaintWithObjs = #()
							thePainterInterface.ScriptFunctions oPAstartStroke oPApaintStroke oPAendStroke oPAcancelStroke oPAsystemEnd
	
							if oPAOnAllObjsValue == false then oPAPaintOnObjList = for i in oPAPaintOnList collect (getNodeByName i)
							else oPAPaintOnObjList = $*

							thePainterInterface.initializeNodes 0 oPAPaintOnObjList
							thePainterInterface.startPaintSession()
							)
						)
					)
				)
			)
			
		button oPAHelpButton "Help" width:50 toolTip:"Help" pos:[45,63]
		on oPAHelpButton pressed do oPAHelp()
		button oPASaveDefButton "SaveDef" width:50 toolTip:"Save Current Settings as Default" pos:[100,63]
		on oPASaveDefButton pressed do oPASaveDef()
		)
	)
)
-------------------------------------------------------------------------------