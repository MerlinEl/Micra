la=LayerManager.newLayer()
la.setName (uniqueName "Pivot Planter Tmp")
la.ishidden = false
la.addNode (selection as array)[1]
clearSelection()
la.select true
delete selection
LayerManager.deleteLayerByName la.name





  Interface: LayerManager
   Properties:
    .count : integer : Read
    .current : Interface : Read
   Methods:
    <Interface>getLayer <integer>which
    <Interface>newLayer()
    <Interface>getLayerFromName <string>name
    <Interface>newLayerFromName <string>name
    <void>editLayerByName <string>name
    <boolean>deleteLayerByName <string>name
    <void>closeDialog()
    <boolean>isDialogOpen()
       isDialogOpen - no automatic redraw after invoked
   Actions:


LayerManager.count --layers count
(LayerManager.getLayer 5).addnode $ -- ad node to layer
(LayerManager.getLayer 5).current = true --active layer


s=$ --Create a sphere, store in variable
s2=$
layer = layermanager.getlayer 0 --get default Layer 0
layerRT = layer.layerAsRefTarg --get layer as RefTarget
dep=refs.dependents layerRT --see the dependents
refs.dependson s

dep.count
dep[4]

theNode.INodeLayerProperties.layer.isHidden

nnode_layer = $.INodeLayerProperties.layer
nnode_layer.addnode $




---ClearEmptyLayers
---"LoneRobot"
(
DeletedLayerCount = 0
local deflayer = layermanager.getlayer 0
deflayer.current = true
for i = Layermanager.count-1 to 1 by-1 do
    (
        layer = layermanager.getLayer i
        local thislayername = layer.name
        layer.nodes &theNodes
        if thenodes.count== 0 then (LayerManager.deleteLayerbyname thislayername;DeletedLayerCount +=1)
    )
    if not DeletedLayerCount == 0 then Messagebox ("Number of layers removed - " + DeletedLayerCount as string) title:"Layer Manager"
)
