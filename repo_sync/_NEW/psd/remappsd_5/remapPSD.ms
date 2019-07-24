/*******************************************************************

NAME: REMAP_PSD
Author: David Shelton
version: 0.7

Version history
++
[0.1]
02.12.2011  First release
++
[0.2]
03.12.2011 Bugfixes.
	- fixed problem with too long layernames (more than 31 characters)
	- fixed error when trying to clear an adjustment layer
	- fixed error caused by slashes in layernames
	- fixed spelling error in messagebox
++
[0.3]
04.07.2012 Bugfixes
	- fixed problem where sometimes automatic uvs would be applied
++
[0.4]
2012-07-06
    - fixed problem where projection was turned off and automatic unwrap got applied.
++
[0.5]
03.04.2013
	- added support for CS6
	- fixed issues with empty layers
	- cleaned photoshop history
	- fixed issue with wrong settings in RTT dialog
	- fixed issue with forwardslashes
	- improved general stability
	
[0.6]
30.04.2013
	- fixed error with render to texture dialog not opened
	
[0.7]
21.05.2013
	- removed unneccessary command and execute steps. Compatibility to 3dsmax 2012 established.
	
[0.8]
30.05.2013
	- Proper handling of premultiplied alphas (no more black halos).
	- fixed bug that occured when the baked layer's alpha was empty
	
	

******************************************************************/


