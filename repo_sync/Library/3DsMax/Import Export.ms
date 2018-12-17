--format list

3D Studio Mesh (*.3DS,*.PRJ)
Adobe ILLustrator (*.AI)
Autodesk Colllada (*.DAE) 
LandXML /DEM / DFF (*.DEM,*.XML,*.DDP)
AutoCAD Drawing (*.DWG,*.DXF)
Legacy AutoCAD (*.DWG)
Autodesk (*.FBX)
Motion Analysis HTR File (*.HTR)
IGES (*.IGE,*.IGS,*.IGES)
Autodesk Inventor (*.IPT,*,IAM)
Lightscape (*.LS,*.VW,*.LP)
WaveFront Material (*.MTL)
WaveFront Object (*.OBJ)
3D Studio Shape (*.SHP)
StereoLithi (*.STL)
Motion Analysis TRC File (*.TRC)
WRML (*.WRL,*.WRZ)
VIZ Material XML Import (*.XML)
All Formats
All Files (*.*)


file_to_import = getOpenFileName caption:"Select File To Import" filename:maxfilepath \
types:
(
"3D Studio Mesh (*.3DS,*.PRJ)|*.3DS,*.PRJ|"+
"Adobe ILLustrator (*.AI)|*.AI|"+
"Autodesk Colllada (*.DAE)|*.DAE|"+
"LandXML /DEM / DFF (*.DEM,*.XML,*.DDP)|*.DEM,*.XML,*.DDP|"+
"AutoCAD Drawing (*.DWG,*.DXF)|*.DWG,*.DXF|"+
"Legacy AutoCAD (*.DWG)|*.DWG|"+
"Autodesk (*.FBX)|*.FBX|"+
"Motion Analysis HTR File (*.HTR)|*.HTR|"+
"IGES (*.IGE,*.IGS,*.IGES)|*.IGE,*.IGS,*.IGES|"+
"Autodesk Inventor (*.IPT,*,IAM)|*.IPT,*,IAM|"+
"Lightscape (*.LS,*.VW,*.LP)|*.LS,*.VW,*.LP|"+
"WaveFront Material (*.MTL)|*.MTL|"+
"WaveFront Object (*.OBJ)|*.OBJ|"+
"3D Studio Shape (*.SHP)|*.SHP|"+
"StereoLithi (*.STL)|*.STL|"+
"Motion Analysis TRC File (*.TRC)|*.TRC|"+
"WRML (*.WRL,*.WRZ)|*.WRL,*.WRZ|"+
"VIZ Material XML Import (*.XML)|*.WRL,*.WRZ|"+
"All Formats (*.*)|*.*|"+
"All Files (*.*)|*.*|"
)