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
				dgv.MultiSelect = true
				dgv.RowHeadersVisible = false
				--dgv.BackgroundColor = (dotNetClass "System.Drawing.Color").Honeydew
				--dgv.EditMode =  (dotNetClass "System.Windows.Forms.DataGridViewEditMode").EditOnEnter --edit cel on enter
			)
			
			fn addColumns = ( --Create a Columns and add it to the DataGridView
				
				local checkboxCol = dotNetObject "System.Windows.Forms.DataGridViewCheckBoxColumn"
				checkboxCol.width = 40
    			checkboxCol.headerText = "Visible"
    			dgv.columns.add checkboxCol
				
    			local versionsCol = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
				versionsCol.width = 200
    			versionsCol.headerText = "Node"
    			dgv.columns.add versionsCol
				
    			dgv.scrollbars = dgv.scrollbars.none	
			)
			
			fn addRows = (
			
				--dgv.rows.item[0].cells.item[0].value = "v."+1 as string
				for i = 1 to 8 do (
					
					local row_id = dgv.rows.add() --add new row
					format "id:%\n" row_id
					--add versions
					dgv.rows.item[row_id].cells.item[0].value = true --set all checkboxes to true
					dgv.rows.item[row_id].cells.item[1].value = "v."+ i as string	--add version
					--dgv.rows.item[row_id].HeaderCell.value = i as String	 --add numbers at begin
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
			on btn_abort pressed do ( destroyDialog dgTest )
    	)
    	createDialog dgTest modal:true
    )
	
	
	
	/*
		dotNetControl dnListView "System.Windows.Forms.ListView"  pos:[0,0] width:listWidth height:listHeight
	/*
	
	/*
	fn arrayToDotNet mArray =   
(  
    netA = dotNetObject "System.String[]" mArray.count  
    for i=1 to mArray.count do   
    (  
        str = dotNetObject "System.String" mArray[i]  
        indx = dotNetObject "System.Int32" (i-1)  
        netA.SetValue str indx  
    )  
    netA  
)  
fn setDotNetWidgetColor dNObj =  
(  
    ClrBackGround = ((colorMan.getColor #window)*255)     
    ClrForeGround = ((colorMan.getColor #text)*255)  
    dNObj.backcolor = dNObj.backcolor.FromArgb ClrBackGround.x ClrBackGround.y ClrBackGround.z  
    dNObj.forecolor = dNObj.forecolor.FromArgb ClrForeGround.x ClrForeGround.y ClrForeGround.z  
)  
rollout testRo "yo" width:600  
(  
    dotNetControl dgv "System.Windows.Forms.DataGridView" height:200  
    on testRo open do  
    (  
        --init basic dataGrivView settings  
        setDotNetWidgetColor dgv  
        dgv.AllowUserToAddRows = false  
        dgv.AutoSize = true  
        dgv.AutoSizeColumnsMode = dgv.AutoSizeColumnsMode.Fill  
        dgv.ShowEditingIcon = dgv.RowHeadersVisible = true  
        dnSelectionMode = dotNetClass "System.Windows.Forms.DataGridViewSelectionMode"  
        dgv.SelectionMode = dnSelectionMode.FullRowSelect   
        --create some colum data  
        colAr = #()  
        append colAr #(#bool,"On?",false,#Right)  
        append colAr #(#text,"hey there guy!",true,#Right)  
        append colAr #(#opt,"list of shit...",false,#Right)  
        --use the column data to proceduraly create colums based on the data types  
        for col in colAr do  
        (  
            dnNewColumn  
            case col[1] of  
            (  
                (#Text):dnNewColumn = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"  
                (#Bool):dnNewColumn = dotNetObject "System.Windows.Forms.DataGridViewCheckBoxColumn"  
                default:dnNewColumn = dotNetObject "System.Windows.Forms.DataGridViewComboBoxColumn"  
            )  
            dnNewColumn.HeaderText = col[2]  
            dnNewColumn.ReadOnly = col[3]  
            dnAlignment = dotNetClass "System.Windows.Forms.DataGridViewContentAlignment"  
            case col[4] of  
            (  
                #Right:     dnNewColumn.DefaultCellStyle.Alignment = dnAlignment.MiddleRight  
                #Center:    dnNewColumn.DefaultCellStyle.Alignment = dnAlignment.MiddleCenter  
                #Left:      dnNewColumn.DefaultCellStyle.Alignment = dnAlignment.MiddleLeft  
                default:    dnNewColumn.DefaultCellStyle.Alignment = dnAlignment.MiddleLeft  
            )  
            --setDotNetWidgetColor dnNewColumn.style  
            dgv.columns.add dnNewColumn  
        )  
  
        --move on to adding actuall values  
        ----create value array structure  
        valueAr = #()  
        for i = 1 to 10 do  
        (  
            append valueAr #(dotNetObject "System.Boolean" True ,dotNetObject "System.String" "Pedro",dotNetObject "System.Int32" 0,#("superMan","batMan"))  
            append valueAr #(dotNetObject "System.Boolean" False ,dotNetObject "System.String" "Peter",dotNetObject "System.Int32" 1,#("Santo","BlueDemon"))  
        )  
        --once our data has been created lets apply it to our grid  
        for v in valueAr do  
        (  
            tempRow = dotNetObject "System.Windows.Forms.DataGridViewRow"  
            dgv.rows.add tempRow  
            for it in v[4] do tempRow.cells.item[2].items.add it  
            tempRow.SetValues v  
            --let's apply preaty colors to our cells   
            for i=1 to tempRow.cells.count do setDotNetWidgetColor tempRow.cells.item[i-1].style  
  
        )  
    )  
)  
createDialog testRo  
	*/