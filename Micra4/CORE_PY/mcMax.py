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
def exportSelectionToFBX(fpath, fname):
	MaxPlus.Core.EvalMAXScript("pluginManager.loadClass FBXEXPORTER")
	MaxPlus.Core.EvalMAXScript("FBXExporterSetParam \"BakeAnimation\" False")
	MaxPlus.Core.EvalMAXScript("exportFile \"test.fbx\"")  

	MaxPlus.Core.EvalMAXScript("pluginManager.loadClass FBXEXPORTER")
	MaxPlus.Core.EvalMAXScript('FBXExporterSetParam "ASCII" True')
	MaxPlus.Core.EvalMAXScript('FBXExporterSetParam "Animation" False')
	MaxPlus.Core.EvalMAXScript('FBXExporterSetParam "EmbedTextures" False')



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