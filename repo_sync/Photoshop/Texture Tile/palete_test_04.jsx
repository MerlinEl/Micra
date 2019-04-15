/*
DOCUMENTATION
http://scripting345.rssing.com/chan-20965412/all_p1.html
http://estk.aenhancers.com/4%20-%20User-Interface%20Tools/scriptui-programming-model.html //interface
https://www.adobeexchange.com/creativecloud.photoshop.html#paging --continue explore from page 7
http://www.ps-scripts.com/
http://ps-scripts.sourceforge.net/xtools.html
http://www.adobe.com/devnet/photoshop/scripting.html
http://www.smashingmagazine.com/2013/07/25/introduction-to-photoshop-scripting/
https://www.adobe.com/content/dam/acom/en/devnet/photoshop/pdfs/photoshop-cc-javascript-ref-2015.pdf  

C:\Users\Rene.baca\AppData\Roaming\Adobe\Adobe Photoshop CC 2018\Presets\Actions
*/

//Clear the console
var bt = new BridgeTalk();
bt.target = 'estoolkit-4.0';
bt.body = function(){app.clc();}.toSource()+"()";
bt.send(5);

#target photoshop
app.bringToFront();

var work_doc = undefined;
var preview_doc = undefined;

function WinObject() {
   
  // Long resource String for 'palette' Window
  var windowResource = "palette {"
        windowResource += "orientation: 'column',"
        windowResource += "alignChildren: ['fill', 'top'],"
        windowResource += "preferredSize:[200, 400],"
        windowResource += "location :[50, 100],"
        windowResource += "text: 'Texture Tile Tool:',"
        windowResource += "margins:15," 
        windowResource += "}"
    var win = new Window(windowResource);
    //Add Buttons
    var btn_def_ptrn = win.add ("button", undefined, "Define Pattern");
    var btn_pre_tile = win.add ("button", undefined, "Preview Tile");
    var btn_3 = win.add ("button", undefined, "Update Preview");
    var btn_11 = win.add ("button", undefined, "Create New Document");
    var btn_12 = win.add ("button", undefined, "Preview Tile");
    var btn_13 = win.add('button', undefined, 'Close', {name:'close'});
    
    //Assign Functions
    btn_def_ptrn.onClick =  redefinePattern
    btn_pre_tile.onClick =  previewTile
    
    //Define Functions
    cTID = function(s) { return app.charIDToTypeID(s); };
    sTID = function(s) { return app.stringIDToTypeID(s); };
    function newRGBColor(r, g, b) {
        
        var newColor = new SolidColor();
        newColor.rgb.red = r;
        newColor.rgb.green = g;
        newColor.rgb.blue = b;
        return(newColor);
    }
    function addFilterBlur(){  //add filter to active layer
        
        var idGsnB = charIDToTypeID( "GsnB" );  
        var desc2 = new ActionDescriptor();  
        var idRds = charIDToTypeID( "Rds " );  
        var idPxl = charIDToTypeID( "#Pxl" );  
        desc2.putUnitDouble( idRds, idPxl, 0.300000 );  
        executeAction( idGsnB, desc2, DialogModes.NO );  
    }
    function createProjectDoc(w, h, dpi, doc_name){
           
        $.writeln("w:"+w+" h:"+h+" dpi:"+dpi);
       var new_doc =  app.documents.add(w*4, h*4, dpi, doc_name, NewDocumentMode.RGB, DocumentFill.WHITE);
       return new_doc;
    }
    function selectDoc() {

        var desc1 = new ActionDescriptor();
        var ref1 = new ActionReference();
        ref1.putOffset(cTID('Dcmn'), 1);
        desc1.putReference(cTID('null'), ref1);
        desc1.putInteger(cTID('DocI'), 217);
        executeAction(cTID('slct'), desc1, DialogModes.NO);
    };
    function fillColor(doc, layer, red,green,blue) {
        
        doc.selection.selectAll();
        var clr = new SolidColor;
        clr.rgb.red = red;
        clr.rgb.green = green;
        clr.rgb.blue = blue;
        doc.selection.selectAll();
        doc.selection.fill(clr);
        doc.selection.deselect();
    }
    // -----------------------------------------
    // newColorOverlayEffect()
    //   overlayOpacity:       // 0 - 100 %
    //   overlayColor:         // SolidColor()
    // -----------------------------------------
    function newColorOverlayEffect(overlayOpacity, overlayColor) {
        
        var effectDescriptor = new ActionDescriptor();
        var effectColor = new ActionDescriptor();
        effectDescriptor.putBoolean(charIDToTypeID("enab"), true);
        effectDescriptor.putEnumerated(charIDToTypeID("Md  "), charIDToTypeID("BlnM"), charIDToTypeID("Nrml")); //Clr, Nrml, Mltp
        effectDescriptor.putUnitDouble(charIDToTypeID("Opct"), charIDToTypeID("#Prc"), overlayOpacity);
        effectColor.putDouble(charIDToTypeID("Rd  "), overlayColor.rgb.red);
        effectColor.putDouble(charIDToTypeID("Grn "), overlayColor.rgb.green);
        effectColor.putDouble(charIDToTypeID("Bl  "), overlayColor.rgb.blue);
        effectDescriptor.putObject(charIDToTypeID("Clr "), charIDToTypeID("RGBC"), effectColor);
        return(effectDescriptor);
    }
     function addStylePattern(doc, layer){
             
       alert("addStylePattern > add pattern to doc:"+doc+" layer:"+layer);
        layer.opacity = 50;
        // layer.applyStyle ("solidFill") //add the color overly layer style
       //photoshop script layer style pattern
          //This will change the opacity of the inner shadow on a layer with inner shadow turned on already
    //layer.property("Layer Styles").property("Inner Shadow")("Opacity").setValue(10)
        //var solid_composite = layer("Layer Styles").addProperty("Stroke");
        
     //artLayes
        /*
            'dropShadow'
            'innerShadow'
            'outerGlow'
            'innerGlow'
            'bevelEmboss'
            'solidFill' // color overlay
            'gradientFill' // gradient overlay
            'patternFill' // pattern overlay
            'chromeFX' // satin
            'frameFX' // stroke
            */
     }
      function addEffectColorOverlay(r,g,b) {  
          
        var desc = new ActionDescriptor();  
            var ref = new ActionReference();  
            ref.putProperty( charIDToTypeID('Prpr'), charIDToTypeID('Lefx') );  
            ref.putEnumerated( charIDToTypeID('Lyr '), charIDToTypeID('Ordn'), charIDToTypeID('Trgt') );  
        desc.putReference( charIDToTypeID('null'), ref );  
            var effectsDesc = new ActionDescriptor();  
            //effectsDesc.putUnitDouble( charIDToTypeID('Scl '), charIDToTypeID('#Prc'), 333.333333 );  
                var colorfillDesc = new ActionDescriptor();  
                colorfillDesc.putBoolean( charIDToTypeID('enab'), true );  
                colorfillDesc.putEnumerated( charIDToTypeID('Md  '), charIDToTypeID('BlnM'), charIDToTypeID('Nrml') );  
                colorfillDesc.putUnitDouble( charIDToTypeID('Opct'), charIDToTypeID('#Prc'), 100.000000 );  
                    var rgbcDesc = new ActionDescriptor();  
                    rgbcDesc.putDouble( charIDToTypeID('Rd  '), r );  
                    rgbcDesc.putDouble( charIDToTypeID('Grn '), g );  
                    rgbcDesc.putDouble( charIDToTypeID('Bl  '), b );  
                colorfillDesc.putObject( charIDToTypeID('Clr '), charIDToTypeID('RGBC'), rgbcDesc );  
            effectsDesc.putObject( charIDToTypeID('SoFi'), charIDToTypeID('SoFi'), colorfillDesc );  
        desc.putObject( charIDToTypeID('T   '), charIDToTypeID('Lefx'), effectsDesc );  
        executeAction( charIDToTypeID('setd'), desc, DialogModes.NO );
    }
    function addLayer(doc, layer_name){
    
        var layers = doc.artLayers;
        var new_layer = layers.add();
        new_layer.name = layer_name;
        doc.activeLayer = new_layer;
        return new_layer
    }
    // get array of patterns’ names;
    function getPatternNames () {
        
        var ref = new ActionReference();
        ref.putProperty(stringIDToTypeID ("property"), stringIDToTypeID("presetManager") );
        ref.putEnumerated( charIDToTypeID("capp"), charIDToTypeID("Ordn"), charIDToTypeID("Trgt") );
        var applicationDesc = executeActionGet(ref);
        var presetManager = applicationDesc.getList(stringIDToTypeID("presetManager"));
        var patternNames = presetManager.getObjectValue(4).getList(stringIDToTypeID("name"));
        var theNames = new Array;
        for (m = 0; m < patternNames.count; m++) {
            
            theNames.push(patternNames.getString(m));
        }
        return theNames;
   }
   function fillPatern(patternName){
        
       //  work_doc.selection.selectAll();
       // docRef.selection.fill(pattern?);
    }
    function definePattern(patternName) {
        
        var desc6 = new ActionDescriptor();
        var ref3 = new ActionReference();
        ref3.putClass( charIDToTypeID('Ptrn') );
        desc6.putReference( charIDToTypeID('null'), ref3 );
        var ref4 = new ActionReference();
        ref4.putProperty( charIDToTypeID('Prpr'), charIDToTypeID('fsel') );
        ref4.putEnumerated( charIDToTypeID('Dcmn'), charIDToTypeID('Ordn'), charIDToTypeID('Trgt') );
        desc6.putReference( charIDToTypeID('Usng'), ref4 );
        desc6.putString( charIDToTypeID('Nm  '), patternName);
        executeAction( charIDToTypeID('Mk  '), desc6, DialogModes.NO );
    }
    function createNewPattern( ptrn_name ) {
        
        var desc1 = new ActionDescriptor();
        var ref1 = new ActionReference();
        ref1.putClass(cTID('Ptrn'));
        desc1.putReference(cTID('null'), ref1);
        var ref2 = new ActionReference();
        ref2.putProperty(cTID('Prpr'), sTID("selection"));
        ref2.putEnumerated(cTID('Dcmn'), cTID('Ordn'), cTID('Trgt'));
        desc1.putReference(cTID('Usng'), ref2);
        desc1.putString(cTID('Nm  '), ptrn_name);
        executeAction(cTID('Mk  '), desc1, DialogModes.NO);
        $.writeln("createNewPattern > New Pattern has been created. Name:"+ptrn_name);
    }
    function deleterPatternAt ( ptrn_index ) {
         
         var desc1 = new ActionDescriptor();
         var ref1 = new ActionReference();
        ref1.putIndex(cTID('Ptrn'), ptrn_index);
        desc1.putReference(cTID('null'), ref1);
        executeAction(cTID('Dlt '), desc1, DialogModes.NO);
        $.writeln("deleterPatternAt > Old Pattern has been deleted. Index:"+ptrn_index);
    }
    function renamePatternAt (ptrn_index, new_name) {

        var desc1 = new ActionDescriptor();
        var ref1 = new ActionReference();
        ref1.putIndex(cTID('Ptrn'), ptrn_index);
        desc1.putReference(cTID('null'), ref1);
        desc1.putString(cTID('T   '), new_name);
        executeAction(cTID('Rnm '), desc1, DialogModes.NO);
    }
    function deleterOldPattern ( ptrn_name ) {
       
        var pattern_names = getPatternNames();
       //alert(pattern_names.join("\n"));
       var last_pattern_name = pattern_names[pattern_names.length-1];
       // $.writeln("last pattern name:"+last_pattern_name);
        if (last_pattern_name == ptrn_name) deleterPatternAt(pattern_names.length-1);
    }
    function redefinePattern() {
        
        var pattern_name = "TILE_PATTERN_TEXTURE";
         $.writeln("redefinePattern > "+pattern_name);
        //find pattern by name and delete if exist
        deleterOldPattern ( pattern_name );
        //generate new pattern
        createNewPattern( pattern_name );
    }
     function  previewTile() {
         
         
    }
    btn_3.onClick = function () {
        //Update Preview
         var preview_doc = app.documents.itemByName("TILE_PROJECTION_DOCUMENT");
    }
    btn_11.onClick = function () {

        app.documents.add(); // adds a new document
        app.activeDocument.activeLayer.applyAddNoise (400, NoiseDistribution.GAUSSIAN, true); //create noise
    }
    btn_12.onClick = function () {

        var work_doc = app.activeDocument;
        if (work_doc == undefined) {

            alert("document must be opened"); 
            return false;
        }  
        createNewPattern("TILE_PROJECTION_PATTERN");
        var w = work_doc.width;
        var h = work_doc.height;
        var dpi = work_doc.resolution;
        var mode = work_doc.mode;
        var preview_doc = createProjectDoc(w, h, dpi, "TILE_PROJECTION_DOCUMENT");
        $.writeln("preview_doc w:"+preview_doc.width+" h:"+preview_doc.height);
        var new_layer = addLayer(preview_doc, "TILE_PROJECT");
        fillColor (preview_doc, new_layer, 255, 255, 255);
        
        addEffectColorOverlay( 0, 0, 255); 
        
        //--------------
        // layer effects
        //--------------
       /* var refr01 = new ActionReference();
        var layerProperties = new ActionDescriptor();
        var layerOptions = new ActionDescriptor();
        var showPsDlgs = DialogModes.NO;  // layer styles Photoshop dialogs NO/ALL
        var ex;
        var overlayColor = new newRGBColor(200, 40, 40);
        var layerEffects = newColorOverlayEffect(50, overlayColor);
        layerOptions.putObject(charIDToTypeID("SoFi"), charIDToTypeID("SoFi"), layerEffects);
         //-----------------
        // layer properties
        //-----------------
        refr01.putProperty(charIDToTypeID("Prpr"), charIDToTypeID("Lefx"));
        refr01.putEnumerated(charIDToTypeID("Lyr "), charIDToTypeID("Ordn"), charIDToTypeID("Trgt"));
        layerProperties.putReference(charIDToTypeID("null"), refr01);
        layerProperties.putObject(charIDToTypeID("T   "), charIDToTypeID("Lefx"), layerOptions);
        try {
            executeAction(charIDToTypeID("setd"), layerProperties, showPsDlgs);
        } catch(ex) {
            if (ex != "Error: User cancelled the operation")
                alert(scriptName + " newLayerEffect() exception caught? line[" + ex.line + "] "  + ex);
        }*/
        
        //addStylePattern(preview_doc, new_layer);
        //fillPattern("TILE_PROJECTION_PATTERN");
    }
    btn_13.onClick = function () { win.close() }    
    // Show the Window
      win.show();
};

