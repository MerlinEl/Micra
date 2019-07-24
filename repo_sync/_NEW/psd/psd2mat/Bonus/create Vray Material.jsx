// creates VRay Map Layers ...
theLayerNames =  new Array("Diffuse", "Reflect", "HGlossiness", "RGlossiness", "Fresnel IOR", "Refract", "Glossiness", "IOR", "Translucent", "Bump", "Displace", "Opacity", "Environment")
function createDocument () {
	theAnswer = true
	try {
		var docRef = app.activeDocument;
		theAnswer = confirm("Add VRay Map Layers to the current document ?")
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
