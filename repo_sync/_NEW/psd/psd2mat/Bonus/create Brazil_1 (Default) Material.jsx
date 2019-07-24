// creates VRay Map Layers ...
theLayerNames =  new Array("Color (Cs)", "Opacity (Os)", "Extra Light", "Diffusion", "Bump", "Displacement", "Environment", "Ambient","Luminosity","Ka","Kd","Kl","Reflect","Kr","IOR","Highlight Color","Spec Level","Spec Gloss","Soften","Gain")
function createDocument () {
	theAnswer = true
	try {
		var docRef = app.activeDocument;
		theAnswer = confirm("Add Brazil r/s 1 Map Layers to the current document ?")
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
