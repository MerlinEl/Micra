-----------------------------------------------------------------------------------------------
    --Implements the a comparer that allows sorting of listview items by columns
    --  (derived from the example snippet in the .NET help docs)
    --
    -- Once this code is assembled you can use it by assigning a comparer object to the
    -- ListViewItemSorter property of your listview. 
    --
    --	 lv.ListViewItemSorter = gNewListViewItemComparer()
    --
    -- You can then adjust the way you want the sort to occur:
    --
    -- Pick the column:
    --	 lv.ListViewItemSorter.Column = <col>	NOTE: out of range [0 - numcols-1] disables sort
    -- Ascending or descending:
    --	 lv.ListViewItemSorter.Reversed = <true|false>
    -- 
    -- Don't forget to call lv.Sort() after changing one of the sorter's properties!
    --
    -----------------------------------------------------------------------------------------------
    if gListViewItemComparerAssembly == undefined then
    (
    	global gListViewItemComparerAssembly
    )
    
    fn gNewListViewItemComparer forceRecompile:false =
    (
    	if (forceRecompile or 
    		(classof gListViewItemComparerAssembly) != dotNetObject or 
    		((gListViewItemComparerAssembly.GetType()).ToStrin  g()) != "System.Reflection.Assembly") do
    	(
    		sb =  "using System;\n"
    		sb += "using System.Windows.Forms;\n"
    		sb += "using System.Collections;\n"
    		sb += "class gpgxListViewItemComparer : IComparer\n"
    		sb += "{\n"
    		sb += "	public int column;\n"
    		sb += "	public bool reversed;\n"
    		sb += "	public gpgxListViewItemComparer()\n"
    		sb += "	{\n"
    		sb += "		column = 0;\n"
    		sb += "		reversed = false;\n"
    		sb += "	}\n"
    		sb += "	public gpgxListViewItemComparer(int col, bool rev)\n"
    		sb += "	{\n"
    		sb += "		column = col;\n"
    		sb += "		reversed = rev;\n"
    		sb += "	}\n"
    		sb += "	public int Compare(object x, object y)\n"
    		sb += "	{\n"
    		sb += "		int ret = 0;\n"
    		sb += "		ListViewItem lvx = (ListViewItem)x;\n"
    		sb += "		ListViewItem lvy = (ListViewItem)y;\n"
    		sb += "		if (column >= 0 && column < lvx.SubItems.Count && column < lvy.SubItems.Count)\n"
    		sb += "			ret = String.Compare(lvx.SubItems[column].Text, lvy.SubItems[column].Text);\n"
    		sb += "		return reversed ? -ret : ret;\n"
    		sb += "	}\n"
    		sb += "}\n"
    
    		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
    		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
    		
    		-- Need to add referenced assemblies that the code snippet is 'using'
    		compilerParams.ReferencedAssemblies.Add("System.dll");
    		compilerParams.ReferencedAssemblies.Add("System.Windows.Forms.dll");
    		
    		compilerParams.GenerateInMemory = true
    		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(sb)
    		
    		if (compilerResults.Errors.Count > 0 ) then
    		(
    			errs = stringstream ""
    			for i = 0 to (compilerResults.Errors.Count-1) do
    			(
    				err = compilerResults.Errors.Item[i]
    				format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line \											  
    													 err.Column err.ErrorText to:errs 
    			)
    			MessageBox (errs as string) title: "Errors encountered while compiling C# code"
    			format "%\n" errs
    			gListViewItemComparerAssembly = undefined
    			return undefined
    		)
    		else
    		(
    			gListViewItemComparerAssembly = compilerResults.CompiledAssembly
    		)
    	)
    	gListViewItemComparerAssembly.CreateInstance "gpgxListViewItemComparer"
    )
    
    
    rollout testRLT "List View Column Sort Test" width:200 height:180
    (
    	 dotNetControl thingy "ListView" width:160 height:100
    	
    	 on testRLT open do 
    	  (
    		thingy.View = thingy.View.Details 
    		column = thingy.Columns.Add "Item"
    		column = thingy.Columns.Add "SbItm0"
    		column = thingy.Columns.Add "SbItm1"
    		 
    		thingy.Items.add "a"
    		thingy.Items.add "b"
    		thingy.Items.add "c"
    		 
    		thingy.Items.Item[0].SubItems.add "y"
    		thingy.Items.Item[0].SubItems.add "f"
    		 
    		thingy.Items.Item[1].SubItems.add "z"
    		thingy.Items.Item[1].SubItems.add "d"
    		 
    		thingy.Items.Item[2].SubItems.add "x"
    		thingy.Items.Item[2].SubItems.add "e"
    
    		 
    		thingy.Columns.Item[0].width = 40
    		thingy.Columns.item[1].width = 50
    		thingy.Columns.item[2].width = 50
    		
    		thingy.ListViewItemSorter = gNewListViewItemComparer()
    
    		thingy.Invalidate  true
    	  )	 
    	
    	on thingy ColumnClick evt do
    	(
    		if (thingy.ListViewItemSorter.Column != evt.Column) then
    		(
    			thingy.ListViewItemSorter.Column = evt.Column
    			thingy.ListViewItemSorter.Reversed = false
    		)
    		else
    		(
    			thingy.ListViewItemSorter.Reversed = (not thingy.ListViewItemSorter.Reversed)
    		)
    		thingy.Sort()
    	)	 
    ) 
    
    floaterInstance= newRolloutFloater "Test" 200 200
    addRollout testRLT floaterInstance
