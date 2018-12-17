
-- DotNet ListView with Scrollable Drag N'Drop and Insertion Mark when dragging
---------------------------------------------------------------------------------------------

try(DestroyDialog MyListViewRoll)catch()

rollout MyListViewRoll "ListView Template with Scrollable Drag 'N Drop" (

	-- Variables and functions
	local dragDropEffect=dotNetClass "System.Windows.Forms.DragDropEffects" -- Drag and drop effects	
	local setupListView, dotNetGraphics, dotNetPen, dotNetLastDrawnRect, lastMousedItem, clickedItem, dontErase=false
	
	-- This is array holds the content for our Listview items. An oversimplification, probably.
	local lvItems=for x=1 to 20 collect "Item "+x as string
	
	dotNetControl lv "System.Windows.Forms.ListView" width:290 height:160 pos:[20,20]
	
	on MyListViewRoll open do setupListView()
	
	-- Returns an array of item numbers representing the ListView items that are selected. ListView indices are zero-based, remember.
	fn getSelection = for x=0 to lv.selectedIndices.count-1 collect lv.selectedIndices.item[x]
	
	-- Given an array of items numbers, this selects those items. ListView indices are zero-based, remember
	fn setSelection itemsToSelect_zeroBased = 
	(			
		for itemNum_zeroBased=0 to lv.items.count-1 do 
		(
			local currItem=lv.items.item[itemNum_zeroBased]
			if findItem itemsToSelect_zeroBased itemNum_zeroBased >0 then currItem.selected=true						
			else currItem.selected=false				
		)			
	)
	
	-- This function reorders the content array and then tells the ListView to redraw itself based on the new array.
	fn reorderItems selectedIndices targetIndex clickedIndex = (
		
		if findItem selectedIndices targetIndex >0 then return() -- if the target is one of the selected items, then leave
		
		local asOneBased=1, asZeroBased=-1 -- used to convert zero-based and one-based arrays back and forth
		
		-- If we're dragging the items downward then we're going to bump the target index by one so that the content is always dropped on the opposite
		-- side from where you're dragging from
		if clickedIndex<targetIndex then targetIndex+=1
		while (findItem selectedIndices targetIndex >0) do targetIndex+=1 -- if we've just made a selected item one of the targets, keep bumping the target until it's not selected
			
		local origItems=for x =1 to lvItems.count collect lvItems[x] -- make a copy of the array		
		local targItem=try(origItems[targetIndex+asOneBased])catch(undefined) -- try to identify the content that corresponds to the target index
		
		-- Move the selected items from the original list to a temporary list
		local itemsToMove=#()
		for y= selectedIndices.count to 1 by -1 do 
		(
			local indexInOrigList=selectedIndices[y]+asOneBased
			append itemsToMove origItems[indexInOrigList]
			deleteItem origItems indexInOrigList
		)			
		
		-- If the selection was dragged to the very bottom of the listview, we can just append it to the end of the content list
		if targItem==undefined then for z = itemsToMove.count to 1 by -1 do append origItems itemsToMove[z]
		
		-- Otherwise we have to insert it
		else 
		(				
			-- Now that the original list has been trimmed down, the zero-based target number may be obsolete, so we need to calc what it is in trimmed down list
			local targNum_oneBased=findItem origItems targItem
			-- Move the selected items back into the main list, inserted at the given insertion point. We now have a nicely re-ordered list of items
			for z = 1 to itemsToMove.count do insertItem itemsToMove[z] origItems (targNum_oneBased) -- insert the selected names
		)			
		lvItems=origItems -- store this reordered array as the official content for the ListView items		
		
		setupListView() -- redraw the ListView
		
		local newSelNums=for r in itemsToMove collect (findItem origItems r)+asZeroBased -- we want the selected items to stay selected, even after the dragging
		setSelection newSelNums -- select the items		
	)
	
	-- Tells Windows to redraw the portion of the screen where the insertion marker was last placed, effectively erasing it
	fn eraseDragDropInsertionMark = lv.invalidate dotNetLastDrawnRect	
	
	-- Checks to see if the insertion mark needs to be erased from the old location and drawn in a new location 
	fn updateDragDropInsertionMark itemNum direction = (
		
		local rect=(lv.GetItemRect itemNum) -- get the rect object of the ListView item given in the first argument
		
		-- Here we figure out where on the Y axis to draw the insertion marker. We want to always draw it on the opposide side of the item that the cursor is coming from.
		local lineY; if direction==#up then lineY=rect.top+dotNetPen.width*.5
		else lineY=rect.bottom-dotNetPen.width*.5
		
		-- If the mouse is over a different item then it was last time, we'll erase the old insertion mark and draw a new one
		if itemNum!=lastMousedItem then (		
			
			-- Don't erase the line if this is the first time around after the draging has begun. Without this, the line disappears on the first item
			if not dontErase then eraseDragDropInsertionMark(); dontErase=false
			
			-- Record the item that the cursor is currently over, and draw the line
			lastMousedItem=itemNum
			dotNetLastDrawnRect.y=lineY-dotNetPen.width; dotNetLastDrawnRect.height=dotNetPen.width*2; dotNetLastDrawnRect.width=rect.width
			dotNetGraphics.DrawLine dotNetPen rect.left lineY rect.right lineY				
		)			
	)		
	
	fn checkDragDropInsertionMarkStatus mousePos arg = (
		
		local testItem= lv.GetItemAt mousePos.x mousePos.y -- find the ListView item under the cursor
		
		-- If there is indeed an item under the mouse, we'll change the cursor to indicate that dropping can ocur here, and we'll update the insertion mark for added visual feedback
		if testItem != undefined then (				
			arg.Effect=arg.AllowedEffect				
			local direction=#down; if clickedItem.index>testItem.index then direction=#up -- determine what direction we're dragging
			updateDragDropInsertionMark testItem.index direction -- update the insertion mark				
			
		-- Otherwise there is no item under the cursor, so change the mouse cursor back to normal and erase the old insertion mark if it exists 
		) else (	
			arg.Effect=dragDropEffect.none				
			eraseDragDropInsertionMark()					
		)			
	)
	
	-- If the mouse leaves the ListView area while dragging, we need to erase the insertion mark that's left behind
	on lv DragLeave e do eraseDragDropInsertionMark() 	
	
	-- Called when the dragging has just begun
	on lv ItemDrag arg do
	(			
		dotNetGraphics=lv.createGraphics() -- create a DotNet Graphics object
		local col=DotNetClass "System.Drawing.Color"; col=col.FromArgb 150 150 160 -- create a color for the insertion line			
		dotNetPen=dotNetObject "System.Drawing.Pen" col 3 -- create a DotNet Pen object and optionally specify its color and width
		dotNetLastDrawnRect=dotNetObject "System.Drawing.Rectangle" 0 0 0 0 -- this rect is what will keep track of what region needs to be erased			
		clickedItem=arg.item -- the item that was just clicked on and is now being dragged. I think this can only be one item (even if multiple are selected).
		
		dontErase=true -- this flag keeps the insertion line from being erased initially when the dragging begins after the cursor is outside of the item that was clicked on
		lv.doDragDrop arg.item dragDropEffect.Copy -- this actually starts the drag and drop process		
	)
	
	-- Called repeatedly while dragging. It's here we call the function to update the insertion mark, and we also take care of scrolling
	on lv DragOver arg do
	(
		local pos=lv.PointToClient lv.MousePosition
		checkDragDropInsertionMarkStatus pos arg			
		
		-- Scroll if necessary
		local scrollAmount=0
		local topIndex=lv.topItem.index			
		if pos.y<lv.top+20 then scrollAmount=-1 -- detect if the cursor is too close to top or bottom
		if pos.y>lv.bottom-12 then scrollAmount=1
		
		if scrollAmount!=0 then (
			eraseDragDropInsertionMark() -- must do this before the topItem is changed, otherwise some times line won't be erased
			topIndex+=scrollAmount
			if topIndex<0 then topIndex=0
			else if topIndex>lv.items.count-1 then topIndex=lv.items.count-1
			lv.topItem=lv.items.item[topIndex]					
		)		
	)
	
	-- Called right after the dragging has stopped (ie the item was dropped on another item)
	on lv DragDrop arg do
	(
		-- Find the item that the cursor was over when the drag content was dropped
		local mousePos=lv.PointToClient lv.MousePosition
		local dropItem=lv.GetItemAt mousePos.x mousePos.y
		
		local selectedNums_zeroBased=getSelection() -- find out what items in the listview are selected... this is what's really being dragged
		
		-- Now that we know what items are selected (which will serve as our dragged items), which item was originally clicked on (which is what DotNet sees as our dragged item),
		-- and what item the content was dropped on, we can reorder our listview items appropriately.
		reorderItems selectedNums_zeroBased dropItem.index clickedItem.index
		
		dotNetGraphics.dispose(); dotNetGraphics=undefined -- release these DotNet items for garbage collection
		dotNetPen.dispose(); dotNetPen=undefined
		
		eraseDragDropInsertionMark() -- If the user canceled the drop, we need to clean up the insertion line
		dotNetLastDrawnRect=undefined
	)		
	
	fn setupListView = 
	(		
		
		local topItemNum=0; if lv.items.count>0 then topItemNum=lv.TopItem.index -- record the scroll position so we can use it later
		
		lv.clear() -- wipe out the contents of the entire listview so that we're redrawing it from scratch each time this function is called
		
		lv.View = (dotNetClass "System.Windows.Forms.View").Details -- this is what allows the grid-like format to be used
		lv.fullRowSelect = true -- When item is clicked, all columns in that item are selected
		lv.gridLines = false-- turn off the grid lines
		lv.HideSelection=false -- When this ListView loses the focus, it will still show what's selected
		lv.BorderStyle=lv.BorderStyle.FixedSingle -- make the border a flat solid color instead of the Windows 3D look
		lv.HeaderStyle=lv.HeaderStyle.Nonclickable -- Flattens the headers a bit (although they're still somewhat 3D) and keeps them from being clickable			
		lv.backColor=lv.backColor.FromArgb 225 225 225 -- Soften the background intensity a bit
		
		lv.allowDrop=true -- required in order to implement DotNet drag and drop functionality
		
		lv.Columns.add "Column One" 80 -- create a couple of columns and optionally specify their width
		lv.Columns.add "Column Two" 80
		
		-- Create the items that will go in the list view
		theRange = #() 
		for x=1 to lvItems.count do ( li = dotNetObject "System.Windows.Forms.ListViewItem" lvItems[x]; append theRange li )		
		
		lv.Items.AddRange theRange -- and then put them there
		
		if lv.items.count>0 then lv.TopItem=lv.items.item[topItemNum] -- set the scroll position to what it was before the redraw
	)
	
)
CreateDialog MyListViewRoll width:330 height:210
