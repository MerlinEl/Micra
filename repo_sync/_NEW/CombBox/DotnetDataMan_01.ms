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
            append valueAr #(dotNetObject "System.Boolean" True ,dotNetObject "System.String" "Pedro"))  
            append valueAr #(dotNetObject "System.Boolean" False ,dotNetObject "System.String" "Peter"))  
        )  
        --once our data has been created lets apply it to our grid  
        for v in valueAr do  
        (  
            tempRow = dotNetObject "System.Windows.Forms.DataGridViewRow"  
            dgv.rows.add tempRow  
            tempRow.SetValues v  
            --let's apply preaty colors to our cells   
            for i=1 to tempRow.cells.count do setDotNetWidgetColor tempRow.cells.item[i-1].style  
        )  
    )  
)  
createDialog testRo  