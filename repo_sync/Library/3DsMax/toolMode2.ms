 fn getScreenRayAtNode obj =
    (
        screenRay = mapScreenToWorldRay mouse.pos
        finalRay = intersectRay obj screenRay
        finalRay
    )

fn placeMarkersOnSurface =
(
    tool surfacePoints
    (
        local obj = getCurrentSelection()
        local m = point size:60 centermarker:false axistripod:false cross:false box:true wirecolor:red
        local pointArray = #()
        
        on start do
        (
            if obj.count == 1 and obj != undefined then
            (
                obj = obj[1]
            )
            else #stop
        )
        
        on freeMove do
        (
            local ir = getScreenRayAtNode obj
            
            if ir != undefined then
            (
                m.pos = ir.pos
                m.dir = ir.dir
                redrawViews()
            )
        )
        
        on mouseMove clickNo do
        (
            local ir = getScreenRayAtNode obj
            
            if ir != undefined then
            (
                m.pos = ir.pos
                m.dir = ir.dir
                redrawViews()
            )
        )
        
        on mousePoint clickNo do
        (
            local ir = getScreenRayAtNode obj
            
            if ir != undefined then
            (
                local p = point pos:ir.pos dir:ir.dir size:40 centermarker:false axistripod:false cross:true box:false wirecolor:yellow
                append pointArray p
                m.pos = ir.pos
                m.dir = ir.dir
                
                redrawViews()
            )
        )
    
        on mouseAbort clickNo do
        (
            #stop
        )
        
        on stop do
        (
        delete m
        return pointArray
        )
    )
    
    startTool surfacePoints

) 

 placeMarkersOnSurface()