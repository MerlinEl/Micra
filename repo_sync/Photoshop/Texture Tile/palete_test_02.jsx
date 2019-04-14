#target photoshop
function WinObject() {
  // Long resource String for 'palette' Window
  var windowResource = "palette {"
        windowResource += "orientation: 'column',"
        windowResource += "alignChildren: ['fill', 'top'],"
        windowResource += "preferredSize:[300, 130],"
        windowResource += "text: 'ScriptUI Window - palette',"
        windowResource += "margins:15," 
        windowResource += "sliderPanel: Panel {"
        windowResource +=  "orientation: 'row',"
        windowResource += "alignChildren: 'right',"
        windowResource += "margins:15,"
        windowResource += "text: ' PANEL ',"
        windowResource += "st: StaticText { text: 'Value:' },"
        windowResource += "sl: Slider { minvalue: 1, maxvalue: 100, value: 30, size:[220,20] },"
        windowResource += "te: EditText { text: '30', characters: 5, justify: 'left'}"
        windowResource += "}"
        windowResource += "bottomGroup: Group{"
        windowResource += "cd: Checkbox { text:'Checkbox value', value: true },"
        windowResource += "cancelButton: Button { text: 'Cancel', properties:{name:'cancel'},  size: [120,24], alignment:['right', 'center'] },"
        windowResource += "applyButton: Button { text: 'Apply', properties:{name:'ok'}, size: [120,24], alignment:['right', 'center'] },"
        windowResource += "}"
        windowResource += "}"
    var win = new Window(windowResource);
    win.bottomGroup.cancelButton.onClick = function() { win.close() };
    win.bottomGroup.applyButton.onClick = function() { win.close() };

    //Add Buttons
    var btn_1 = win.add ("button", undefined, "Create New Document");
    //Define Functions
    btn_1.onClick = function () {

        app.documents.add(); // adds a new document
        app.activeDocument.activeLayer.applyAddNoise (400, NoiseDistribution.GAUSSIAN, true); //create noise
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