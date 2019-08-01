// Offset All Visible Layers V1.1 CS2 Version
// Script By Hesido
// Copyright 2005 Emrah BASKAYA - www.hesido.com.  All rights reserved.

// This script is freely redistributable as long its contents and copyright
// notice is not changed.
// All modified scripts based on this should acknowledge www.hesido.com
// as the original script writer.
// PLEASE MAKE SURE YOU HAVE A BACKUP OF YOUR WORK BEFORE RUNNING THIS!
// Emrah BASKAYA cannot be held responsible for any loss of data due
// to the use of this script. USE AT YOUR OWN RISK!

/*
This Script is provided "as is" without warranties of any kind,
either expressed or implied, including, but not limited to, the implied
warranties of merchantability and fitness for a particular purpose. The 
entire risk as to the quality and performance of the script is with you.
Should the script prove defective, you assume the cost of all necessary
servicing, repair or correction. In no event will any copyright holder be
liable to you for damages, including any general, special, incidental or
consequential damages arising out of the use or inability to use the script
(including but not limited to loss of data or data being rendered inaccurate
or losses sustained by you or third parties or a failure of the script to
operate with any other programs).
*/

// To disable the rasterize warning, activate the second line by removing dashes.
var warnForRasterize = true;
//var warnForRasterize = false;

// To disable the user interaction, activate the second line by removing dashes.
var userInteraction = true;
//var userInteraction = false;

// To disable the crop warning at the beginning, activate the second line by removing dashes.
var cropWarning = true;
//var cropWarning = false;


// 0.5 for half of the width
var defaultXoffset = 0.5; // amount of horizontal shift, where 1.0 is document width. 0 for none.
var defaultYoffset = 0.5; // amount of vertical shift, where 1.0 is document height. 0 for none.

// Do not mess with the Rest!

// enable double clicking from the Macintosh Finder or the Windows Explorer
#target photoshop

// in case we double clicked the file
app.bringToFront();

// debug level: 0-2 (0:disable, 1:break on error, 2:break at beginning)
// $.level = 0;
// debugger; // launch debugger on next line

var scriptName = "Offset All Visible Layers Script V1.1 by www.hesido.com";
var csText = "";
//var csText = scriptName + "\r\r";


if (!app.documents.length > 0) {    // Alert if no document is open, else run the script
	alert(csText + "Error: No Documents Open",scriptName);
}
else {

	var docRef = app.activeDocument;

	var initialRulerUnits = app.preferences.rulerUnits;
	app.preferences.rulerUnits = Units.PIXELS;

	var XoffsetAmount = docRef.width * defaultXoffset; 
	var YoffsetAmount = docRef.height * defaultYoffset; 

	if (userInteraction == true) {
		XoffsetAmount = prompt(csText + "Enter X Offset Amount (Defaults to " + defaultXoffset + " times of document width)", XoffsetAmount, scriptName); 
		if (XoffsetAmount != null) {
			YoffsetAmount = prompt(csText + "Enter Y Offset Amount (Defaults to " + defaultYoffset + " times of document height)", YoffsetAmount, scriptName); 
		}
	}
	
	
//	prepareDocument();

	var layersToFilter = new Array ("LayerKind.TEXT", "LayerKind.SMARTOBJECT", "Vector");
//	var layersToFilter = new Array () -> change to this if you want the script to attempt to rasterize text and smartobject layers automatically


	var goForIt = true;

	if ((XoffsetAmount != null && YoffsetAmount != null) && goForIt == true) {
		doit()
	}
	
}

function doit() {

	layerList = grabAllLayers(docRef,true,true,"",layersToFilter);
	if (layerList.outOfBounds > 0) {
	goForIt = confirm("There is/are " +layerList.outOfBounds+" visible layer(s) that has pixels outside visible part of Canvas\rThese cannot be properly offset.\rYou can press YES to crop&fix *whole* document, or NO to cancel the operation.", false, scriptName);
		if (goForIt == true) {
			if (cropWarning == true) {
				alert(csText + "Warning: Portions of layers that is outside canvas area will be clipped",scriptName)
			}
			prepareDocument()
		}
	}
	if (layerList.filtered > 0 && warnForRasterize == true && goForIt) {
	goForIt = confirm("Reminder: Text Layers and vector layers need to be rasterized or otherwise they will NOT be offset even when visible.\r\rThere is/are at least " +layerList.filtered+" such layer(s). Still continue?", false, scriptName);
	}
	

	if (goForIt == true) {
		offsetLayers(XoffsetAmount, YoffsetAmount, layerList);
	}
	
	app.preferences.rulerUnits = initialRulerUnits;
	docRef = null;
}

function offsetLayers(offsetX, offsetY, layerList) {

for (var i=0; i<layerList.length; i++) {

	if (layerList[i].visible && layerList[i].bounds[2] > 0) {
		layerList[i].applyOffset(offsetX, offsetY, OffsetUndefinedAreas.WRAPAROUND);
	} 
}

}

function prepareDocument() {
	docRef.selection.selectAll();
	var id1094 = charIDToTypeID( "Crop" );
    var desc238 = new ActionDescriptor();
	executeAction( id1094, desc238, DialogModes.NO );
	docRef.selection.deselect();
	}

function grabAllLayers(layersal,onlyVisible,artLayersOnly,layerNameToFind,filter,firstCall) {

// set Defaults
	if (firstCall != false) {
		layersal = layersal.layers;
	}

	var jointfilter = "";
	if (typeof(filter) != "undefined")  {
	if (filter.constructor.toString().indexOf("Array") == -1) {
			var jointfilter = filter;
		} else {
			var jointfilter = filter.join();
		}
	}

	var arrayLocal = new Array();
	arrayLocal.filtered = 0;
	arrayLocal.lposition = null;
	arrayLocal.outOfBounds = 0;
	var filteredLayers = 0;

	for (var i=0; i<layersal.length; i++) {
		var processLayer = true;
		if (onlyVisible && !layersal[i].visible) {
			var processLayer = false;	
		}
		if (processLayer && layersal[i].typename == "ArtLayer") {
			if (jointfilter.indexOf(layersal[i].kind) == -1) {
				var lastelement = arrayLocal.push(layersal[i]);
				if (arrayLocal[arrayLocal.length-1].name == layerNameToFind) {
					arrayLocal.lposition = arrayLocal.length-1;
				}
				arrayLocal.outOfBounds += testForBounds(layersal[i]);
			} else {
				arrayLocal.filtered++;
			}
		}
	    if (processLayer && layersal[i].typename == "LayerSet") {
			if (artLayersOnly == false) {
				var lastelement = arrayLocal.push(layersal[i]);
				if (arrayLocal[arrayLocal.length-1].name == layerNameToFind) {
					arrayLocal.lposition = arrayLocal.length-1;
				}
			}
			var restoreL = arrayLocal.lposition;
			var preLength = arrayLocal.length;
			var dummy = grabAllLayers(layersal[i].layers, onlyVisible, artLayersOnly, layerNameToFind, filter, false);
			arrayLocal = arrayLocal.concat(dummy);
			arrayLocal.filtered += dummy.filtered;
			if (dummy.lposition != null) {
				arrayLocal.lposition = dummy.lposition+preLength;
			} else {
				arrayLocal.lposition = restoreL;
			}
		}
	}

	return arrayLocal;
}

function testForBounds(targetLayer) {
	var boundActive = targetLayer.bounds;
	var	outOfBounds = 0;
	if (boundActive[0] < 0 || boundActive[1] < 0 || boundActive[2] > docRef.width || boundActive[3] > docRef.height) {
		outOfBounds = 1;
	}
	return outOfBounds;
}

