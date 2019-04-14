#target photoshop
var w = new Window ('dialog', '');
w.group = w.add ('group');
w.group.add ('statictext {text: "New name:"}');
w.input = w.group.add ('edittext {characters: 20, active: true}');
w.buttons = w.add ('group {alignment: "right"}');
w.ok = w.buttons.add ('button {text: "OK", enabled: false}');
w.buttons.add ('button {text: "Cancel"}');
w.input.onChanging = function () {
    
    w.ok.enabled = !app.activeDocument.hyperlinkTextDestinations.item
    (w.input.text).isValid;
    }
    if (w.show() == 1 && w.input.text.length > 0) {
    app.activeDocument.hyperlinkTextDestinations.add (app.selection[0],
    {name: w.input.text});
}