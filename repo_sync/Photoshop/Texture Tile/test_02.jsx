#target photoshop
var w = new Window ('dialog', 'Texture Tile');
w.group = w.add ('group');
w.buttons = w.add ('group {alignment: "right"}');
w.ok = w.buttons.add ('button {text: "OK", enabled: false}');
w.buttons.add ('button {text: "Cancel"}');
//Add Buttons
var btn_1 = w.add ("button", undefined, "Create New Document");

//Define Functions
btn_1.onClick = function () {
    
    app.documents.add(); // adds a new document
    app.activeDocument.activeLayer.applyAddNoise (400, NoiseDistribution.GAUSSIAN, true); //create noise
}


w.show();

/*
w.show(this);
this.Enabled = false;
$.writeln(w.show());
app.refresh() ;
*/