<void>GetSelectionFromFace()

gco.fit() --zoom all
gco.fitSelected() --zoom selection
 
<void><Unwrap_UVW>.getArea <bitArray>faceSelection <&float>x <&float>y <&float>width <&float>height <&float>areaUVW <&float>areaGeom 

x is Out parameter 
y is Out parameter 
width is Out parameter 
height is Out parameter 
areaUVW is Out parameter 
areaGeom is Out parameter 


unwrapMod.getAreaByNode first_element &areaUVW &areaGeom  $


gco.NumberVertices() 
gco.numberPolygons()
gco.selectFaces #{1}


point3><Unwrap_UVW>.getSelCenter()

$.unwrap_uvw.unwrap.weldSelected()

$.unwrap_uvw.unwrap.getWeldThresold()

$.unwrap_uvw.unwrap.setWeldThreshold 0.0001

showinterface $.unwrap_uvw.unwrap
/*
  Interface: unwrap
   Properties:
   Methods:
    <void>planarMap()
    <void>save()
    <void>load()
    <void>reset()
    <void>edit()
    <void>setMapChannel <integer>mapChannel
    <integer>getMapChannel()
    <void>setProjectionType <integer>mapChannel
    <integer>getProjectionType()
    <void>setVC <boolean>vertexColor
    <boolean>getVC()
    <void>move()
    <void>moveh()
    <void>movev()
    <void>rotate()
    <void>scale()
    <void>scaleh()
    <void>scalev()
    <void>mirrorH()
    <void>mirrorV()
    <void>expandSelection()
    <void>contractSelection()
    <void>setFalloffType <integer>falloffType
    <integer>getFalloffType()
    <void>setFalloffSpace <integer>falloffSpace
    <integer>getFalloffSpace()
    <void>setFalloffDist <float>falloffDist
    <float>getFalloffDist()
    <void>breakSelected()
    <void>weld()
    <void>weldSelected()
    <void>updateMap()
    <void>DisplayMap <boolean>displayMap
    <boolean>IsMapDisplayed()
    <void>setUVSpace <integer>UVSpace
    <integer>getUVSpace()
    <void>options()
    <void>lock()
    <void>hide()
    <void>unhide()
    <void>freeze()
    <void>unfreeze()
    <void>filterselected()
    <void>pan()
    <void>zoom()
    <void>zoomRegion()
    <void>fit()
    <void>fitselected()
    <void>snap()
    <integer>getCurrentMap()
    <void>setCurrentMap <integer>map
    <integer>numberMaps()
    <point3>getLineColor()
    <void>setLineColor <point3>color
    <point3>getSelectionColor()
    <void>setSelectionColor <point3>color
    <integer>getRenderWidth()
    <void>setRenderWidth <integer>width
    <integer>getRenderHeight()
    <void>setRenderHeight <integer>height
    <boolean>getUseBitmapRes()
    <void>setUseBitmapRes <boolean>useRes
    <float>getWeldThreshold()
    <void>setWeldThreshold <float>height
    <boolean>getConstantUpdate()
    <void>setConstantUpdate <boolean>update
    <boolean>getShowSelectedVertices()
    <void>setShowSelectedVertices <boolean>show
    <boolean>getMidPixelSnap()
    <void>setMidPixelSnap <boolean>snap
    <integer>getMatID()
    <void>setMatID <integer>matid
    <integer>numberMatIDs()
    <bitArray>getSelectedVertices()
    <void>selectVertices <bitArray>selection
    <boolean>isVertexSelected <integer>index
    <void>MoveSelectedVertices <point3>offset
    <void>RotateSelectedVerticesCenter <float>angle
    <void>RotateSelectedVertices <float>angle <point3>axis
    <void>ScaleSelectedVerticesCenter <float>scale <integer>dir
    <void>ScaleSelectedVertices <float>scale <integer>dir <point3>axis
    <point3>GetVertexPosition <time>time <integer>index
    <integer>numberVertices()
    <void>moveX <float>p
    <void>moveY <float>p
    <void>moveZ <float>p
    <bitArray>getSelectedPolygons()
    <void>selectPolygons <bitArray>selection
    <boolean>isPolygonSelected <integer>index
    <integer>numberPolygons()
    <void>detachEdgeVertices()
    <void>flipHorizontal()
    <void>flipVertical()
    <boolean>getLockAspect()
    <void>setLockAspect <boolean>aspect
    <float>getMapScale()
    <void>setMapScale <float>scale
    <void>getSelectionFromFace()
    <void>forceUpdate <boolean>update
    <void>zoomToGizmo <boolean>all
    <void>setVertexPosition <time>time <integer>index <point3>pos
    <void>markAsDead <integer>index
    <integer>numberPointsInFace <integer>index
    <integer>getVertexIndexFromFace <integer>faceIndex <integer>ithVertex
    <integer>getHandleIndexFromFace <integer>faceIndex <integer>ithVertex
    <integer>getInteriorIndexFromFace <integer>faceIndex <integer>ithVertex
    <integer>getVertexGeomIndexFromFace <integer>faceIndex <integer>ithVertex
    <integer>getHandleGeomIndexFromFace <integer>faceIndex <integer>ithVertex
    <integer>getInteriorGeomIndexFromFace <integer>faceIndex <integer>ithVertex
    <void>setFaceVertex <point3>pos <integer>faceIndex <integer>ithVertex <boolean>sel
    <void>setFaceHandle <point3>pos <integer>faceIndex <integer>ithVertex <boolean>sel
    <void>setFaceInterior <point3>pos <integer>faceIndex <integer>ithVertex <boolean>sel
    <void>setFaceVertexIndex <integer>faceIndex <integer>ithVertex <integer>vertexIndex
    <void>setFaceHandleIndex <integer>faceIndex <integer>ithVertex <integer>vertexIndex
    <void>setFaceInteriorIndex <integer>faceIndex <integer>ithVertex <integer>vertexIndex
    <void>updateView()
    <void>getFaceSelectionFromStack()
   Actions:
  */