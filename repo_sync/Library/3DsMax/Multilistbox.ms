rollout test "test"
	(
	MultiListBox mlb "MultiListBox" items:#("A","B","C") selection:#(1,3)
	on mlb selected val do
		( 
		format "selected: % - %\n" val mlb.selection[val]
		)
	on mlb doubleclicked val do
		( 
		 format "doubleclicked: % - %\n" val mlb.selection[val]
		)
	on mlb selectionEnd do
		( 
		format "selectionEnd: %\n" mlb.selection
		)
	)
rof=newrolloutfloater "tester" 200 300
addrollout test rof

test.mlb.items
test.mlb.selection=1
test.mlb.selection=#(1,3)
test.mlb.selection=#{}
----------------------------------------------------------------------------
delete (getNodeByName LBox.selected) --delete from selection 
ListObj.LBox.items = $sphere20 --put a object name in LBox
ListObj.LBox.selection = 1 --select nLabels from LBox
ListObj.LBox.selection --get number of selecion from LBox
select (getNodeByName ListObj.LBox.items[1]) --select first object list in scene
<void>doPutToObjectDialog()
----------------------------------------------------------------------------
(x = for i in 1 to $objects.count collect i) --collect object numbers as array #{1,2,3...atd}
----------------------------------------------------------------------------
BoxItms = LBox.items --Get the items into a temporary array:
deleteItem BoxItms nLabel --the local variable nLabel contains the index!
LBox.items = BoxItms --Assign the result back to the items array:
----------------------------------------------------------------------------
				ListObj.LBox.selection = oVisNum
				LBoxSelNames = for i in (ListObj.LBox.selection as array) collect (ListObj.LBox.items[i])
				ListObj.LBox.items = sort (ListObj.LBox.items)
				LBoxNamesNum = for i in (LBoxSelNames) collect (findItem ListObj.LBox.items i)
				ListObj.LBox.selection = LBoxNamesNum


LBoxSelNames = for i in (ListObj.LBox.selection as array) collect (ListObj.LBox.items[i])
LBoxNamesNum = for i in (LBoxSelNames) collect (findItem ListObj.LBox.items i) --show number from name
--visible objects
AllObjectsNames = sort (for i in objects collect i.name)
(ListObj.LBox.items[(ListObj.LBox.selection as array)[1]]) --show name in selection
x = ("$"+AllObjectsNames[4])
y = (execute x)
y.IsHidden
select y
--Tests----------------------------------------------------------------------
------item_list = ListObj.Lbox.items --#("Sphere06", "Sphere09", "Sphere02")
--A---selected_items = ListObj.LBox.selection --#{1..5}
--B---itms_count = item_list.count as string --11
--B---ListObj.Lbox.items.count --11
------unselected_items = 
--A---oVisNum --#{1, 4..10}
--visible = ovisnum
--all_names = 
--if Lbox.selection = false then hide 
--x = ListObj.LBox.selection
--print x
----------------------------------------------------------------------------
				local Listbox_Items_UnSel=#()					
				for i in 1 to isoDialog.LBox.items.count collect
		 			(if (isoDialog.LBox.selection[i] != true) then (Listbox_Items_UnSel[i] = i))
				while (findItem Listbox_Items_UnSel undefined) > 0 do
					(DeleteItem Listbox_Items_UnSel (findItem Listbox_Items_UnSel undefined) )
				isoDialog.LBox.selection=Listbox_Items_UnSel
				local Inv_Sel_Obj =(for i in Listbox_Items_UnSel collect getNodeByName isoDialog.LBox.items[i])
				select Inv_Sel_Obj 
				
	/* Function for collect selected names in listbox */
fn ListBoxItemsSel Dia = 
	(
	local x= "for i in 1 to " + Dia +".items.count where " + Dia + ".selection[i] collect " + Dia + ".items[i]"
	execute x
	)
/* Call: ListBoxItemsSel "isoDialog.LBox" */


(for i in isoDialog.LBox.selection do unhide (getNodeByName isoDialog.LBox.items[i]))


AllNumCount=(for i in 1 to isoDialog.LBox.items.count collect i) as bitarray
SelNumCount=isoDialog.LBox.selection
UnsNumCount=AllCount-SelCount
for i in AllNumCount where (getNodeByName isoDialog.LBox.items[(SelNumCount as array)[i]]).isHidden collect i