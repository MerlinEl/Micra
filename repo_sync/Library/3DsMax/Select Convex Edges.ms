rollout rolTest "Convex Edges"
(
    button btRun "Select!" width:90 align:#center offset:[0, -2]

    function selectConvexEdges oPoly =
    (
        polyOp.setEdgeSelection oPoly #{}

        local baFaceSel = polyOp.getFaceSelection oPoly

        if ( (baFaceSel.isEmpty == true) or (subObjectLevel == 0) or (subObjectLevel == undefined) ) do
            baFaceSel = #{1..(polyOp.getNumFaces oPoly)}

        local baVertSet = polyOp.getVertsUsedOnlyByFaces oPoly baFaceSel
        local baEdgeTest = (polyOp.getEdgesUsingVert oPoly baVertSet) - (polyOp.getOpenEdges oPoly)

        local mGetFaceNormal = polyOp.getFaceNormal
        local mGetVert = polyOp.getVert

        local iNumFaces = polyOp.getNumFaces oPoly
        local ap3FaceNormals = for i = 1 to iNumFaces collect (mGetFaceNormal oPoly i)

        local iNumVerts = polyOp.getNumVerts oPoly
        local ap3VertPos = for i = 1 to iNumVerts collect (mGetVert oPoly i)

        local baConvexEdges = #{}

        local aiVerts = #()
        local aiFaces = #()

        local p3EdgeNorm = [0,0,0]
        local p3Cross = [0,0,0]

        for iEdge in baEdgeTest do
        (
            aiVerts = polyOp.getEdgeVerts oPoly iEdge
            aiFaces = polyOp.getEdgeFaces oPoly iEdge

            p3EdgeNorm = normalize(ap3VertPos[aiVerts[2]] - ap3VertPos[aiVerts[1]])
            p3Cross = cross ap3FaceNormals[aiFaces[1]] p3EdgeNorm

            if (dot p3Cross (ap3FaceNormals[aiFaces[2]]) < 0) do
                baConvexEdges[iEdge] = true
        )

        setCommandPanelTaskMode #modify
        subObjectLevel = 2
        polyOp.setEdgeSelection oPoly baConvexEdges
        forceCompleteRedraw()
    )

    on btRun pressed do
    (
        if ( (selection.count == 1) and ( (classOf selection[1]) == Editable_Poly) ) do
            selectConvexEdges selection[1]
    )

) -- End Rollout

createDialog rolTest 96 27 style:#(#style_toolwindow, #style_border, #style_sysmenu)