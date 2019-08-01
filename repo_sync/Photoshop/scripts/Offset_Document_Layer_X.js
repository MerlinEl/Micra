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
	var offset_x = doc.width / 2
	doc.activeLayer.applyOffset(offset_x, 0, OffsetUndefinedAreas.WRAPAROUND);
}
offsetDocumentLayer()

//doc.activeLayer.bounds;
//doc.activeLayer.translate(-10,-20);