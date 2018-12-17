
dt= dotnetobject "DataObject" 
mc2system.show dt

dt.SetData "val" (dotNetObject "System.Int32" 1.25)
dt.SetData (dotNetObject "System.Int32" 1477)
dt.GetData "val"

dt.SetText "abcd"
dt.GetText()

dt.GetFormats()
dt.GetFormats (dotnetObject "System.Boolean" true)
dt.GetDataPresent "val" (dotnetObject "System.Boolean" true) --check if contains data "val"

(dotnetclass "DataFormats").Text
(dotnetclass "DataFormats").CommaSeparatedValue

((dotnetclass "DataFormats").Text) "alialia aaaaa"

 
dt.SetData "iii" indx 
dt.GetData "iii"


mc2system.show (dotnetClass "System.Type")

f.DataObject
dob=dotnetObject "System.Windows.Forms.DataObject"
dob.DataObject

  System.Windows.Forms.DataObject()
  System.Windows.Forms.DataObject <System.Object>data
  System.Windows.Forms.DataObject <System.String>format <System.Object>data

mc2_Dialog_F.DataBindings.Add "dt" dt "dt.GetData"