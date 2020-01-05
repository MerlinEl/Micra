import MaxPlus
import pymxs as mxs

def getSelection():
	return MaxPlus.SelectionManager.GetNodes()

def deselectAll():
	MaxPlus.SelectionManager.ClearNodeSelection()

def exportSelectionAsFBX(fpath):
	mxs.runtime.exportFile (
		#r''+fpath,
		fpath,
		mxs.runtime.Name("noPrompt"), 
		selectedOnly=True,
		Animation= False,		
		using='FBXEXP'
	)

"""	
http://help.autodesk.com/view/3DSMAX/2016/ENU/

def exportSelectionToFBX(fpath, fname):
	MaxPlus.Core.EvalMAXScript("pluginManager.loadClass FBXEXPORTER")
	MaxPlus.Core.EvalMAXScript("FBXExporterSetParam \"BakeAnimation\" False")
	MaxPlus.Core.EvalMAXScript("exportFile \"test.fbx\"")  

	MaxPlus.Core.EvalMAXScript("pluginManager.loadClass FBXEXPORTER")
	MaxPlus.Core.EvalMAXScript('FBXExporterSetParam "ASCII" True')
	MaxPlus.Core.EvalMAXScript('FBXExporterSetParam "Animation" False')
	MaxPlus.Core.EvalMAXScript('FBXExporterSetParam "EmbedTextures" False')
--Geometry------------------------------------------------------------------------
	FBXExporterSetParam "SmoothingGroups" true
	FBXExporterSetParam "NormalsPerPoly" false
	FBXExporterSetParam "TangentSpaceExport" true
	FBXExporterSetParam "SmoothMeshExport" false
	FBXExporterSetParam "Preserveinstances" false
	FBXExporterSetParam "SelectionSetExport" false
	FBXExporterSetParam "GeomAsBone" false
	FBXExporterSetParam "ColladaTriangulate" true
	FBXExporterSetParam "PreserveEdgeOrientation" true
--Animation------------------------------------------------------------------------
	FBXExporterSetParam "Animation" false
--Cameras------------------------------------------------------------------------
	FBXExporterSetParam "Cameras" false
--Lights------------------------------------------------------------------------
	FBXExporterSetParam "Lights" false
--Embed Media--------------------------------------------------------------------
	FBXExporterSetParam "EmbedTextures" false
--Units----------------------------------------------------------------------------
--Axis Conversion-----------------------------------------------------------------
	FBXExporterSetParam "AxisConversionMethod" "None"
	FBXExporterSetParam "UpAxis" "Y" 
--UI----------------------------------------------------------------
	FBXExporterSetParam "ShowWarnings" true
	FBXExporterSetParam "GenerateLog" false
--FBX File Format----------------------------------------------------------------
	FBXExporterSetParam "ASCII" true
	FBXExporterSetParam "FileVersion" "FBX201200"
--Path and file name stuff
	makeDir (maxFilePath + "FBX")
	FBXSavePath = (maxFilePath + "FBX\\" + $.name)
	exportFile FBXSavePath #noPrompt selectedOnly:true using:FBXEXP 
--to prevent the export of the cameras:
	FBXExporterSetParam "Cameras" False

MaxPlus.FileManager.ExportSelected


fm = MaxPlus.FileManager
fm.Open(MaxPlus.PathManager.GetTempDir() + r"\test3.max")
fm.Save(MaxPlus.PathManager.GetTempDir() + r"\test.max")
print fm.GetFileNameAndPath()


result = fm.DoesFileExist ( "c:\\temp")
print ("is file exist:", result)

result = fm.ExportSelected ("c:\\temp\\test_export.fbx")
print ("export file:", result)
"""