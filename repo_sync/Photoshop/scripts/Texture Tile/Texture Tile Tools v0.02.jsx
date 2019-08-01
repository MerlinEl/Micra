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
        windowResource += "preferredSize:[120, 200],"
        windowResource += "location :[50, 100],"
        windowResource += "text: 'Texture Tile Tools:',"
        windowResource += "margins:15," 
        windowResource += "}"
    var win = new Window(windowResource);
    //Add Buttons
//~     var btn_def_ptrn = win.add ("button", undefined, "Define Pattern");
//~     var btn_pre_tile = win.add ("button", undefined, "Preview Tile");
    var btn_close = win.add('button', undefined, 'Close', {name:'close'});
    var btn_init = win.add ("button", undefined, "INITIALIZE");
    var btn_offset_xf = win.add ("button", undefined, "Offset X ►");
    var btn_offset_xb = win.add ("button", undefined, "Offset X ◄");
    var btn_offset_yf = win.add ("button", undefined, "Offset Y ▼");
    var btn_offset_yb = win.add ("button", undefined, "Offset Y ▲");
    var btn_update = win.add ("button", undefined, "UPDATE");
    
    //Assign Functions
//~     btn_def_ptrn.onClick =  redefinePattern
//~     btn_pre_tile.onClick =  previewTile
    btn_init.onClick = initialize
    btn_update.onClick = updatePreview
    btn_offset_xf.onClick = offsetWorkXF
    btn_offset_xb.onClick = offsetWorkXB
    btn_offset_yf.onClick = offsetWorkYF
    btn_offset_yb.onClick = offsetWorkYB
    btn_close.onClick = function () { win.close() } 
    
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
    function createNewDocument(w, h, dpi, doc_name){
           
        $.writeln("createNewDocument > w:"+w+" h:"+h+" dpi:"+dpi+" name:"+doc_name);
       var new_doc =  app.documents.add(w*4, h*4, dpi, doc_name, NewDocumentMode.RGB, DocumentFill.WHITE);
       return new_doc;
    }
    function getDocumentIndex( doc_name ) {
        
        var doc_index = -1;
        for(var i=0;i<app.documents.length;i++){  
            
            var doc = app.documents[i];  
            if (doc.name == doc_name) doc_index = i
        }  
        return doc_index
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
        $.writeln("fillColor > rgb:"+clr);
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
    function createNewLayer(doc, layer_name){
    
        $.writeln("createNewLayer > name:"+layer_name);
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
    function offsetLayerGraphics(h, w){
              
        var desc1 = new ActionDescriptor();
        desc1.putInteger(cTID('Hrzn'), h);
        desc1.putInteger(cTID('Vrtc'), w);
        desc1.putEnumerated(cTID('Fl  '), cTID('FlMd'), cTID('Wrp '));
        executeAction(cTID('Ofst'), desc1, DialogModes.NO);
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
        
          if (work_doc == undefined) {

            alert("Document must be initialized.."); 
            return false;
        }  
        var pattern_name = "TILE_PATTERN_TEXTURE";
         $.writeln("redefinePattern > "+pattern_name);
        //find pattern by name and delete if exist
        deleterOldPattern ( pattern_name );
        //generate new pattern
        createNewPattern( pattern_name );
    }
    //add effect pattern in active layer in active doc
    function addEfectPattern(pattern_name){
         
         $.writeln("addEfectPattern > ")
//~         var pattern_id = getLastPatternId(pattern_name);
//~         $.writeln("addEfectPattern > name:"+pattern_name+" id:"+pattern_id);
        var desc1 = new ActionDescriptor();
        var ref1 = new ActionReference();
        ref1.putProperty(cTID('Prpr'), cTID('Lefx'));
        ref1.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt'));
        desc1.putReference(cTID('null'), ref1);
        var desc2 = new ActionDescriptor();
        desc2.putUnitDouble(cTID('Scl '), cTID('#Prc'), 100);
        var desc3 = new ActionDescriptor();
        desc3.putBoolean(cTID('enab'), true);
        desc3.putBoolean(sTID("present"), true);
        desc3.putBoolean(sTID("showInDialog"), true);
        desc3.putEnumerated(cTID('Md  '), cTID('BlnM'), cTID('Nrml'));
        desc3.putUnitDouble(cTID('Opct'), cTID('#Prc'), 100);
        var desc4 = new ActionDescriptor();
        desc4.putString(cTID('Nm  '), pattern_name);
        //desc4.putString(cTID('Idnt'), "1e8b0550-f8c9-5946-a14c-eca6644e2535");
        desc3.putObject(cTID('Ptrn'), cTID('Ptrn'), desc4);
        desc3.putUnitDouble(cTID('Scl '), cTID('#Prc'), 100);
        desc3.putBoolean(cTID('Algn'), true);
        var desc5 = new ActionDescriptor();
        desc5.putDouble(cTID('Hrzn'), 0);
        desc5.putDouble(cTID('Vrtc'), 0);
        desc3.putObject(sTID("phase"), cTID('Pnt '), desc5);
        desc2.putObject(sTID("patternFill"), sTID("patternFill"), desc3);
        desc1.putObject(cTID('T   '), cTID('Lefx'), desc2);
        executeAction(cTID('setd'), desc1, DialogModes.NO);
    }
    function  previewTile() {
         
        if (work_doc == undefined) {

            alert("Document must be initialized."); 
            return false;
        }  
         $.writeln("previewTile > ");
         var  doc_index = getDocumentIndex("TILE_PROJECTION_DOCUMENT");
         $.writeln("previewTile > doc index:"+doc_index);
         var pattern_name = "TILE_PATTERN_TEXTURE";
         if (doc_index == -1)  { //create project documet
             
            var w = work_doc.width;
            var h = work_doc.height;
            var dpi = work_doc.resolution;
            var mode = work_doc.mode;
            preview_doc = createNewDocument(w, h, dpi, "TILE_PROJECTION_DOCUMENT");
             var new_layer = createNewLayer(preview_doc, "TILE_PROJECT");
            fillColor (preview_doc, new_layer, 255, 255, 255); //fill layer white
            addEfectPattern(pattern_name);
             
         } else { //focus project documet
             
             preview_doc = app.documents[doc_index];
             app.activeDocument = preview_doc;
             addEfectPattern(pattern_name);
         }
          app.activeDocument = work_doc //focus back
    }   
    function initialize(){
        
        work_doc = app.activeDocument;
        redefinePattern();
        previewTile();
    }
    function updatePreview(){
        
         if (work_doc == undefined) {

            alert("Document must be initialized."); 
            return false;
        }  
        app.activeDocument = work_doc;
        redefinePattern();
        previewTile();
    }
    function offsetWorkXF(){
        
         if (work_doc == undefined) {

            alert("Document must be initialized."); 
            return false;
        }  
        app.activeDocument = work_doc;
        offsetLayerGraphics ((work_doc.width/2),  0);
    }
    function offsetWorkXB(){
        
         if (work_doc == undefined) {

            alert("Document must be initialized."); 
            return false;
        }  
        app.activeDocument = work_doc;
        offsetLayerGraphics (-(work_doc.width/2),  0);
    }
    function offsetWorkYF(){
        
          if (work_doc == undefined) {
              
            alert("Document must be initialized.."); 
            return false;
        }  
        app.activeDocument = work_doc;
        offsetLayerGraphics (0, (work_doc.height/2));
    }
    function offsetWorkYB(){
        
          if (work_doc == undefined) {
              
            alert("Document must be initialized.."); 
            return false;
        }  
        app.activeDocument = work_doc;
        offsetLayerGraphics (0, -(work_doc.height/2));
    }
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