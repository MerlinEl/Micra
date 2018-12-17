--    includes two max modifiers, for attaching and exporting mount nodes to xml format.
--    I give you this code in the hopes that it is usefull. Public Domain 
--    todo : add undo support :) add remove from scene support (delete object by keyboard)
--    hopefully all usefull changes end up here.
--    Filename: MountNodes.ms
 
plugin Modifier MountNode
    name:"MountNode"
    category:"Ogre"
    classID:#(0xBBADF00D, 0xCBADF00D)
    version:1
    initialRollupState:0x01
(
    parameters ExportOptions rollout:MountNodeObjectRollout
    (
        exportThis type:#boolean ui:cbet default:true
    )
 
    rollout MountNodeObjectRollout "Common Settings"
    (
        checkbox cbet "Export this entity" enabled:true checked:true
 
        label parLabel "Parent: None" align:#left
        button btnSelParent "Select Parent" width:90 height:30 align:#center
        button btnDelNode "Delete this Node" width:90 height:30 align:#center
 
        on MountNodeObjectRollout open do
        (
            if selection[1].parent != undefined then
                parLabel.text = "Parent: " + selection[1].parent.name
        )
        on btnSelParent pressed do
        (
            if(selection[1].parent != undefined) then
                select selection[1].parent
        )
        on btnDelNode pressed do
        (
            val = queryBox("Delete MountNode?");
            if(val == false) then --???
                return;
 
            format "Deleting this node %\n" selection[1].name
            obj = selection[1]
            select obj.parent
 
            obj.parent.MountNodeSet.removeNodeNamed obj.name        
        )
    )    
    on attachedToNode theNode do 
    (
        format "added MountNode to %" theNode.name
    )    
    on detachedFromNode theNode do     
    (
        format "removing MountNode, attempting to detach from parent.. this does not seem to work..\n"
        theNode.parent.MountNodeSet.removeNodeNamed theNode.name
    )
    on deleted do 
    (
        format "scene deleted MountNode\n"
    )
    on load do
    (
        format "Loading MountNode Modifier..\n"
    )
)
 
plugin Modifier MountNodeSet
name:"MountNodeSet"
    category:"Ogre"
    classID:#(0xABADF00D, 0xBBADF00D)
    version:1
    initialRollupState:0x01
