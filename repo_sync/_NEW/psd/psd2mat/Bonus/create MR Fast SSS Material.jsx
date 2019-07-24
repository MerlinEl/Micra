// creates VRay Map Layers ...
theLayerNames =  new Array("Bump", "Ambient", "Overall Diffuse Color", "Unscattered Diffuse Color", "Unscattered Diffuse Weight", "Front Surface Scatter Color", "Front Surface Scatter Weight", "Front Surface Scatter Radius", "Back Surface Scatter Color", "Back Surface Scatter Weight", "Back Surface Scatter Radius", "Back Surface Scatter Depth", "Specular Color", "Shininess", "Scale Conversion Falloff", "Falloff Strenght")
function createDocument () {
	theAnswer = true
	try {
		var docRef = app.activeDocument;
		theAnswer = confirm("Add MR Fast SSS Map Layers to the current document ?")
	}catch(someError){
	 	docRef = app.documents.add(new UnitValue (512, "px"), new UnitValue (512, "px"), 72)
	}
	if(theAnswer){
		for (i = theLayerNames.length - 1; i >= 0; i--) {
			theLayer = docRef.artLayers.add()
			theLayer.name = theLayerNames[i]
		}
	}
}

createDocument ()
