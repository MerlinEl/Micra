#target photoshop
// palette same as before
var windowResource = "palette";
var win = new Window(windowResource);
win.show();

app.documents.add(); // adds a new document
app.activeDocument.activeLayer.applyAddNoise (400, NoiseDistribution.GAUSSIAN, true)
for (i = 0; i < 3; i++) { // Blurs it 3 times
    app.activeDocument.activeLayer.applyGaussianBlur(1);
    $.sleep (2000); // waits 2 seconds
    app.refresh(); // refreshes PS
}