(
    local a_names = #();
 
    on attachedToNode theNode do 
    (
        format "MountNodeSet attached to Node"
    )    
    on detachedFromNode theNode do     
    (
        format "MountNodeSet detached to Node"
    )
    on deleted do 
    (
        format "scene deleted MountNodeSet\n"
    )
 
    parameters ExportOptions rollout:rcommon
    (
        exportThis type:#boolean ui:uiExpThis default:true
        flipXY type:#boolean ui:uiFlipXY default:true
        lastFile type:#string
    )
 
    parameters ExportOptions rollout:rnodes
    (
        anames type:#stringTab tabSizeVariable:true
        aboxes type:#nodeTab tabSizeVariable:true
    )    
    rollout rcommon "Common Settings"
    (
        checkbox uiExpThis "Export this entity" enabled:true checked:true
        checkbox uiFlipXY "Flip X/Y" enabled:true checked:true
    )    
    on load do
    (
        format "Loading MountNodeSet Modifier..\n"
        a_names = #();
        for str in anames do
        (
            append a_names str
            format "MountNode found %\n" str
        )
    )    
    fn findIndex name =
    (
        for i = 1 to a_names.count do 
        (
            if a_names[i] == name then
                return i
        )
    )
    fn removeNode index = 
    (
        if ((a_names.count >= index) and (index > 0)) then
        (
            ind = index
            deleteItem a_names ind
            deleteItem anames ind
 
            box = aboxes[ind]
            delete box
 
            deleteItem aboxes ind
 
            max motion mode
            max modify mode        
        )        
    )
    fn removeNodeNamed name =
    (
        index = findIndex name
        removeNode index
    )    
    fn findMountMod obj = 
    (
        local mntMod = 0;
        for mod in obj.modifiers do
        (
            if (mod.name == "MountNodeSet") then
            (
                mntMod = mod;
                break;
            )
        )
 
        mntMod
    )
    fn findObjParent obj =
    (
        local objtmp = obj.parent;
        local last = 0;
        while (objtmp != undefined) do
        (
            last = objtmp
            objtmp = objtmp.parent
        )
 
        last
    )    
    fn getObjParentId array obj =
    (
        local index = 1;
        local found = false;
        local newarray = #();
 
        for i = 1 to array.count do 
        (
            index = i;
            nobj = array[i][1];
 
            if(nobj.parent != undefined) then
                pobj = findObjParent nobj
            else
                pobj = nobj
 
            if(obj.name == pobj.name) then
            (
                found = true;
                break;
            )
        )
 
        if(found == false) then
        (
            append array newarray
 
            index = array.count
        )
        index
    )    
      fn recurseSceneNodes scene = 
    (    
        local tmpList = #();
 
        for obj in objects do -- ALL OBJECTS IN SCENE
        (
            if (obj != undefined) then
            (
                for mod in obj.modifiers do
                (
                    if (mod.name == "MountNodeSet") then
                    (
                    --    format "Found MountNodeSet Modifier: %\n\tNode Name: %\n\tNode Mounts: %\n" mod.name obj.name mod.aboxes.count
 
                        append tmpList obj
                    )
                )
            )
        )
 
        local marray = #();
 
        for i = 1 to tmpList.count do 
        (
            myobj = tmpList[i]
            if(myobj.parent != undefined) then
                listobj = findObjParent myobj
            else
                listobj = myobj            
 
            parentId = getObjParentId marray listobj
            append marray[parentId] myobj
        )
 
        marray
    )    
    fn writeMountXml outFile = 
    (
        format "Enumerating Scene Nodes...\n"
        marray = recurseSceneNodes "SomeStuff"
 
        local list = #();
 
        if(marray.count > 1) then
            format "Error, too many heirarchies, will only write one file.. (the last heirarchy will be used..)"
 
        for i = 1 to marray.count do
        (
            list = marray[i];
 
            if(list[1].parent != undefined) then
                parentObj = findObjParent list[1]
            else
                parentObj = list[1]
 
            if(parentObj == undefined) then
            (
                parentObj = list[1]
 
                format "Defining parent to self, no parent assigned!\n"
            )
 
            format "Parent: %\n\tMount Modifiers: %\n" parentObj.name list.count
 
            if(list.count == 0) then
            (
                format "Error, No Mount Modifiers Found in the scene!\n"
 
                break;    
            )
 
            xmlFile        = 0
 
            local filename = #();
            filename = outFile
            xmlFile    = createFile filename
 
            if(xmlFile == undefined) then
                format "**** Error opening File: %!\n" filename
            else
                format "\tOpened File : %\n" filename
 
            format "<MountNodes Parent=\"%\">\n" parentObj.name to: xmlFile;
 
            for j = 1 to list.count do
            (
                mobj = list[j];
                format "\tLinked Object: %\n" mobj.name
 
                mntMod = findMountMod mobj
                if(mntMod == 0) then
                (
                    format "Failed to locate Mount Modifier!\n"
 
                    break;
                )
 
                format "\tMount Nodes found..\n" mntMod.aboxes.count
 
                isbone = "Mesh"
                bisBone = false
                if(mobj.boneEnable or isKindOf mobj Biped_Object or isKindOf mobj BoneGeometry or isKindOf mobj BoneObj) then
                (
                    format "% is a Bone.. adjusting accordingly....\n" mobj.name
 
                    isbone = "Bone"
                    bisBone = true
                )
                else
                (
                    format "doesnt seem to be a bone.. I bet it should be treated as one..\n"
                    par = findObjParent mobj
                    if isKindOf par Biped_Object or isKindOf par BoneGeometry then
                    (
                        format "hmm parented from bone.. lets commit some wtf'ery!!!\n"
                        isbone = "Bone"
                        bisBone = true    
                    )
                    else
                    (
                        format "guess not.. Current target system does not support mesh mount's.\n"
                    )
                )
 
                if(bisBone) then
                (
                    Tform = mobj.transform
                    pos = Tform.pos
                    rot = Tform.rotation as quat
                )
                else
                (
                    pos = mobj.position
                    rot = mobj.rotation
                )
 
                for k=1 to mntMod.aboxes.count do
                (
                    node = mntMod.aboxes[k]
 
                    format "\t\tExporting Node: %\n" node.name
                    format "\t<Node Name=\"%\" Parent=\"%\" ParentType=\"%\">\n" node.name node.parent.name isbone to: xmlFile;
 
                    npos = -(pos - node.position)
                    nrot = node.rotation
 
                    if(mntMod.flipXY) then
                    (
                        format "Flip XY enabled.. flipping now.\n"
 
                        saved  = npos.y
                        npos.y = npos.z
                        npos.z = -saved
                    )
                    format "\t\t<Position x=\"%\" y=\"%\" z=\"%\">\n" npos.x npos.y npos.z to: xmlFile;
                    format "\t\t</Position>\n" to: xmlFile;
                    format "\t\t<Rotation x=\"%\" y=\"%\" z=\"%\" w=\"%\">\n" nrot.x nrot.y nrot.z nrot.w to: xmlFile;
                    format "\t\t</Rotation>\n" to: xmlFile;
                    format "\t</Node>\n" to: xmlFile;
                )
            )
            format "</MountNodes>\n" to: xmlFile;
 
            format "Done writing %\n" filename
 
            flush xmlFile
            close xmlFile            
        )
    )           
    rollout rnodes "Mount Nodes"
    (
        group "Node List"
        (
            button btnAddNode "Add" width:60 height:30 across:2
            button btnRemNode "Remove" align:#right width:60 height:30
            combobox nodeList align:#left height:4 width:140 items:a_names
        )
        group "Features"
        (
            button btnSelectNode "Select Node" width:60 height:30 across:2
            button btnExport "Export All" width:60 height:30 across:2 align:#right
        )
 
        on btnExport pressed do
        (
            tryfile = "C:\\"
            if(lastFile != undefined) then
                tryfile=lastFile
            filename = getSaveFileName types:"Mount Node XML(*.xml)|*.xml|" filename:tryfile
 
            if(filename == undefined) then
            (
                format "filename Undefined: %\n" filename
                return false
            )
            lastFile=filename
            format "saving xml to: %\n" filename
            writeMountXml filename
        )
 
        on btnSelectNode pressed do
        (
            item = nodeList.selection
 
            if ((aboxes.count >= item) and (item > 0)) then
            (
                node = aboxes[item]
 
                select node        
            )    
        )
 
        on btnAddNode pressed do
        (
            if (nodeList.text != "") then
            (
                for i = 1 to anames.count do 
                (
                    if anames[i] == nodeList.text then
                    (
                        format "Error, this node name has already been used. [%]\n" nodeList.text;
                        return false
                    )
                )
                append a_names nodeList.text
                append anames nodeList.text
 
                node = selection[1]
 
                size = node.max-node.min/2
                if(size.x<size.y) then
                    len = size.x
                else if(size.y<size.x) then
                    len = size.y
 
                if(size.z<len) then
                    len = size.z
 
                len *=.1
 
                size.x=len
                size.y=len
                size.z=len
 
                object = box length:len width:len height:len
                object.name = nodeList.text
 
                if(len < 1) then
                    object.scale = size*.1
 
                object.pivot = object.center
 
                addModifier object (MountNode())
                object.parent = node
                object.position = node.transform.position
                append aboxes object
 
                offset = node.transform.position - object.position 
                format "Offset Distance : x: % y: % z: %\n" offset.x offset.y offset.z
 
                format "added Mount Node,\n\tName: %\n\tParent Name: %\n\tTotal Mount Nodes: %\n" nodeList.text node.name aboxes.count;
                format "\tPosition X: % Y: % Z: %\n" object.position.x object.position.y object.position.z
                format "\tRotation X: % Y: % Z: % W: %\n" object.rotation.x object.rotation.y object.rotation.z object.rotation.w
 
                select object
 
                max motion mode
                max modify mode
            )
        )
 
        on btnRemNode pressed do
        (
            val = queryBox("Delete MountNode?");
            if(val == true) then --???
                return;
 
            removeNode nodeList.selection
        )        
    )
)