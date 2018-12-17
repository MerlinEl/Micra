(dotNetClass "System.IO.Path").GetFileName
(dotNetClass "System.IO.FileAccess").Read

fileInfo = dotNetObject "System.IO.FileInfo" fileName


local ofd = dotnetobject "System.Windows.Forms.OpenFileDialog"
 ofd.Filter = "XML Files (*.xml)|*.xml"
 ofd.RestoreDirectory = false			
 ofd.multiselect = true
  			
 if ofd.showDialog() == (dotNetClass "System.Windows.Forms.DialogResult").OK then (
   local sFile = ofd.fileNames
   -- Process the file array here...
 )
 
 --get bitmap info
tag = mcDgalleryDialog.flp_cat.controls.item 1 --dotNetObject:System.Windows.Forms.Button
tag.image -- dotNetObject:System.Drawing.Bitmap
fileInfo = dotNetObject "System.IO.FileInfo" tag.name--(tag.image.ToString())
fileInfo.Extension
fileInfo.name
fileInfo.FullName
fileInfo.Directory
fileInfo.Exists
fileInfo.DirectoryName