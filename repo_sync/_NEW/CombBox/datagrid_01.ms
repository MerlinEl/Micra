    (
    	rollout dgTest "DataGridView Test" width:338 height:300
    	(
    		dotNetControl dgv "System.Windows.Forms.DataGridView" pos:[8,8] width:324 height:224
			
    		fn addItems sender e = (
    			
    			for i = 1 to 8 do
    			(
    				dgv.rows.add ()
    			)
    		)
    		
    		fn addScrollbars sender e =
    		(
    			dgv.scrollbars = dgv.scrollbars.both
    		)
    		
			fn initInterface = (
				
				local sm = dotNetClass "System.Windows.Forms.DataGridViewSelectionMode"
				dgv.SelectionMode = sm.FullRowSelect
				dgv.MultiSelect = false
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
			
			
    		on dgTest open do (
    			
				initInterface()
				addColumns()
			
    			--Execute the addItems Function via MultiThreading
    			myThread = dotnetobject "CSharpUtilities.SynchronizingBackgroundWorker"
    			dotnet.addEventHandler myThread "DoWork" addItems
    			dotnet.addEventHandler myThread "RunWorkerCompleted" addScrollbars
    			myThread.runWorkerAsync()
    		)
    	)
    	createDialog dgTest modal:true
    )
	
	/*
	local rowNumber = 1;
    for  row in dataGridView.Rows do (
    
        if row.IsNewRow do continue
        row.HeaderCell.Value = "Row " + rowNumber
        rowNumber += 1
    )
    dataGridView.AutoResizeRowHeadersWidth(DataGridViewRowHeadersWidthSizeMode.AutoSizeToAllHeaders)
	*/