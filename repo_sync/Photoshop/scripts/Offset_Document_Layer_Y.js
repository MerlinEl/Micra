function offsetDocumentLayer () {

	var doc = activeDocument;
	var scriptName = "Offset Document Layer v0.1 by MerlinEl";
	var csText = scriptName + "\r";
	if (doc == undefined) {
		
		alert(csText + "Error: No Documents Open");
		return false
	}
	if (doc.activeLayer == undefined) {
		
		alert(csText + "Error: No Layer Selected");
		return false
	}
	var offset_y = doc.height / 2
	doc.activeLayer.applyOffset(0, offset_y, OffsetUndefinedAreas.WRAPAROUND);
}
offsetDocumentLayer()

//doc.activeLayer.bounds;
//doc.activeLayer.translate(-10,-20);