// String message for BridgeTalk
var message = WinObject.toString();
// construct an anonymous instance and add it to the string
message += "\nnew WinObject();"
// $.writeln(message); // check it in the ESTK Console, just in case
var bt = new BridgeTalk();
bt.target = "photoshop";
bt.body = message;
bt.send();
app.bringToFront();

/*
    
    app.activeDocument.name
  ps.ApplicationClass app = new ps.ApplicationClass();

app.Open(@"test.psd",null);//   this  statement  is  added  by  me,  is it  right?
String Code = "var ref = new ActionReference();" +
"ref.putEnumerated( charIDToTypeID('Lyr '), charIDToTypeID('Ordn'), charIDToTypeID('Trgt') ); " +
"  ReturnCode =  executeActionGet(ref).hasKey(stringIDToTypeID('layerEffects'))?'Style Exists' :'Style Does Not Exist';";
String ReturnCode = app.DoJavaScript(Code, null, null);
MessageBox.Show(ReturnCode);  
      
function getStrokeSize(){  
    try{  
        var ref = new ActionReference();  
        ref.putEnumerated( charIDToTypeID("Lyr "), charIDToTypeID("Ordn"), charIDToTypeID("Trgt") );   
        var desc = executeActionGet(ref).getObjectValue(stringIDToTypeID('layerEffects')).getObjectValue(stringIDToTypeID('frameFX'));  
        return desc.getUnitDoubleValue(stringIDToTypeID('size'));  
    }catch(e){}  
};  
    
    
  // Ask user for input by showing prompt box and save inputted value to variable:
var stemsAmount = prompt("Processing ""+originalStem.name+""nHow many stems do you need?", 12);  
    
  var lastPatternIndex = getPatternIndexByName(patternName); 
  function getPatternIndexByName(match) {  
    try {  
        var r = new ActionReference();  
        r.putProperty(charIDToTypeID("Prpr"), stringIDToTypeID("presetManager"));  
        r.putEnumerated(charIDToTypeID("capp"), charIDToTypeID("Ordn"), charIDToTypeID("Trgt"));  
  
  
        var list = executeActionGet(r).getList(stringIDToTypeID("presetManager"));  
  
  
        for (var i = 0; i < list.count; i++) {  
            if (list.getObjectType(i) == charIDToTypeID("PttR")) {  
                var list2 = list.getObjectValue(i).getList(stringIDToTypeID("name"));  
  
  
                for (var x = 0; x < list2.count; x++) {  
                    var name = list2.getString(x);  
                    if (name.indexOf(match) >= 0) return x + 1;  
                }  
  
  
                break;  
            }  
        }  
  
  
        return -1;  
    }  
    catch (e) {  
        alert(e);  
        return -1;  
    }  
}
  
  
  
  function createFill() {  
        var fillColor = new SolidColor();  
        fillColor.rgb.red = 255;  
        fillColor.rgb.green = 255;  
        fillColor.rgb.blue = 255;  
  
  
        var newLayer = doc.artLayers.add();  
        newLayer.name = "fill " + (i + 1);  
        doc.selection.fill(fillColor);  
        newLayer.move(newLayer, ElementPlacement.PLACEAFTER);  
  
  
        var fillLayer = doc.activeLayer;    
        fillLayer.move(doc.layers[doc.layers.length-1], ElementPlacement.PLACEAFTER);  
    } 
  
work_doc.artLayers["Background"].copy() //Using the copy merged command/method
preview_doc.paste()
  
 alert (imgD.Width.as("px"));
//target text layer
var layerRef = app.activeDocument.layers.getByName("Text");
app.activeDocument.close();
*/