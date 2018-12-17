--Loading the 3ds Max FBX Plug-in using MAXScript
pluginManager.loadClass FBXEXPORTER
pluginManager.loadClass FBXIMPORTER 

--FBXExporterSetParam [arg] [value]
FBXExporterGetParam
--Name  	--Value
Animation  	True or false
ASCII 	True or false
AxisConversionMethod 	"None", "Animation", or "Fbx_Root"
BakeAnimation 	True or false
Bip2FBX 	True or false
Cameras 	True or false
ColladaTriangulate 	True or false
ColladaSingleMatrix 	True or false
ColladaFrameRate 	Float (in frames)
Convert2Tiff 	True or false
ConvertUnit 	"mm" or "cm" or "dm" or "m" or "km" or "in" or "ft" or "yd"
EmbedTextures 	True or false
FileVersion 	"FBX200900" or "FBX200611" or "FBX200608" or "FBX200602_MB75" or "FBX200508_MB70" or "FBX60_MB60" or "FBX53_MB55"
FilterKeyReducer 	True or false
ForceNormalsByControlPoint 	True or false
GeomAsBone 	True or false
Lights 	True or false
LoadImportPresetFile 	"x" where x is the location of the preset file.
NormalsPerPoly 	True or false
PointCache 	True or false
Resampling 	Float
ResetExport 	No value
ScaleFactor 	Float
SelectionSet 	Name of the selection set to use
Shape 	True or false
Skin 	True or false
ShowWarnings 	True or false
UpAxis 	"Y" or "Z"

--FBXImporterSetParam [arg] [value]
FBXImporterSetParam
--Name  	--Value
Animation  	True or false
AxisConversion 	True or false
Cameras 	True or false
ConvertUnit 	"mm" or "cm" or "dm" or "m" or "km" or "in" or "ft" or "yd"
FilterKeyReducer 	True or false
FilterKeySync 	True or false
ImportBoneAsDummy 	True or false
KeepFrameRate 	True or false
Lights 	True or false
LoadImportPresetFile 	"x" where x is the location of the preset file.
Markers 	True or false
Mode 	#create (Add to scene)#exmerge (Update scene elements)#merge (Add and Update scene elements)
PointCache 	True or false
Resampling 	Float
ResetImport 	No value
ScaleConversion 	True or false
ScaleFactor 	Float
Shape 	True or false
Skin 	True or false
SmoothingGroups 	True or false
TakeIndex 	An integer number from 1 to the number of takes in the FBX file. This parameter is only available for setting.
UpAxis 	"Y" or "Z"


--examples
FBXImporterSetParam "Mode" #merge
FBXImporterSetParam "Skin" true
FBXImporterSetParam "Animation" false