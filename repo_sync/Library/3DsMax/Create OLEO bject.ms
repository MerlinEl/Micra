PSDapp=CreateOLEObject"Photoshop.Application"
PSDapp.ActiveDocument.Selection.Copy()
ActiveDocument.Selection.Paste()  

PSDapp.ActiveDocument.Selection.Paste()
PSDapp.ActiveDocument.Paste()

mobj = createOLEObject  ("Max.Application")
mobj = createOLEObject ("Shell.Application")
mobj.minimizeAll()
--mobj.undoMinimizeAll()
releaseOLEObject mobj