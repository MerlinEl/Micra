

f = dotnetobject "form"
f.name = "formicka"

b = dotnetobject "button"
b.name = "butonik"

str = dotnetObject "System.String" f.name
indx = dotNetObject "System.Int32" 45.36

strArray = dotNetObject "System.String[]" 2
str1 = dotnetObject "System.String" "zero"
str2 = dotnetObject "System.String" "one"
strArray.SetValue str1 0
strArray.SetValue str2 1
strArray.get 0
strArray.get 1

objArray = dotNetObject "object[]" 2
objArray.SetValue indx 1

img_list = (dotNetObject "ImageList")

bs= (dotNetObject "BindingSource")
bs.Dispose()
bs.Add indx
bs.Add strArray
bs.item[0][1]

columns = (dotNetObject "BindingSource")
columns.add (dotNetObject "System.Drawing.Point" 8.25 8.896)
columns.item[1].y

--ADD
container = dotnetObject "System.ComponentModel.Container"
container.dispose() --empty
container.add f f.name
container.add b b.name
container.add b
container.add img_list "img_list"
container.add bs "columns count"
container.add data
container.add pt2 "size"

container.add indx "value" --???
container.add str "string" --???
container.add strArray "str array" --???
container.add #("e","f") "str array" --???

container.Components.count

container.Components.item[0].name 
container.Components.item[1].name
container.Components.item[1].handle


container.Components.item ( "formicka" )
container.Components.item ( "value" ) --???
f.container.components.item "img_list"
(f.container.components.item "columns count").get_List()
(f.container.components.item "columns count").count
(f.container.components.item "columns count").Item[0]
(f.container.components.item "columns count").List
(f.container.components.item "columns count").RemoveAt 0
(f.container.components.item "columns count").Insert 0 (dotNetObject "System.Int32" 42)


mc2system.show container


f.controls.add (f.container.components.item "butonik")
f.controls.item[0]
f.controls.remove (f.container.components.item "butonik")



-----------------------------
F.BindingContext --: <System.Windows.Forms.BindingContext>

F.Controls --: <System.Windows.Forms.Control+ControlCollection>, read-only
(F.Container.components.item "columns count").item[0][1] --: <System.ComponentModel.IContainer>, read-only

F.AccessibleName --: <System.String>
F.AccessibleRole --: <System.Windows.forms.AccessibleRole>
F.AccessibilityObject --: <System.Windows.Forms.AccessibleObject>, read-only

mc2_Dialog_F.ResetBindings()
bi= mc2_Dialog_F.DataBindings --: <System.Windows.Forms.ControlBindingsCollection>, read-only
mc2system.show bi
mc2_Dialog_F.DataBindings.Add "1" indx "get"

bi = dotnetObject "System.Windows.Forms.Binding[]" 2

ic = dotnetObject "System.ComponentModel.IComponent[]" 5
ic.GetValue 1

Collection = dotnetObject "System.ComponentModel.Container"
imageCollection =dotnetobject "DevExpress.Utils.ImageCollection"(Collection)
f.control.Images =imageCollection