macroScript remap_psd
ButtonText:"remap_psd"
category:"3dhippie"
toolTip:"remap_psd"
Icon:#("remap",1)
(


	prepare_str = "
	function select_mask ()
	{
		var idslct = charIDToTypeID( \"slct\" );
		var desc74 = new ActionDescriptor();
		var idnull = charIDToTypeID( \"null\" );
		var ref49 = new ActionReference();
		var idChnl = charIDToTypeID( \"Chnl\" );
		var idChnl = charIDToTypeID( \"Chnl\" );
		var idMsk = charIDToTypeID( \"Msk \" );
		ref49.putEnumerated( idChnl, idChnl, idMsk );
		desc74.putReference( idnull, ref49 );
		executeAction( idslct, desc74, DialogModes.NO );
	}

	function delete_mask()
	{
		var idDlt = charIDToTypeID( \"Dlt \" );
		var desc109 = new ActionDescriptor();
		var idnull = charIDToTypeID( \"null\" );
		var ref67 = new ActionReference();
		var idChnl = charIDToTypeID( \"Chnl\" );
		var idOrdn = charIDToTypeID( \"Ordn\" );
		var idTrgt = charIDToTypeID( \"Trgt\" );
		ref67.putEnumerated( idChnl, idOrdn, idTrgt );
		desc109.putReference( idnull, ref67 );
	executeAction( idDlt, desc109, DialogModes.NO );
	}

	function hasMask(layerRef) 
	{
	  var lm = true, pmd;
	  try {
				pmd = layerRef.layerMaskDensity;
				layerRef.layerMaskDensity = 50.0;
				layerRef.layerMaskDensity = pmd;
	  } catch(e) { lm = false };
	  return lm;
	}
	 
	function hasVectorMask() 
	{
	  var lvm = true, pmd;
	  try {
				pmd = doc.activeLayer.vectorMaskDensity;
				doc.activeLayer.vectorMaskDensity = 50.0;
				doc.activeLayer.vectorMaskDensity = pmd;
	  } catch(e) { lvm = false };
	  return lvm;
	};

	function seperate_masks()
	{
		try {
			select_mask()
			docRef = app.activeDocument
			docRef.selection.selectAll()
			docRef.selection.copy()
			var layername = docRef.activeLayer.name
			delete_mask()
			var layerRef = docRef.artLayers.add()
			layerRef.name = (layername.substring(0,25))+\"_MASK\"
			layerRef.blendMode = BlendMode.NORMAL
			docRef.activeLayer = layerRef
			docRef.paste()
		} catch(e) {
		; // do nothing
		}

	}

	function collect_all_layers (theSet)
	{
			var result = new Array()
			for (var i = 0; i < theSet.length; i++) 
			{
			   layerRef = theSet[i]
			   result.push(layerRef)
			   if  (layerRef.typename == \"LayerSet\") {result = result.concat(collect_all_layers (layerRef.layers))}
			}
			layerRef = null
			return result
	}
	
	function IsLayerEmpty (layer)
	{
		result = false
		try {
		if((LayerKind.TEXT == layer.kind)){ // TEXT Layer
				if(layer.textItem.contents == \"\")	result = true;
			}else{ // Other Layer
				if(  (0 == layer.bounds[2])	// width = 0
					&& (0 == layer.bounds[3])){	// height = 0
					result = true;
				}
			}
		} catch(e){
		; // do nothing
		}
		return result
	}
	


	var docRef = app.activeDocument
	var allLayers = collect_all_layers(docRef.layers)
	docRef.suspendHistory(\"Prepare for 3ds Max\",\"main()\");

	function main()
	{
		try {docRef.rasterizeAllLayers()} catch(e){;} 
		try 
		{
			for (var i = 0; i < allLayers.length; i++) 
			{
				
				layerRef_vis = allLayers[i].visible
				layerRef = allLayers[i]
				//layerRef.name = layerRef.name.replace(/\//g, 'FwdSlash')
				layerRef.name = layerRef.name.replace('/', '_')
				
				if  (layerRef.typename == \"LayerSet\")  
				{  layerRef.name = i+\"_SET_\"+\"v\"+(layerRef_vis)+\"__\"+layerRef.name   }
				else   
				{  
					if (IsLayerEmpty (layerRef) == true ){layerRef_empty = \"_xv\";} else {layerRef_empty = \"_v\";}
					layerRef.name = i+layerRef_empty+(layerRef_vis)+\"__\"+layerRef.name;
				}

				docRef.activeLayer = layerRef
				if (hasMask(layerRef) == true) { try {seperate_masks()} catch (none) {} } //layerRef.name = \"hasamask\"}
				layerRef.visible = layerRef_vis
			}
		} catch(e) {
		; // do nothing 
		}
	}	
	docRef = null
	
	"



	update_str = "
	//$.level = 2
	function place_layer ( path )
	{
		var idPlc = charIDToTypeID( \"Plc \" );
		var desc7 = new ActionDescriptor();
		var idnull = charIDToTypeID( \"null\" );
		desc7.putPath( idnull, new File( path ) );
		var idFTcs = charIDToTypeID( \"FTcs\" );
		var idQCSt = charIDToTypeID( \"QCSt\" );
		var idQcsa = charIDToTypeID( \"Qcsa\" );
		desc7.putEnumerated( idFTcs, idQCSt, idQcsa );
		var idOfst = charIDToTypeID( \"Ofst\" );
		var desc8 = new ActionDescriptor();
		var idHrzn = charIDToTypeID( \"Hrzn\" );
		var idRlt = charIDToTypeID( \"#Rlt\" );
		desc8.putUnitDouble( idHrzn, idRlt, 0.000000 );
		var idVrtc = charIDToTypeID( \"Vrtc\" );
		var idRlt = charIDToTypeID( \"#Rlt\" );
		desc8.putUnitDouble( idVrtc, idRlt, 0.000000 );
		var idOfst = charIDToTypeID( \"Ofst\" );
		desc7.putObject( idOfst, idOfst, desc8 );
		executeAction( idPlc, desc7, DialogModes.NO );
	}

	function create_mask()
	{
		var idMk = charIDToTypeID( \"Mk  \" );
		var desc57 = new ActionDescriptor();
		var idNw = charIDToTypeID( \"Nw  \" );
		var idChnl = charIDToTypeID( \"Chnl\" );
		desc57.putClass( idNw, idChnl );
		var idAt = charIDToTypeID( \"At  \" );
		var ref26 = new ActionReference();
		var idChnl = charIDToTypeID( \"Chnl\" );
		var idChnl = charIDToTypeID( \"Chnl\" );
		var idMsk = charIDToTypeID( \"Msk \" );
		ref26.putEnumerated( idChnl, idChnl, idMsk );
		desc57.putReference( idAt, ref26 );
		var idUsng = charIDToTypeID( \"Usng\" );
		var idUsrM = charIDToTypeID( \"UsrM\" );
		var idRvlS = charIDToTypeID( \"RvlS\" );
		desc57.putEnumerated( idUsng, idUsrM, idRvlS );
		executeAction( idMk, desc57, DialogModes.NO );    
	}

	function paste_mask()
	{
	var idShw = charIDToTypeID( \"Shw \" );
		var desc80 = new ActionDescriptor();
		var idnull = charIDToTypeID( \"null\" );
			var list5 = new ActionList();
				var ref44 = new ActionReference();
				var idChnl = charIDToTypeID( \"Chnl\" );
				var idOrdn = charIDToTypeID( \"Ordn\" );
				var idTrgt = charIDToTypeID( \"Trgt\" );
				ref44.putEnumerated( idChnl, idOrdn, idTrgt );
			list5.putReference( ref44 );
		desc80.putList( idnull, list5 );
	executeAction( idShw, desc80, DialogModes.NO );

	// =======================================================
	var idpast = charIDToTypeID( \"past\" );
		var desc81 = new ActionDescriptor();
		var idAntA = charIDToTypeID( \"AntA\" );
		var idAnnt = charIDToTypeID( \"Annt\" );
		var idAnno = charIDToTypeID( \"Anno\" );
		desc81.putEnumerated( idAntA, idAnnt, idAnno );
	executeAction( idpast, desc81, DialogModes.NO );

	// =======================================================
	var idHd = charIDToTypeID( \"Hd  \" );
		var desc82 = new ActionDescriptor();
		var idnull = charIDToTypeID( \"null\" );
			var list6 = new ActionList();
				var ref45 = new ActionReference();
				var idChnl = charIDToTypeID( \"Chnl\" );
				var idOrdn = charIDToTypeID( \"Ordn\" );
				var idTrgt = charIDToTypeID( \"Trgt\" );
				ref45.putEnumerated( idChnl, idOrdn, idTrgt );
			list6.putReference( ref45 );
		desc82.putList( idnull, list6 );
	executeAction( idHd, desc82, DialogModes.NO );
	}

	function select_mask_channel()
	{
		var idslct = charIDToTypeID( \"slct\" );
		var desc62 = new ActionDescriptor();
		var idnull = charIDToTypeID( \"null\" );
		var ref30 = new ActionReference();
		var idChnl = charIDToTypeID( \"Chnl\" );
		var idOrdn = charIDToTypeID( \"Ordn\" );
		var idTrgt = charIDToTypeID( \"Trgt\" );
		ref30.putEnumerated( idChnl, idOrdn, idTrgt );
		desc62.putReference( idnull, ref30 );
		var idMkVs = charIDToTypeID( \"MkVs\" );
		desc62.putBoolean( idMkVs, false );
		executeAction( idslct, desc62, DialogModes.NO );
	}

	function merge_layer ()
	{
		var idMrgtwo = charIDToTypeID( \"Mrg2\" );
		var desc9 = new ActionDescriptor();
		executeAction( idMrgtwo, desc9, DialogModes.NO );
	}

	function select_alpha()
	{
		var idsetd = charIDToTypeID( \"setd\" );
		var desc304 = new ActionDescriptor();
		var idnull = charIDToTypeID( \"null\" );
		var ref187 = new ActionReference();
		var idChnl = charIDToTypeID( \"Chnl\" );
		var idfsel = charIDToTypeID( \"fsel\" );
		ref187.putProperty( idChnl, idfsel );
		desc304.putReference( idnull, ref187 );
		var idT = charIDToTypeID( \"T   \" );
		var ref188 = new ActionReference();
		var idChnl = charIDToTypeID( \"Chnl\" );
		ref188.putName( idChnl, \"Alpha 1\" );
		desc304.putReference( idT, ref188 );
		executeAction( idsetd, desc304, DialogModes.NO );
	}

	function selectRGB()
	{
		var idslct = charIDToTypeID( \"slct\" );
		var desc306 = new ActionDescriptor();
		var idnull = charIDToTypeID( \"null\" );
		var ref190 = new ActionReference();
		var idChnl = charIDToTypeID( \"Chnl\" );
		var idChnl = charIDToTypeID( \"Chnl\" );
		var idRGB = charIDToTypeID( \"RGB \" );
		ref190.putEnumerated( idChnl, idChnl, idRGB );
		desc306.putReference( idnull, ref190 );
		executeAction( idslct, desc306, DialogModes.NO );
	}
	
	function unlockBaseLayer()
	{
		var idsetd = charIDToTypeID( \"setd\" );
		var desc82 = new ActionDescriptor();
		var idnull = charIDToTypeID( \"null\" );
		var ref77 = new ActionReference();
		var idLyr = charIDToTypeID( \"Lyr \" );
		var idBckg = charIDToTypeID( \"Bckg\" );
		ref77.putProperty( idLyr, idBckg );
		desc82.putReference( idnull, ref77 );
		var idT = charIDToTypeID( \"T   \" );
		var desc83 = new ActionDescriptor();
		var idOpct = charIDToTypeID( \"Opct\" );
		var idPrc = charIDToTypeID( \"#Prc\" );
		desc83.putUnitDouble( idOpct, idPrc, 100.000000 );
		var idMd = charIDToTypeID( \"Md  \" );
		var idBlnM = charIDToTypeID( \"BlnM\" );
		var idNrml = charIDToTypeID( \"Nrml\" );
		desc83.putEnumerated( idMd, idBlnM, idNrml );
		var idLyr = charIDToTypeID( \"Lyr \" );
		desc82.putObject( idT, idLyr, desc83 );
		executeAction( idsetd, desc82, DialogModes.NO );
	}

	function removeBlack()
	{
		var idRmvB = charIDToTypeID( \"RmvB\" );
		executeAction( idRmvB, undefined, DialogModes.NO );
	}
	
	function IsLayerEmpty (layer)
	{
		result = false
		try {
		if((LayerKind.TEXT == layer.kind)){ // TEXT Layer
				if(layer.textItem.contents == \"\")	result = true;
			}else{ // Other Layer
				if(  (0 == layer.bounds[2])	// width = 0
					&& (0 == layer.bounds[3])){	// height = 0
					result = true;
				}
			}
		} catch(e){
		; // do nothing
		}
		return result
	}

	function getFileNameWithoutExtension( filename ) 
	{
		var index = filename.lastIndexOf('.');
		var result = filename.substring(0, index)
		return result
	}

	function collect_all_layers (theSet)
	{
			var result = new Array()
			for (var i = 0; i < theSet.length; i++) 
			{
			   layerRef = theSet[i]
			   result.push(layerRef)
			   if  (layerRef.typename == \"LayerSet\") {result = result.concat(collect_all_layers (layerRef.layers))}
			}
			layerRef = null
			return result
	}
	


	var docRef = app.activeDocument
	var allLayers = collect_all_layers(docRef.layers)

	origRulerUnits = app.preferences.rulerUnits
	origTypeUnits = app.preferences.typeUnits
	origPointSize = app.preferences.pointSize

	app.preferences.rulerUnits = Units.PIXELS
	app.preferences.typeUnits = TypeUnits.PIXELS
	app.preferences.pointSize = PointType.POSTSCRIPT
			
			
	var thefolder = new Folder()
	thefolder.changePath(app.activeDocument.path.fsName+\"\\\\\"+getFileNameWithoutExtension(app.activeDocument.name)+\"\\\\\")  
	var bakedImages = thefolder.getFiles()

	var importLayerRefs = new Array(bakedImages.length)
	var selBounds = new Array(4)
	var newSel = new Array(4)
	var emptyalpha = false

	 numMasks = 0
	while (allLayers[numMasks].name.indexOf('MASK') != -1) { numMasks ++}

	docRef.suspendHistory(\"Import baked maps\",\"importLayers()\");
	docRef.suspendHistory(\"Merge Masks & rename\",\"mergeAndRename()\"); 
	
	// Import all Layers from Folder
	function importLayers() 
	{
		try 
		{
			for (var i = 0; i < bakedImages.length; i++) 
			{
				
				layerName = getFileNameWithoutExtension(bakedImages[i].displayName)
				  
				importLayerRefs[i] = app.open(bakedImages[i])
				otherImage = app.activeDocument = importLayerRefs[i] 
				
				if ((layerName.indexOf('_xvtrue') == -1) && (layerName.indexOf('_xvfalse') == -1)) 
				{
				
					if (layerName.indexOf('MASK') == -1) 	
					{
					
						unlockBaseLayer();
						try {select_alpha();} catch(e) {}
						
						emptyalpha = false;
						try {otherImage.selection.bounds[2];} catch(e) {emptyalpha = true;}
						
							
							
						if (emptyalpha == false)
						{
							selBounds = otherImage.selection.bounds;
							otherImage.selection.invert();
							otherImage.selection.clear();
							otherImage.selection.deselect();
							removeBlack ();
							otherImage.selection.selectAll(); 
						}
					}	else { 
						otherImage.selection.selectAll(); 
						selBounds = otherImage.selection.bounds;
					}
								
				
					if (emptyalpha == false)
					{
						newSel = Array(Array(selBounds[0],selBounds[1]), 
									   Array(selBounds[2],selBounds[1]), 
									   Array(selBounds[2],selBounds[3]),
									   Array(selBounds[0],selBounds[3]))
						
						
						
						otherImage.selection.copy()
						if (i == 0) 
						{
								
								if ((docRef.width != otherImage.width)||(docRef.height != otherImage.height))
								{

										var doResize = true
										var resizeWidth = otherImage.width
										var resizeHeight = otherImage.height
										
								}
						}
						
						//otherImage.activeHistoryState = otherImage.historyStates[0];
						otherImage.close(SaveOptions.DONOTSAVECHANGES);
						 
						
						if (layerName.indexOf('MASK') != -1) {layerRef = app.activeDocument.activeLayer = app.activeDocument.layers[layerName]}
						else {layerRef = app.activeDocument.activeLayer = allLayers[parseInt(layerName.substring(0,layerName.indexOf ('_')))+numMasks] }
						if (doResize == true) 
						{
							docRef.resizeImage(resizeWidth,resizeHeight)
							
						}
						
						
						if (layerRef.typename != 'LayerSet' && layerRef.kind == LayerKind.NORMAL) { layerRef.clear() }
						docRef.selection.select(newSel)
						docRef.paste()
						
					}else // special case: original layer wasn't empty but the baked one is
					{
						otherImage.close(SaveOptions.DONOTSAVECHANGES)
						layerRef = app.activeDocument.activeLayer = allLayers[parseInt(layerName.substring(0,layerName.indexOf ('_')))+numMasks]
						if (layerRef.typename != 'LayerSet' && layerRef.kind == LayerKind.NORMAL) { layerRef.clear() }
					}
					
				} // end if cont
				else
				{
					otherImage.close(SaveOptions.DONOTSAVECHANGES)
					layerRef = app.activeDocument.activeLayer = allLayers[parseInt(layerName.substring(0,layerName.indexOf ('_')))+numMasks]
					if (layerRef.typename != 'LayerSet' && layerRef.kind == LayerKind.NORMAL) { layerRef.clear() }
				}
				
				
			} // end of loop
		} catch (e) {
		; // do nothing
		}
		
	} // end of function

	// merge masks and rename
	
	function mergeAndRename()
	{
		try
		{
			for (var i = 0; i < allLayers.length; i++) 
			{
				
				layerRef = allLayers[i]
				if (layerRef.name.indexOf('vfalse') != -1) {layerRef_vis = false} else {layerRef_vis = true}
				
				if (layerRef.name.indexOf('MASK') != -1) 
				{
					app.activeDocument.activeLayer = layerRef
					layerName = layerRef.name
						   
					app.activeDocument.selection.selectAll()
					app.activeDocument.selection.copy()
					
					app.activeDocument.layers[layerName].remove()
					app.activeDocument.activeLayer = allLayers[parseInt(layerName.substring(0,layerName.indexOf ('_')))+numMasks]
					app.activeDocument.activeLayer.name = app.activeDocument.activeLayer.name.replace(/FwdSlash/g, '/')
					create_mask()
					paste_mask()  
					 
				}
				else
				{    
					layerRef.name = layerRef.name.substring(layerRef.name.indexOf('__')+2,layerRef.name.length) 
					layerRef.visible = layerRef_vis
				}
				
			}// end of loop
		} catch(e) {;} // do nothing
	}// end of function

	app.preferences.rulerUnits = origRulerUnits 
	app.preferences.typeUnits = origTypeUnits
	app.preferences.pointSize = origPointSize
	"
	
	fn FindByElementName obj str = -- will find a texture bake element by name. default funtion didn't seem to work properly.
	(
		counter = 1
		try (	while (obj.iNodeBakeProperties.getBakeElement counter).elementname != str do counter += 1 ) catch (counter = 0)
		counter
	)
	
	try (gTextureBakeDialog.close()) catch()
	failed = false
	changeLights = false
	noMat = noMap = wrongMat = false

	
	if $ == undefined then 
	(
		messagebox "please select an object first."
		failed = true
	)
	else if selection.count != 1 then
	(
		messagebox "please select one object only."
		failed = true
	) 
	
	if not failed do
	(
		
		if $.material == undefined then 
		(
			noMat = true
		)
		else if hasproperty $.material "diffusemap" then 
		(		
			if $.material.diffusemap == undefined or (classof $.material.diffusemap) != Bitmaptexture then
			(
				noMap = true
			)
		)else wrongMat = true
		
		if noMat or noMap or wrongMat then
		(
			psdfileName = getOpenFileName types:"Photoshop(*.psd)|*.psd|Tiff(*.tif)|*.tif|"
			if psdfileName == undefined then failed = true
				
		)else
		(
			psdfileName = $.material.diffusemap.fileName
		)
			
		
		if lights.count > 0 and not failed then
		(
			changeLights = false
			answer = yesnocancelbox "The output will only be correct if all lights are turned off. Do you want to turn all lights off?"
			if answer == #yes then
			(
				changeLights = true
				allLights = for l in (lights as array) where classof l != targetobject collect #(l,l.on)
				for l in allLights do l[1].on = false
			)
			if answer == #cancel then failed = true
					
		)
	)

	if not failed then
	(
		
		global obj = $
		max create mode -- because subobject modifications are slow with modify panel it's better to view the create panel
		
		-- progress rollout
		rollout progress_rollout "TO CANCEL, PRESS ESCAPE FOR 10 SECONDS" width:328 height:216
		(
			dotNetControl total_pb "Windows.Forms.Progressbar" pos:[9,40] width:311 height:14 --height:24
			label total_lbl "Total Compositing:" pos:[8,16] width:134 height:18
			--button cancel_btn "Cancel" pos:[248,8] width:72 height:24
			GroupBox grp1 "Progress" pos:[8,70] width:312 height:96
			
			label time_last_lb "Last Frame Time" pos:[16,136-40] width:168 height:16
			label Time_elapsed_lb "Elapsed Time:" pos:[16,160-40] width:168 height:16
			label time_remaining_lb "Time Remaining:" pos:[16,184-40] width:168 height:16
			
			label cancel_lbl "TO CANCEL, PRESS ESCAPE FOR 10 SECONDS" pos:[8,185]
		)

		fn get2Zeros theNum = (substring "00" 1 (2-(theStr = theNum as string).count) + theStr )
		
		--***************
		 --PREPARATION
		--***************
		pshop=CreateOLEObject"Photoshop.Application"  -- Open Photoshop
		pshop.Visible=true
		
		rollout psAtWork "photoshop at work" width:329 height:115
		(
			label lbl1 "Photoshop is preparing the file. Depending on the number of layers this can take a while. You can open photoshop and watch the progress." pos:[20,36] width:290 height:48
		)
		createdialog psAtWork
		
		if not noMat do oldmat = obj.material -- store old material if one exists
		pshop.open(psdFileName) -- open the texture
		pshop.doJavaScript(prepare_str) -- run the first preparation java script in photoshop.
		
		
		destroydialog psAtWork
		--save the file under a different name
		original_name = psdFileName 
		remapped_name = (getFilenamePath original_name)+(getFilenameFile original_name)+"_remapped.psd"
		pshop.activeDocument.saveAs(remapped_name)
		psdfile = openbitmap psdfilename
		sizeX = psdfile.width
		sizeY = psdfile.height
		close psdfile
		-- assign a new material and save the old one
		
		
		numlayers = BitmapLayerManager.getLayerCount remapped_name
		print numlayers
		newmat = standard()
		newmat.Diffuse = color 0 0 0
		newmat.Ambient = color 0 0 0
		newmat.selfIllumAmount = 100
		obj.material = newmat
				
		-- save original bakeElements
		element_states = #()
		for i = 1 to obj.iNodeBakeProperties.numBakeElements() do 
		(
			element = obj.iNodeBakeProperties.getBakeElement i
			append element_states #(i,element.enabled)
			element.enabled = false
		)
		
		-- look for the REMAP element and create one if it doesn't exist
		if (FindByElementName obj "REMAP") == 0 then 
		(
			
			remap_element = CompleteMap() -- although diffuse maps is more appropriate, only the complete map also saves an alpha channel
			obj.iNodeBakeProperties.addBakeElement remap_element
			remap_element.elementname = "REMAP"
			automate = true
			
		)
		else
		(
			remap_element = obj.iNodeBakeProperties.getBakeElement (FindByElementName obj "REMAP")
			automate = false
		)

		remap_element.enabled = true

		-- if REMAP bake element hasn't been setup use default settings
		if automate then 
		(
			
			remap_element.outputSzX = sizeX -- use texture size from the psd file
 			remap_element.outputSzY = sizeY
			if gtextureBakedialog == undefined then macros.run "Render" "BakeDialog"
			if not gTextureBakeDialog.open then macros.run "Render" "BakeDialog"
			obj = $
			obj.iNodeBakeProjProperties.enabled = true -- enable projection mapping
			gTextureBakeDialog.rollouts.selectedObjectProps.cProjMapEnable.checked = true
			gTextureBakeDialog.rollouts.selectedObjectProps.cProjMapEnable.changed true
 			obj.INodeBakeProperties.BakeChannel = 2 -- bake to channel 2
 			obj.iNodeBakeProjProperties.subObjBakeChannel = 1 -- bake from channel 1
			gTextureBakeDialog.rollouts.selectedObjectProps.rb_mapCoordOpt_Obj.state = 1
			gTextureBakeDialog.rollouts.selectedObjectProps.rb_mapCoordOpt_Obj.changed 1 
			gTextureBakeDialog.rollouts.selectedObjectProps.rb_mapCoordOpt_SubObj.state = 1
			gTextureBakeDialog.rollouts.selectedObjectProps.rb_mapCoordOpt_SubObj.changed 1 
			gTextureBakeDialog.rollouts.selectedObjectProps.CloseWorkingObjects()
			gTextureBakeDialog.rollouts.selectedObjectProps.UpdateObjectSettings()
				
		)
		--$.INodeBakeProperties.ndilations = 2
		
		-- open the Bake dialog and make changes
		macros.run "Render" "BakeDialog"
		oldpath = gTextureBakeDialog.rollouts.commonBakeProps.eFilePath.text
		global newpath = ( (getfilenamepath remapped_name)+(getfilenamefile remapped_name)) -- create a remapped folder at the same hierarchy as the psd file
		
		removeDir = substituteString newpath "\\" "\\\\"
		dotnetdir = dotNetClass "System.IO.Directory"
		if dotnetdir.exists removedir then dotnetdir.delete removedir true
			
		makeDir newpath
		gTextureBakeDialog.rollouts.commonBakeProps.eFilePath.text = newpath -- use the new folder for output
		gTextureBakeDialog.rollouts.bakedMtlProps.cbRenderToFilesOnly.checked = true -- make sure files are rendered only!
		createdialog progress_rollout
		lasttime = timestamp()
		begin = timestamp()
		cont = true
		pshop.visible = false	
			
		renderscenedialog.close()	
		orig_rendTimeType = rendTimeType 
		rendTimeType = 1
		
		--****************
		--BAKE TEXTURES
		--****************	
		
		for i = 1 to numLayers do
		(
			if cont then
			(
				
				
				thebitmap = BitmapLayerManager.loadLayer ( remapped_name  ) (i-1) true
				theTexture = bitmapTexture bitmap:thebitmap --(execute command)
				obj.material.diffusemap = theTexture
				
				-- apply the same map to the opacity channel
				theOpacity = bitmapTexture bitmap:thebitmap --(execute command)
				theOpacity.monoOutput = 1
				obj.material.opacitymap = theOpacity
				
				layerName = BitmapLayerManager.getLayerName remapped_name (i-1)
				
				--be1 = (obj.iNodeBakeProperties.getBakeElement 1) 
				remap_element.fileType = (newpath +"\\"+layername+".tga")
				remap_element.fileName = filenameFromPath remap_element.fileType
				gTextureBakeDialog.rollouts.selectedElementProps.eFilename.text = layername+".tga"
				gTextureBakeDialog.rollouts.selectedElementProps.eFilename.entered (layername+".tga")
				gTextureBakeDialog.bRender.pressed()
				
				
				progress_rollout.total_pb.value = (100/numLayers)*(i-1)
				time_last_caption = stringstream ""
				now = timestamp()
				frametime = ((now-lasttime)/1000.0)
				format "Last Frame Time: % s" frametime to:time_last_caption
				Time_elapsed_caption = stringstream ""
				format "Time Elapsed: %:%:%" (get2zeros((((now-begin)/1000)/60)/60)) (get2zeros(((now-begin)/1000)/60)) (get2zeros((mod ((now-begin)/1000) 60) as integer)) to:Time_elapsed_caption		
				Time_remaining_caption = stringstream ""
				remaintime = (frametime*(numlayers-i) )
				format "Time Remaining: %:%:%" (get2zeros(((( remaintime )/60.0)/60.0) as integer)) (get2zeros(((remaintime)/60.0) as integer)) (get2zeros(((mod (remaintime) 60.0) as integer))) to:Time_remaining_caption		
				
				
				progress_rollout.time_last_lb.caption = time_last_caption as string
				progress_rollout.time_elapsed_lb.caption = time_elapsed_caption as string 
				progress_rollout.time_remaining_lb.caption = time_remaining_caption as string 
				lasttime = timestamp()
				if keyboard.escPressed do cont = false;
				
				
			)
		)
		
		-- reenforce correct settings
		if automate then 
		(
			
			remap_element.outputSzX = sizeX -- use texture size from the psd file
 			remap_element.outputSzY = sizeY
			
			
			if not gTextureBakeDialog.open then macros.run "Render" "BakeDialog"
			obj.iNodeBakeProjProperties.enabled = true -- enable projection mapping
			gTextureBakeDialog.rollouts.selectedObjectProps.cProjMapEnable.checked = true
			gTextureBakeDialog.rollouts.selectedObjectProps.cProjMapEnable.changed true
 			obj.INodeBakeProperties.BakeChannel = 2 -- bake to channel 2
 			obj.iNodeBakeProjProperties.subObjBakeChannel = 1 -- bake from channel 1
			gTextureBakeDialog.rollouts.selectedObjectProps.rb_mapCoordOpt_Obj.state = 1
			gTextureBakeDialog.rollouts.selectedObjectProps.rb_mapCoordOpt_Obj.changed 1 
			gTextureBakeDialog.rollouts.selectedObjectProps.rb_mapCoordOpt_SubObj.state = 1
			gTextureBakeDialog.rollouts.selectedObjectProps.rb_mapCoordOpt_SubObj.changed 1 
			gTextureBakeDialog.rollouts.selectedObjectProps.CloseWorkingObjects()
			gTextureBakeDialog.rollouts.selectedObjectProps.UpdateObjectSettings()
			
		)
		
		
		destroydialog progress_rollout
		
		--*******************
		--POST OPERATIONS
		--********************
		
		
		pshop.visible = true
		
		err = false
		try (pshop.doJavaScript(update_str) ) catch(err = true) -- Load all layers back into the psd file
		try (pshop.activeDocument.save()) catch (err = true) -- save the remapped file
		
		if err == false then
		(
			if not noMat then
			(
				obj.material = oldmat -- reassign old material
				if not wrongmat and not noMap do
				(
					obj.material.diffusemap.bitmap = openbitmap remapped_name -- apply the remapped file to the diffuse channel
					obj.material.diffusemap.coordinates.mapchannel = obj.INodeBakeProperties.BakeChannel -- use the new mapping channel
				)
			)else obj.material = undefined
		)
		
		gTextureBakeDialog.rollouts.commonBakeProps.eFilePath.text = oldpath -- reset the bake dialog path
		
		-- use dotnet to remove the directory with temporary files
		removeDir = substituteString newpath "\\" "\\\\"
		dotnetdir = dotNetClass "System.IO.Directory"
		--if dotnetdir.exists removedir then dotnetdir.delete removedir true
			
		rendtimetype = orig_rendTimeType 
		
		
	)

	if changeLights then for l in allLights do l[1].on = l[2] -- turn all lights back on
	
)

colorman.reiniticons()