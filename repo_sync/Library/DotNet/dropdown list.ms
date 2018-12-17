ddlMainClass = dotNetObject "ComboBox",

mcs.ddlMainClass.Items.addRange #(1,2,3)
mcs.ddlMainClass.SelectedIndex = 0
mcs.ddlMainClass.SelectedItem = mcs.ddlMainClass.items.item[0]


 mcDgalleryDialog.tag.value.ddlMainClass.findString (dotnetObject "system.string" "Beaking")
  mcDgalleryDialog.tag.value.ddlMainClass.findString "Animation" -- get number 0 - infinete or -1 == undefined
 mcDgalleryDialog.tag.value.ddlMainClass.items.item[1]

Ok, I found a work-around for placing the textbox:

 rollout rollo_test "test" (
 dotNetControl dnc_AllCtrls "System.Windows.Forms.Panel" pos:[0,0] width:270 height:210
 dotNetControl dnc_scSetCtrl "System.Windows.Forms.Panel"
 dotNetControl dnc_scSet "System.Windows.Forms.TextBox" pos:[0,0] width:109 height:17

 on rollo_test open do (
 dnc_AllCtrls.controls.add dnc_scSetCtrl
 dnc_scSetCtrl.Location = dotNetObject "System.Drawing.Point" 83 35
 dnc_scSetCtrl.Size = dotNetObject "System.Drawing.Size" 192 55
 dnc_scSetCtrl.controls.add dnc_scSet
 dnc_scSet.borderstyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle 

 dnc_ComboBox = dotNetObject "System.Windows.Forms.ComboBox"
 dnc_ComboBox.Location = dotNetObject "System.Drawing.Point" 20 35
 dnc_ComboBox.Size = dotNetObject "System.Drawing.Size" 51 17
 ComboBoxStyle = dotNetClass "System.Windows.Forms.ComboBoxStyle"
 dnc_ComboBox.DropDownStyle = ComboBoxStyle.DropDownList
 dnc_AllCtrls.controls.add dnc_ComboBox
 )
 )
 createDialog rollo_test width:270 height:210 style:#(#style_toolwindow, #style_sysmenu)
 gc()

 And now, hopefully, everything will be pretty and behaves nicely...
 
 
 
 comboBox.Items.Add (dotNetObject "System.String" "Text 1")
str = dotnetObject "system.string" "myString"
 
 on comboBox SelectedValueChanged do
 (
 if comboBox.SelectedIndex != -1 then
 print comboBox.SelectedItem
 )