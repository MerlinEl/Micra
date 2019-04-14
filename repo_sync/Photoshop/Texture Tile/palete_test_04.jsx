/*
DOCUMENTATION
http://scripting345.rssing.com/chan-20965412/all_p1.html
https://www.adobeexchange.com/creativecloud.photoshop.html#paging --continue explore from page 7
http://www.ps-scripts.com/
http://ps-scripts.sourceforge.net/xtools.html
http://www.adobe.com/devnet/photoshop/scripting.html
http://www.smashingmagazine.com/2013/07/25/introduction-to-photoshop-scripting/
https://www.adobe.com/content/dam/acom/en/devnet/photoshop/pdfs/photoshop-cc-javascript-ref-2015.pdf  
*/

#target photoshop

function WinObject() {
   
  // Long resource String for 'palette' Window
  var windowResource = "palette {"
        windowResource += "orientation: 'column',"
        windowResource += "alignChildren: ['fill', 'top'],"
        windowResource += "preferredSize:[200, 400],"
        windowResource += "text: 'Texture Tile Tool:',"
        windowResource += "margins:15," 
        windowResource += "}"
    var win = new Window(windowResource);
    //Add Buttons
    var btn_1 = win.add ("button", undefined, "Create New Document");
    var btn_2 = win.add ("button", undefined, "Preview Tile");
    //Define Functions
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
    function createProjectDoc(w, h, dpi){
           
        $.writeln("w:"+w+" h:"+h+" dpi:"+dpi);
       var project_doc =  app.documents.add(w*4, h*4, dpi, "TILE_PROJECTION", NewDocumentMode.RGB, DocumentFill.WHITE);
       return project_doc;
    }
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
   function fillPatern(patternName){
        
       //  current_doc.selection.selectAll();
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
    btn_1.onClick = function () {

        app.documents.add(); // adds a new document
        app.activeDocument.activeLayer.applyAddNoise (400, NoiseDistribution.GAUSSIAN, true); //create noise
    }
    btn_2.onClick = function () {

        var current_doc = app.activeDocument;
        if (current_doc == undefined) return false;
        definePattern("TILE_PROJECTION_PATTERN");
        var w = current_doc.width;
        var h = current_doc.height;
        var dpi = current_doc.resolution;
        var mode = current_doc.mode;
        var project_doc = createProjectDoc(w, h, dpi);
        $.writeln("project_doc w:"+project_doc.width+" h:"+project_doc.height);
        var new_layer = addLayer(project_doc, "TILE_PROJECT");
        fillColor (project_doc, new_layer, 255, 255, 255);
        
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
        
        //addStylePattern(project_doc, new_layer);
        //fillPattern("TILE_PROJECTION_PATTERN");
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
  
current_doc.artLayers["Background"].copy() //Using the copy merged command/method
project_doc.paste()
  
 alert (imgD.Width.as("px"));
//target text layer
var layerRef = app.activeDocument.layers.getByName("Text");
app.activeDocument.close();
*/