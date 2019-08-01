// Offset All Visible Layers V1.1 PS 7 Version
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

// Do cropping for proper offset?
var doCrop = true;
//var doCrop = false;


// 0.5 for half of the width
var defaultXoffset = 0.5; // amount of horizontal shift, where 1.0 is document width. 0 for none.
var defaultYoffset = 0.5; // amount of vertical shift, where 1.0 is document height. 0 for none.

// Do not mess with the Rest!


// debug level: 0-2 (0:disable, 1:break on error, 2:break at beginning)
// $.level = 0;
// debugger; // launch debugger on next line

var scriptName = "Offset Layers V1.1 by www.hesido.com";
//var csText = "";
var csText = scriptName + "\r";


if (!documents.length > 0) {    // Alert if no document is open, else run the script
	alert(csText + "Error: No Documents Open");
}
else {

	var docRef = activeDocument;
	var errors = 0;


	var initialRulerUnits = preferences.rulerUnits;
	preferences.rulerUnits = Units.PIXELS;

	var XoffsetAmount = docRef.width * defaultXoffset; 
	var YoffsetAmount = docRef.height * defaultYoffset; 



	if (userInteraction == true) {
		if (!cropWarning || !doCrop || confirm(csText + "This script will auto-crop WHOLE document, anything outside visible canvas area will be lost, still continue?")) {
			var doX = confirm( csText + "Offset document horizontally " + defaultXoffset + " times of document width? Cancel for no offset)" );
			var doY = confirm( csText + "Offset document horizontally " + defaultXoffset + " times of document height? Cancel for no offset)" );
			if (!doX) {XoffsetAmount = 0;}
			if (!doY) {YoffsetAmount = 0;}
		} else { 
			XoffsetAmount = 0;
			YoffsetAmount = 0;			
		}

	}


	
	

	var layersToFilter = new Array ("LayerKind.TEXT", "LayerKind.SMARTOBJECT", "Vector");

	
	var textLayers = 0;
	var goForIt = true;
	if (!(XoffsetAmount == 0 && YoffsetAmount == 0) && goForIt == true) {
		doit()
	}
	
}

function doit() {
	if (doCrop) {
		prepareDocument();
	}
	layerList = grabAllLayers(docRef,true,true,"",layersToFilter);
/*	if (layerList.outOfBounds > 0) {
	goForIt = confirm("There is/are " +layerList.outOfBounds+" visible layer(s) that has pixels outside visible part of Canvas\rThese cannot be properly offset.\rYou can press YES to crop&fix *whole* document, or NO to cancel the operation.", false, scriptName);
		if (goForIt == true) {
			if (cropWarning == true) {
				alert(csText + "Warning: Portions of layers that is outside canvas area will be clipped",scriptName)
			}
			prepareDocument()
		}
	} */
	if (textLayers > 0 && warnForRasterize == true && goForIt) {
	goForIt = confirm("Reminder: Text and vector layers cannot be offset even if visible.\rThere is/are at least " +textLayers+" such layer(s). Still continue?");
	}
	

	if (goForIt == true) {
		offsetLayers(XoffsetAmount, YoffsetAmount, layerList);
	}
	
	preferences.rulerUnits = initialRulerUnits;
	docRef = null;
}

function offsetLayers(offsetX, offsetY, layerList) {

for (var i=0; i<layerList.length; i++) {

try {

	if (layerList[i].visible) {
		layerList[i].applyOffset(offsetX, offsetY, OffsetUndefinedAreas.WRAPAROUND);
	} 

}
catch(e) {

errors++;

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
	} else 
{

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
			if (layersal[i].kind != 2) {
				var lastelement = arrayLocal.push(layersal[i]);
				if (arrayLocal[arrayLocal.length-1].name == layerNameToFind) {
					arrayLocal.lposition = arrayLocal.length-1;
				}
			} else {
				textLayers++;
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
			var dummy = grabLayerSetContent(layersal[i].layers, onlyVisible, artLayersOnly, layerNameToFind, filter, false);
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

function grabLayerSetContent(layersal,onlyVisible,artLayersOnly,layerNameToFind,filter,firstCall) {


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
			if (layersal[i].kind != 2) {
				var lastelement = arrayLocal.push(layersal[i]);
				if (arrayLocal[arrayLocal.length-1].name == layerNameToFind) {
					arrayLocal.lposition = arrayLocal.length-1;
				}
			} else {
				textLayers++;
			}
		}

	}

	return arrayLocal;
}

