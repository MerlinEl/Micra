#target photoshop
var isDone, sTID, waitForRedraw, win, windowResource;
windowResource = "palette";
win = new Window(windowResource);
var oldInputGroup = win.add("group");
oldInputGroup.add("statictext", undefined, "Search for");
var oText = oldInputGroup.add("edittext", undefined, "Search for");
oText.characters = 25;
oText.active = true;
var newInputGroup = win.add("group");
newInputGroup.add("statictext", undefined, "Replace with");
var nText = newInputGroup.add("edittext", undefined, "Replace with");
nText.characters = 25;
nText.active = false;
var caseCheck = win.add("checkbox", undefined, "Case Sensitive?");
var bottomGroup = win.add("group");
var btnOK = bottomGroup.add("button", undefined, "OK");
var btnCancel = bottomGroup.add("button", undefined, "Cancel");
main();