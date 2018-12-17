fn replaceCBoxSelectedItem sender str =
(
	local sel_index = sender.selectedIndex
	sender.items.RemoveAt sel_index
	sender.items.Insert sel_index (dotNetObject "System.String" str)
	sender.SelectedIndex = sel_index
)

sender = mcSaveProfileAsDialog.tag.value.cbox
replaceCBoxSelectedItem sender "Mod"



rollout dotnetMaxComboBoxDialog "Combo Box Test:" width:240 height:332
(
	dotNetControl textBox "textbox" pos:[8,20] width:224 height:20
	dotNetControl listbox "listbox" pos:[8,44] width:224 height:284
	fn dotNetArray mxsArray = 
  	(
		local netArray = dotNetObject "System.String[]" mxsArray.count
  		for i=1 to mxsArray.count do 
  		(
  			local str = dotNetObject "System.String" mxsArray[i]
  			local indx = dotNetObject "System.Int32" (i-1)
  			netArray.SetValue str indx
  		)
  		netArray
  	)
	fn fillListBox =
	(
		--generate random array
		local upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		local lower="abcdefghijklmnopqrstuvwxyz"
		local arr = for i = 1 to 100 collect \
		upper[random 1 upper.count] +
		lower[random 1 upper.count] +
		lower[random 1 upper.count] +
		lower[random 1 upper.count] +
		lower[random 1 upper.count]
		
		listbox.items.addrange(dotNetArray arr)
		listbox.Sorted = true
	)
	fn lowerCase text =
	(
		local upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		local lower="abcdefghijklmnopqrstuvwxyz"
		new_text = ""
		for i = 1 to text.count do
		(
			local column = findString upper text[i] 
			if column == undefined
			then new_text += text[i]
			else new_text += lower[column]
		)
		new_text
	)
	fn compareTexts textArray text ignoreCase:false =
	(
		for i = 1 to textArray.count do
		(
			if  textArray[i].count < text.count do return 0
			local text_part = subString textArray[i] 1 text.count
			if ignoreCase do
			(
				text_part = lowerCase text_part
				text      = lowerCase text 
			)
			format "text_part:%\ttext:%\n"  text_part text 
			if text_part == text do return i
		)
		return 0
	)
	fn searchInListbox text =
	(
		--mc2System.show listbox
		local listbox_items = for i = 0 to listbox.Items.Count-1 collect listbox.Items.Item[i]
		local row = compareTexts listbox_items text ignoreCase:true
		if row != 0 do listbox.SelectedIndex = row-1
	)
	on dotnetMaxComboBoxDialog open do
	(
		fillListBox()
		setFocus textBox
	)
	on textBox keyPress arg do 
	(
		--if not backspace pressed
		searchInListbox (textBox.text + (if arg.KeyChar != "" then arg.KeyChar else ""))
	)
)
createDialog dotnetMaxComboBoxDialog


---OR

(
rollout dotnetMaxComboBoxDialog "Combo Box Test:" width:240 height:332
  (
	local items = #()
  	dotNetControl textBox "textbox" pos:[8,20] width:224 height:20
  	dotNetControl listbox "listbox" pos:[8,44] width:224 height:284
  	fn dotNetArray mxsArray = 
  	  (
  		local netArray = dotNetObject "System.String[]" mxsArray.count
  		  for i=1 to mxsArray.count do 
  		  (
  			  local str = dotNetObject "System.String" mxsArray[i]
  			  local indx = dotNetObject "System.Int32" (i-1)
  			  netArray.SetValue str indx
  		  )
  		  netArray
  	  )
  	fn fillListBox =
  	(
  		--generate random array
  		local upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  		local lower="abcdefghijklmnopqrstuvwxyz"
  		local arr = for i = 1 to 100 collect \
  		upper[random 1 upper.count] +
  		lower[random 1 upper.count] +
  		lower[random 1 upper.count] +
  		lower[random 1 upper.count] +
  		lower[random 1 upper.count]
  		
  		listbox.items.addrange (dotNetArray arr)
  		listbox.Sorted = true
		items = arr
  	)
	
  	fn searchInListbox txt = --made by Akram
  	(
  		--mc2System.show listbox
		tempAry = #()
		pat = txt + "*"
		for i in items do
		(
			if matchPattern i pattern:pat do
			(
				append tempAry i
			)
		)
		
		tempAry
  	)
	
  	on dotnetMaxComboBoxDialog open do
  	(
  		fillListBox()
  		setFocus textBox
  	)
	
  	on textBox keyUp arg do 
  	(
		--if not backspace pressed
		txt = textBox.text
		
		list = searchInListbox txt

		if txt != "" then
		(
			listbox.items.clear()
			listbox.items.addrange (dotNetArray list)
			if list.count != 0 then	listbox.selectedIndex = 0
		)
		else
		(
			listbox.items.clear()
			listbox.items.addrange (dotNetArray items)
			listbox.selectedIndex = 0
		)
  	)
  )
  createDialog dotnetMaxComboBoxDialog
  
  ----
  

rollout dotNetComboBoxTest ".NET ComboBox Test" width:200 height:40
(
	dotNetControl comboBox "System.Windows.Forms.ComboBox" pos:[10,8] width:180 height:21
	fn dotNetArray mxsArray = 
	(
		netArray = dotNetObject "System.String[]" mxsArray.count
		for i=1 to mxsArray.count do 
		(
			str = dotNetObject "System.String" mxsArray[i]
			indx = dotNetObject "System.Int32" (i-1)
			netArray.SetValue str indx
		)
		netArray
	)
	on dotNetComboBoxTest open do
	(
		tItems=#("Left","Center","Right")
		comboBox.Items.AddRange (dotNetArray tItems)
		
		comboBox.SelectedIndex = 0
		--ComboBoxStyle = dotNetClass "System.Windows.Forms.ComboBoxStyle"
		--comboBox.DropDownStyle = ComboBoxStyle.DropDownList
		comboBox.DropDownStyle = comboBox.DropDownStyle.DropDownList
	)
	on comboBox SelectedValueChanged do
	(
		if comboBox.SelectedIndex != -1 then
		print comboBox.SelectedItem
	)
)

try(destroyDialog dotNetComboBoxTest)catch()
createDialog dotNetComboBoxTest