    (
    	rollout dgTest  (micra.version + " Updater:")  width:332 height:312
    	(
    		dotNetControl dgv "System.Windows.Forms.DataGridView" pos:[4,52] width:324 height:224
    		button btn_get "Get" pos:[4,280] width:108 height:28
    		button btn_abort "Cancel" pos:[220,280] width:108 height:28
    		label lbl_local_version "You Version:" pos:[8,4] width:320 height:20
    		label lbl2 "Server Versions:" pos:[8,28] width:320 height:20
			
			fn initInterface = (
				
				local sm = dotNetClass "System.Windows.Forms.DataGridViewSelectionMode"
				dgv.SelectionMode = sm.FullRowSelect
				dgv.MultiSelect = false
				dgv.RowHeadersVisible = true
				--dgv.BackgroundColor = (dotNetClass "System.Drawing.Color").Honeydew
				--dgv.EditMode =  (dotNetClass "System.Windows.Forms.DataGridViewEditMode").EditOnEnter --edit cel on enter
			)
			
			fn addColumns = (
				
				--Create a Column and add it to the DataGridView
    			local versionsCol = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
				versionsCol.width = 80
    			versionsCol.headerText = "Version"
    			dgv.columns.add versionsCol
    			dgv.scrollbars = dgv.scrollbars.none
				
				local dateCol = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
				dateCol.width = 200
    			dateCol.headerText = "Date"
    			dgv.columns.add dateCol
    			dgv.scrollbars = dgv.scrollbars.none	
			)
			
			fn addRows = (
			
				--dgv.rows.item[0].cells.item[0].value = "v."+1 as string
				for i = 1 to 8 do (
					
					local row_id = dgv.rows.add() --add new row
					format "id:%\n" row_id
					--add versions
					dgv.rows.item[row_id].cells.item[0].value = "v."+ i as string	--add version
					dgv.rows.item[row_id].cells.item[1].value = "day."+ i as string --add date
					dgv.rows.item[row_id].HeaderCell.Value = i as String	 --add numbers at begin
				)
				
				--align text
				--local vca = dotNetClass "System.Windows.Forms.DataGridViewContentAlignment"
				--dgv.RowsDefaultCellStyle.Alignment = vca.MiddleCenter
				--autosize headers
				--local vsm = dotNetClass "System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode"
				--dgv.AutoResizeRowHeadersWidth vsm.AutoSizeToAllHeaders
			)
			
			fn getData = (
				
					lbl_local_version.text = "You Version:" + "1.01"
			)
			
    		on dgTest open do (
    			
				getData()
				initInterface()
				addColumns()
				addRows()
				
    		)
    	)
    	createDialog dgTest modal:true
    )