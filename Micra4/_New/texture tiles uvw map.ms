$.setMaterialIndex 53 1
mo = uvwMap maptype:0 mapChannel:1 realWorldMapSize:false name:"Pavement" 
modPanel.addModToSelection mo -- Add UVW Map Modifier to selection
mo.axis = 2
mo.utile = 14
mo.vtile = 32
maxOps.CollapseNodeTo $ 1 true

$.setMaterialIndex 140 1
mo = uvwMap maptype:0 mapChannel:1 realWorldMapSize:false name:"Grass" 
modPanel.addModToSelection mo -- Add UVW Map Modifier to selection 
mo.axis = 2
mo.utile = 30
mo.vtile = 60
convertToPoly $