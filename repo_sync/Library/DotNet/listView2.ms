/**********************************************************************
*<
FILE:   NET_ListViewWrapper.ms

DESCRIPTION: A wrapper for the .NET System.Windows.Forms.ListView control

CREATED BY: Chris P. Johnson
  
HISTORY:  Created April 18 2006

*> Copyright Autodesdk (c) 2000, All Rights Reserved.
**********************************************************************/


struct ListViewOps
(  
 m_dnColor = dotNetClass "System.Drawing.Color",
 function MXSColor_to_dotNetColor hColor =
 (
  m_dnColor.fromARGB hColor.r hColor.g hColor.b
 ),
 function dotNetColor_to_MXSColor dnColor =
 (
  local mxsCol = color (dnColor.r as integer) (dnColor.g as integer) (dnColor.b as integer)
  mxsCol
 ),
 function InitImageList lv stringFileArray pSize:0 =
 (
  --[brief] This method only adds icons and bitmaps, to an imagelist.
  --        An imagelist is a structure that manages images for a control.
  --[param] lv - The listview control. Must inherit from System.Windows.Forms.Control class.
  --[param] stringFileArray - A maxscript array containing filenames of the images to add.
  --        Must pass the string file names as a symbolic pathname: 
  --        i.e. "$ui/icons/mybitmap.bmp"
  --[param] pSize - The size of the bitmap to add. For example 16 if the image is 16 x 16 pixels.
  --[return] A System.Windows.Forms.ImageList
  local hImgList  = dotNetObject "System.Windows.Forms.ImageList"
  local imgSize   = dotNetObject "System.Drawing.Size" 16 16
  
  if pSize == 0 then
  ( 
   hImgList.imagesize = imgSize
  )
  else if (pSize > 2) then
  (
   imgSize   = dotNetObject "System.Drawing.Size" pSize pSize
   hImgList.imagesize = imgSize
  )
  
  local bColor  = dotNetClass "System.Drawing.Color"
  if pTransparentColor != undefined and (classof pTransparentColor == color) then
  ( 
   local col = pTransparentColor --temporary
   hImgList.transparentColor = bColor.fromARGB col.r col.g col.b
  ) 
  else
  (
   hImgList.transparentColor = bColor.fromARGB 125 125 125 
  )
  
  local img    = dotNetClass "System.Drawing.Image"
  
  function IsIconFile stringFileName =
  (
   local type = GetFileNameType stringFileName
   local result = false
   if type == ".ico" do ( result = true )
   result 
  )
  
  for file in stringFileArray do
  (
   fName = (symbolicPaths.expandFileName file)
   if (IsIconFile fName ) then --Add icons
   (
    local icon  = dotNetObject "System.Drawing.Icon" fName
    hImgList.images.add icon
   )
   else --or Add bitmaps
   (
    local dnBitmap = dotNetObject "System.Drawing.Bitmap" fName
    hImgList.images.add dnBitmap
   )
  )
  lv.SmallImageList = hImgList
 ),
    function AddLvItem lv                 \
                    pTextItems:#()        \
                    pChecked:  false      \
                    pHashKey:  ""         \
                    pTag:      undefined  \
                    pToolTip:  ""         \
                    pInsertAt: undefined  \
                    pImgIndex: 1          \
                    pIndent:   0 =
 (
  --[brief] This function Creates and Adds a ListViewItem to a ListView control.
  --[param] pTextItems - A maxscript array that contains the strings to put in each cell
  --                     of the listview cells which are called ListViewSubItems
  --[param] pChecked   - If true displays a checkbox to the far left of the listview item
  --[param] pHashKey   - A string used for a hash table index
  --[param] pTag       - Any maxscript / custom value to be stored in the tag property
  --[param] pToolTip   - A string to be used for the tooltip for the ListViewItem
  --[param] pInsertAt  - A number used to insert a new listviewItem in the middle of a listview.
  --[param] pImgIndex  - Index of the image to use in the embedded imagelist.
  --[param] pIndent    - A number used to specify how far to indent the text of ListViewItems.
  --[return] Returns the newly created Listview Item.
  local item = dotNetObject "System.Windows.Forms.ListViewItem" pTextItems[1]
  
  item.Checked   = (pChecked == 1 or pChecked == true)
  item.indentCount = pIndent
  
  if pHashKey == "" then
  ( item.Name = pTextItems[1] ) --Useful for fast lookup
  else ( item.Name = pHashKey )
   
  if pTag != undefined do 
  (    item.tag  = pTag   )
  item.toolTipText = pToolTip
  item.imageIndex  = pImgIndex
  
  --Inserts the first item in the pTextItems array after ListViewItem specified by 
  --the pInsertAt index.
  if (pInsertAt != undefined) and (pInsertAt > 0) then
  (
   lv.items.Insert pInsertAt item
   item.indentCount = 1
  )
  else
  (
   lv.items.add item
  )
  
  --If the pTextItems array contains more than one entry, add additional cell
  -- entryies to the listviewITem in the form of ListViewSubItem class objects.
  --Note that an extra column will have to have been added to the listview to
  -- display these.
  local count = pTextItems.count
  -- Cache this method to improve performance
  local itemSubItemsAdd = item.SubItems.add
  for i = 2 to count do
  (
   -- subItem is of class System.Windows.Forms.ListViewSubItem
   local subItem = itemSubItemsAdd pTextItems[i]
   
   if (pHashKey == "") then --Useful for fast lookup
   ( subItem.name = pTextItems[i] )
   else ( subItem.name = phashKey )
   subitem.tag = pTag
  )
  --return the listview item if the caller wants it
  item 
 ),
 function DeleteLvItem lv index =
 (
  --[brief] Deletes the specified listview item.
  --[param] lv - A System.Windows.Forms.ListView control
  --[param] index - The integer index of the item to delete
  if (index != undefined) and (index >= 0) and (index < lv.Items.count) then
  ( 
   lv.items.removeat index
  ) 
 ),

 function AddLvColumnHeader lv                \
                          pCaption: ""        \
                          pWidth: undefined =
 (
  --[brief] Adds a column header to the listview control
  --[param] lv - A System.Windows.Forms.ListView control
  --[param] pCaption - A string for the column caption
  --[param] pWidth - The horizontal size of the caption cell and column.
  if (pWidth == undefined) do
  (
   local sizeCaption = GetTextExtent pCaption
   pWidth = sizeCaption.x
   pWidth *= 2.0
  )
  
  --Adds a Column to a listview control.
  local horizontalAlignment = dotNetClass "System.Windows.Forms.HorizontalAlignment"
  lv.Columns.Add pCaption pWidth horizontalAlignment.Left
 ),
 function RefreshListView lv = 
 (
  lv.Refresh()
 ),
 function SetFontStyle pControl pStyle =
 (
  --[brief] Changes the font style. The font style is changed according to the list,
  --        but the The size and family are supposed to stay the same.
  --[param] pControl - Must inherit from the System.Windows.Forms.Control class
  --        This control must have a public font property
  --[param] pStyle - A maxscript enumeration or name indicating the style. See the
  --        case statement below for a list of possible values.
  local oldFont = pControl.font
  local oldSize = oldFont.size --as Integer
  local oldStyle= oldFont.style
   
  local fontStyle     = dotNetClass  "System.Drawing.FontStyle"
  local appliedFontStyle = undefined
  
  appliedFontStyle = case pStyle of
  (
   #bold: ( 
    if(oldStyle != fontStyle.bold) do (oldSize -= 3); 
    fontStyle.Bold      
   )
   #regular: (
    fontStyle.Regular   
   )
   #Italic:  ( 
    if (oldStyle != fontStyle.Italic) do (oldSize -= 3); 
    fontStyle.Italic    
   )
   #Strikeout:( 
    fontStyle.Strikeout 
   )
   #Underline:( 
    if (oldStyle != fontStyle.underline) do (oldSize -= 3); 
    fontStyle.Underline 
   )
   default:   ( 
    fontStyle.Regular   
   )
  )
  local highLightFont = dotNetObject "System.Drawing.Font" oldFont.fontFamily oldSize appliedFontStyle
  pControl.font = highLightFont
 ),
 function SetForeColor pControl pColor =
 (
  --[brief] Changes the text color
  --[param] pControl - A control object which must inherit from the System.windows.forms.control class
  --[param] pColor   - A maxscript color value
  --[return] Returns the equivalent System.Drawing.Color
  pControl.foreColor = MXSColor_to_dotNetColor pColor
 ),
 function HighLightLvItem pControl pStyle pColor =
 (
  --[brief] Highlights the font of a system.windows.forms.Listview class object.
  --[param] pControl - A control object which must inherit from the System.windows.forms.control class
  --[param] pStyle   - A maxscript name specifying the font style. See the SetFontStyle function for details.
  SetFontStyle pControl pStyle 
  SetForeColor pControl pColor
 ),
 ---------------------------------------
 -- Mass Deletion Methods 
 ---------------------------------------
 function ClearColumns lv = 
 (
  lv.columns.clear() 
 ),
 function ClearLvItems lv =
 (
  lv.items.clear() 
 ),
 ---------------------------------------
 -- Selection Methods 
 ---------------------------------------
 function GetLvSelection lv =
 (
  --[brief] Returns a maxscript array of selected ListViewItems.
  --    The SelectedItems property of a listview is of class 
  --    System.Windows.Forms.SelectedListViewItemCollection
  --[param] lv - A ListView control
  --[return] A maxscript array of System.Windows.Forms.ListViewItem objects
  local sel = lv.selectedItems
  local result = #()
  if sel.count != 0 then
  (
   local nCount = sel.count - 1 --.NET arrays are zero based
   result = for i = 0 to nCount collect ( sel.item[i] )
  )
  else
  (
   result = #()
  )
  result
 ),
 function GetLvSingleSelected lv =
 (
  --[brief] Returns a single selected ListViewItem 
  --        from the ListView Control
  --[return] An item of the System.Windows.Forms.ListViewItem class
  local result = GetLvSelection lv
  if (result.count > 0) then
   result[1] 
  else
   undefined
 ),
 function GetSelectedIndex lv =
 (
  --[brief] Gets the index of the selected listview item. Only one 
  --        item can be selected at one time.
  --[param] lv - The System.Windows.Forms.ListView class control
  --[return] The integer index of the selected item in listview control
  local result = -1
  if (lv.SelectedIndices.count == 1) then
  (
   result = lv.SelectedIndices.item[0]
  )
  result
 ),
 function SelectLvItem lv index =
 ( 
  --[brief] Selects an Item in the Listview by integer index
  --[param] lv - The System.Windows.Forms.ListView class control
  --[param] index - An integer of the item to select. Note that
  --        .NET arrays are zero based.
  --[return] Returns the selected ListViewItem if the selection was
  --         valid, otherwise it returns undefined
  local result = undefined
  if (index != undefined) and (lv.items.count != 0) and (index != -1) then
  (
   if ( index >= lv.Items.count) do 
   (
    index = lv.Items.count - 1 -- off the end, use last item
   )
   li = lv.Items.item[ index ]
   if li != undefined do 
   (
    li.selected = true
    result = li
   )
  )
  else if (index == -1) do
  (
   lv.selectedItems.clear() 
  )
  result
 ),

 ---------------------------------------
 -- Cell Operations
 ---------------------------------------
 function GetLvItemName lv nRow nColumn =
 (
  --[brief] Gets the text from the listviewItem or subItem. The listview
  --        must be in report mode, which means displaying its data in a 
  --        grid format. All .NET arrays are zero based.
  --[param] lv - The System.Windows.Forms.ListView class control
  --[param] nRow - An integer for the row, or ListViewItem to query
  --[param] nColumn - An integer for the column (if any) to help locate the cell
  --        by an x y coordinate system.
  --[return] A string from the specified cell.
  local result = ""
  if nRow >= 0 and \
     nRow < lv.Items.count and \
     nColumn >= 0 and \
     nColumn < (lv.columns.count) then
  (
   local li = lv.Items.item[ nRow ]
   local si = li.subItems.item[ncolumn]
   result = si.text
  )
  else
  (
   result = ""
  )
  
  result
 ),
 function SetLvItemName lv nRow nColumn newName =
 (
  --[brief] Sets the text from the listviewItem or subItem. The listview
  --        must be in report mode, which means displaying its data in a 
  --        grid format. All .NET arrays are zero based.
  --[param] lv - The System.Windows.Forms.ListView class control
  --[param] nRow - An integer for the row, or ListViewItem to query
  --[param] nColumn - An integer for the column (if any) to help locate the cell
  --        by an x y coordinate system.
  --[param] newName - A string to place into the specified cell.
  if nRow >= 0 and \
     nRow < lv.Items.count and \
     nColumn >= 0 and \
     nColumn < lv.columns.count then
  (
   local li = lv.Items.item[ nRow ]
   local si = li.subItems.item[ncolumn]
   si.text = newName as string
  )
 ),
 ---------------------------------------
 -- ListViewItem Operations
 ---------------------------------------
 function GetLvItemCheck lv index =
 (
  --[brief] Queries whether a ListViewItem is checked or not. A listview Item
  --        must be first displaying checkboxes for this to take effect.
  --        Note: All .NET arrays are zero based.
  --[param] lv - The System.Windows.Forms.ListView class control
  --[param] index - The index of the listview Item to query
  --[return] true if checked, false if not checked
  local result = false
  if index >= 0 and index < lv.Items.count then
  (
   li = lv.Items.item[ index ]
   result = li.checked
  )
  result
 ),
 function SetLvItemCheck lv index newState =
 (
  --[brief] Sets a ListViewItems checked state. A listview Item
  --        must be first displaying checkboxes for this to take effect.
  --        Note: All .NET arrays are zero based.
  --[param] lv - The System.Windows.Forms.ListView class control
  --[param] index - The index of the listview Item to query
  --[param] newState - A boolean value that contains the state.
  if index >= 0 and index < lv.Items.count then
  (
   li = lv.Items.item[ index ]
   li.checked = newState
  )
 ),
 function SetLvItemRowColor lv index newColor =
 (
  --[brief] Sets the row color for a listview control.
  --[param] lv - The System.Windows.Forms.ListView class control
  --[param] index - The index of the listview Item to modify
  --[param] newColor - A maxscript color
  if index >= 0 and index < lv.Items.count then
  (
   local li = lv.Items.item[ index ]
   li.ForeColor = MXSColor_to_dotNetColor newColor
   --cache these for fast lookup
   local si = li.SubItems.item
   local siCount = (li.SubItems.count - 1)
   local newNETColor = MXSColor_to_dotNetColor newColor
   for i = 0 to siCount do
   (
    si[i].ForeColor = newNETColor
   )
  ) 
 ),
 function GetLvItemCount lv =
 (
  lv.items.count 
 ),
 function GetLvItems lv =
 (
  --[brief] Returns a maxscript array of ALL ListViewItems in the listview control
  --[param] lv - The System.Windows.Forms.ListView class control
  --[return] A maxscript array of System.Windows.Forms.ListViewItem objects
  local result = #()
  local nCount = lv.items.count - 1 --.NET arrays are zero based
  local lvItems = lv.items
  for i = 0 to nCount do
  (
   append result lvItems.item[i]
  )
  result
 ),
 function GetLvItemByName lv stringName =
 (
  --[brief] Searchs the listview control for any listview Items that have
  --        a name matching the passed in string. 
  --[param] lv - The System.Windows.Forms.ListView class control
  --[param] stringName - The string to search for
  --[return] An array of all items with the stringName, or undefined 
  --         if no items were found
  local result = lv.Items.Find stringName true
  if result.count == 0 do (result = undefined)
  result
 ),
 ---------------------------------------
 -- The Grand Initialization Method
 ---------------------------------------
 function InitListView lv pLabelEdit:    true \
      pAllowReorder: true \ 
      pCheckBoxes:   false\ 
      pFullRowSel:   true \
      pMultiSel:     true \
      pGridLines:    true \
      pHideHeaders:  false\
      pAllowDrop:    false\
      pInitColumns:  #()  \
      pInitColWidths:#()  =
 (
  --Initialization Function to set general properties of a listview control
  
  ------------------------------------
  -- user defined options
  ------------------------------------
  -- Allow the user to edit item text.
  lv.LabelEdit = pLabelEdit;
  -- Allow the user to rearrange columns.
  lv.AllowColumnReorder = pAllowReorder;
  -- Display check boxes.
  lv.CheckBoxes = pCheckBoxes;
  -- Select the item and subitems when selection is made.
  lv.FullRowSelect = pFullRowSel;
  -- Enable multiple selections
  lv.multiselect = pMultiSel
  -- Display grid lines.
  lv.GridLines = pGridLines;
  -- Set Drag and Drop
  lv.allowDrop = pAllowDrop
  ------------------------------------
  -- other options
  ------------------------------------
  -- Set the view to show details.
  local view = dotNetClass "System.Windows.Forms.View"
  lv.View = view.Details;
  -- Sort the items in the list in ascending order.
  local sortOrder = dotNetClass "System.Windows.Forms.SortOrder"
  lv.Sorting = sortOrder.Ascending;
  
  -- Add columns (if supplied) and name them 
  local index = 1
  local doSetWidth = if (pInitColWidths.count == pInitColumns.count) then true else false
  for caption in pInitColumns do
  ( 
   local width = if (doSetWidth) then pInitColWidths[index] else undefined 
   local header = AddLvColumnHeader lv pCaption: caption pWidth: width
   index += 1
  )
  
  -- Set Listview to System Colors
  local textColor   = MXSColor_to_dotNetColor (((colorman.getColor #text  )*255) as color)
  local windowColor = MXSColor_to_dotNetColor (((colorman.getColor #window)*255) as color)

  lv.backColor = windowColor
  lv.foreColor = textColor
 )
)

global lvops = ListViewOps()


if (true) do --for testing
(
 lvstuff = ListViewOps()
 
 rollout stuff "STUFF_ROLLOUT_CAPTION" width: 250 height: 250
 (
  local flip = true
  dotNetControl lv "Listview" pos: [5,5,0] width: 240 height: 240
  on stuff open do
  (
   lvstuff.InitListView lv pInitColumns: #("LVSTUFF_COL_TITLE_FIRST","LVSTUFF_COL_TITLE_MIDDLE","LVSTUFF_COL_TITLE_LAST") pCheckBoxes: true
   lvstuff.InitImageList lv #("$Ui\\icons\\tvObj.ico", "$Ui\\icons\\tvCutObj.ico", "$Ui\\icons\\tvSet.ico") 
    
   lvstuff.AddLvItem lv pTextItems: #("Chris", "Paul", "Johnson") 
   lvstuff.AddLvItem lv pTextItems: #("Kenneth", "Robert", "Benson","bang","gee","whiz")
   lvstuff.AddLvItem lv pTextItems: #("Jared","Lee","Hess") pInsertAt: 0
   
   local findA = lvstuff.GetLvItemByName lv "Hess"
   local findB = lvstuff.GetLvItemByName lv "Robert"
   
   lvstuff.HighLightLvItem lv.items.item[0] #bold (color 255 0 0)
   lvstuff.HighLightLvItem lv.items.item[1] #italic (color 0 185 0)
   lvstuff.HighLightLvItem lv.items.item[2] #underline (color 0 0 255)
    
   local theItem = lvstuff.AddLvItem lv pTextItems: #("Jared","Lee","Hess") pInsertAt: 0
   theItem.indentCount = 1
   

   --lvstuff.DeleteLvItem lv 2
   --lvstuff.DeleteLvItem lv 1
   --lvstuff.DeleteLvItem lv 0
  )
  on lv click arg do
  (
   if flip then
   (
    lvstuff.SetLvItemRowColor lv 0 red
    lvstuff.SetLvItemRowColor lv 1 red
    lvstuff.SetLvItemRowColor lv 2 red
   )
   else
   (
    lvstuff.SetLvItemRowColor lv 0 green
    lvstuff.SetLvItemRowColor lv 1 green
    lvstuff.SetLvItemRowColor lv 2 green
   )
   flip = not flip
  )
  on lv columnClick columnHeader do 
  (
   lv.ListViewItemSorter = dotnetobject "MXS_dotNet.ListViewItemComparer" columnHeader.column
   lv.ListViewItemSorter = undefined
  )
 )
 
 createdialog stuff
)
