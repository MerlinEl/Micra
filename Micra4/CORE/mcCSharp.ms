--------------------------------------------------------------------------------
/* mcCSharp by Orien 2020 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
	mcCSharpUI
*
*@Used Objects
	undefined
*
*@Usage
	setting up the assembly in memory
*
*@Example
	----------------------------------------------------
	rect_1 = mcCSharp.new "Orien.Math.Rectangle2D"  params:#(10, 122)
	rect_1.Area()
	----------------------------------------------------
	rect_2 = mcCSharp.new "Orien.Math.Rectangle2D"  params:#(100, 400)
	rect_2.Area()
	----------------------------------------------------
	lbl_01 = mcCSharp.new "Orien.DotnetUI.LabelRoundCorners" 
	----------------------------------------------------
	source = mcCSharpUI.getClass "Orien.Math.Rectangle2D"
	----------------------------------------------------
*
*@Thanks to
	Mambo4 2014 http://discourse.techart.online/t/3ds-max-c-iterating-on-a-dll-using-visual-studio-unload-assemblies-in-max/4265/7
	ninianne98 2013 https://forums.asp.net/t/1905021.aspx?How+to+pass+your+constructor+parameters+using+System+Reflection
	Rod Stephens 2016 http://csharphelper.com/blog/2016/11/run-user-entered-code-in-c/
	
*/

struct MICRA_CSHARP_STRUCTURE	(
	
	--variables
	debug = true,
	activator = dotNetClass "System.Activator",
	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider",
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	-------------------------------------------------------------------
	--LOADING ASSEMBLY FROM DLL (MEMORIZE CONTENT WITHOUT LOCK DLL)--
	-------------------------------------------------------------------
	/**
	*@Usage
	*@Example
		if mcCSharp.isLoaded() then (
			mcMath_Instance = mcCSharp.getClassInstance "Orien.Tools.mcMath" --without constructor parameters
			mcMath_Instance.minMax 100	1	50	--> 50
			mcMath_Instance.minMax -1	1	50	--> 1
			mcMath_Instance.minMax 100	1	200	--> 100
		)
	*/
	fn isLoaded = (classOf (dotNet.getType "Orien.Tools.McGet") == dotNetObject),
	fn getClassInstance classPath constructorParams:#() forceLoad:false = (
		local class_instance
		if not doesFileExist (micra.AssemblyDir + "Orien.Star.dll") do return false
		if not isLoaded() or forceLoad do try ( --load first time or if forceLoad
			--Orien.Tools and Orine.NetUi are mergetn in to > 
			format "Assembly Orien.Star was loaded\n"
			local assembly_path = micra.AssemblyDir + "Orien.Star.dll"
			local assembly_bytes = (dotnetClass "System.IO.File").ReadAllBytes assembly_path
			local assembly = (dotnetClass "System.Reflection.Assembly").Load assembly_bytes

		) catch (
		
			format "mcCSharp > getClassInstance > Unable to load Assembly:\n\t%\n"  (getCurrentException())
			return false
		)
		try (
			local dotnet_class = dotNet.getType classPath
			--format "cls:% path:%\n" dotnet_class classPath
			class_instance = (dotNetClass "System.Activator").CreateInstance dotnet_class	
		
		) catch (
			format "mcCSharp > getClassInstance > Unable to load Class:\n\t%\n"  (getCurrentException())
		)
		class_instance
	),
	-------------------------------------------------------------------
	--BUILDING ASSEMBLY FROM STRING--
	-------------------------------------------------------------------
	/**
	*@Example
		src = mcCSharpUI.getClass "Rectangle2D"
		dll_filenames = mcCSharp.getUsedResources src
		--> #("System.dll", "System.Drawing.dll")
	*/
	fn getUsedResources src = (
	
		local ss = src as stringStream 
		skipToString ss "\n" --pass first enter
		local using_arr =#()
		while not eof ss do (

			local line_str = readLine ss
			if findString line_str "using" == undefined do exit
			if findString line_str "//internal" == undefined do ( --skip internal assemblies
			
				local dll_name = trimLeft line_str	--remove spaces at begin
				dll_name = trimRight dll_name		--remove spaces at end
				dll_name = trimLeft dll_name "using "	--remove using at begin
				dll_name = trimRight dll_name ";"	--remove last semicolon
				dll_name += ".dll"					--add dll extension
				append using_arr dll_name
			)
		)
		close ss
		using_arr
	),
	fn loadReferences using = (
	
		local cp = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
		--Add dll names in to Referenced Assemblies 
		if using.count > 0 do try (
		
			cp.ReferencedAssemblies.AddRange using
			
		) catch (
		
			format "Unable Load References:\n\t%\n"  (getCurrentException())
		)
		--Print loaded Assemblies
		if debug do (
		
			format "mcCSharp > loadReferences(%)\n" cp.ReferencedAssemblies.count
			for i=0 to cp.ReferencedAssemblies.count-1 do (
			
				format "\t%\n" cp.ReferencedAssemblies.item[i]
			)
		)
		cp
	),
	/**
	*@Usage
		compile C# code(string) in to Max memory
	*@Example
		mcCSharp.compile "Orien.Math.Rectangle2D"
		mcCSharp.compile "Orien.DotnetUI.LabelRoundCorners"
	*/
	fn compile className source:"" = (
		
		local src = if source == "" then mcCSharpUI.getClass className else source
		local using = getUsedResources src
		try (
		
			local compilerParams = loadReferences using --Create compiller parameters and load desired Assemblies
			compilerParams.GenerateInMemory = true
			compilerParams.GenerateExecutable = false
			local compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(src)
			--Error check for compiler
			if (compilerResults.Errors.Count > 0 ) then (
			
				local errs = stringstream ""
				for i = 0 to (compilerResults.Errors.Count-1) do (
				
					local err = compilerResults.Errors.Item[i]
					format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line err.Column err.ErrorText to:errs 
				)
				MessageBox (errs as string) title: "Errors encountered while compiling C# code"
				return undefined
			)
			format "mcCSharp > compile > In mem\n"
			compilerResults.CompiledAssembly --return compiled assembly
				
		) catch (
			
			format "Unable to compile Assembly:\n\t%\n"  (getCurrentException())
			undefined
		)
	),	
	/**
	*@Usage
		create c# classes ir instances
	*@Example
		rect_1 = mcCSharp.new "Orien.Math.Rectangle2D"  params:#(10, 122)
		rect_1.Area()

		rect_2 = mcCSharp.new "Orien.Math.Rectangle2D"  params:#(100, 400)
		rect_2.Area()
	*/
	fn new className params:#() = (
	
		local cls_type = dotNet.getType className --pickup class from memory
		if cls_type == undefined do (
			format "mcCSharp > new > compile\n"
			mcCSharp.compile className
			cls_type = dotNet.getType className --pickup class from memory
		)
		if params.count > 0 then (
		
			local args = dotNet.ValueToDotNetObject params (dotNetObject "System.Object")
			activator.CreateInstance cls_type args
			
		) else (
		
			activator.CreateInstance cls_type
		)
	)
	/*<end>*/
)	
 --create instance
Global mcCSharp = mcStructMan.instanceStructure MICRA_CSHARP_STRUCTURE "mcCSharp"
Global McGetCS = mcCSharp.getClassInstance "Orien.Tools.McGet" forceLoad:true

/*
if params.count == 0 then ( --object instance
	format "mcCSharp > compile > As Instance\n"
	compilerResults.CompiledAssembly.CreateInstance className
	
) else ( --object instance with pased parameters
	format "mcCSharp > compile > As Instance with params\n"			
	local a = compilerResults.CompiledAssembly
	local cls_type = a.getType className  --or dotNet.getType className
	format "\tcls_type:%\n" cls_type
	local args = dotNet.ValueToDotNetObject params (dotNetObject "System.Object")
	format "\targs:%\n" args
	activator.CreateInstance cls_type args
)
*/

/*{
	// Get a MethodInfo object describing the SayHi method.
	MethodInfo method_info = a_type.GetMethod("SayHi");
	if (method_info != null) 
	{
		// Make the parameter list.
		object[] method_params = new object[]
		{
			"This is the parameter string. Isn't it great?"
		};

		// Execute the method.
		DialogResult method_result =
			(DialogResult)method_info.Invoke(null,
				method_params);

		// Display the returned result.
		MessageBox.Show(method_result.ToString());
	}
}*/


/*
public Form1()
{
    InitializeComponent();
    this.button1.Click += new System.EventHandler(this.button1_Click);
    this.button2.Click += new System.EventHandler(this.button1_Click);
}
*/

/*
type = dotNetClass "System.Int32[]"
args = dotnet.ValueToDotNetObject #(11,12) type
*/

/*
fn compile_experimental src className:"" using:#() params:#() = (
		
		try (
		
			local compilerParams = loadReferences using --Create compiller parameters and load desired Assemblies
			compilerParams.GenerateInMemory = true
			compilerParams.GenerateExecutable = false
			format "compile A\n"
			local compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(src)
			format "compile B\n"
			--Error check for compiler
			format "err:%\n" compilerResults.Errors.Count
			format ".HasErrors:%\n" compilerResults.Errors.HasErrors
			if (compilerResults.Errors.Count > 0 ) then (
			
				local errs = stringstream ""
				for i = 0 to (compilerResults.Errors.Count-1) do (
				
					local err = compilerResults.Errors.Item[i]
					format "\t\t:%\n" err
					format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line err.Column err.ErrorText to:errs 
				)
				MessageBox (errs as string) title: "Errors encountered while compiling C# code"
				return undefined
			)
			format "compile C\n"
			if className == "" then ( --load object in to memory
			
				format "compile without className\n"
				compilerResults.CompiledAssembly
				
			) else ( --return object as instance
			
				format "compile with className\n"
				if params.count == 0 then ( --object instance
					
					format "compile with className no params\n"
					compilerResults.CompiledAssembly.CreateInstance className
					
				) else ( --object instance with pased parameters
				
					format "compile with className with params\n"
					--Get the compiled method and execute it.
					local types = compilerResults.CompiledAssembly.GetTypes()
					format "result types:%\n" types
					for i = 1 to types.count do ( --get class and pass paramaters in it
						
						Global object_type = types[i]
						if not object_type.IsClass or object_type.IsNotPublic do continue
						
						format "got type:%\n" object_type
						-- object myNewObject = (object)Activator.CreateInstance(Type.GetType("YourNamespace.YourClass"), args );
						local args = dotNet.ValueToDotNetObject params (dotNetObject "System.Object")
						local new_object = activator.CreateInstance object_type args
						exit with new_object
					)
				)
			)
			
		) catch (
			
			format "Unable to compile Assembly:\n\t%\n"  (getCurrentException())
			undefined
		)
	),
*/



/*
rect = mcCSharp.compile "Rectangle2D" instanced:false
cls_type = dotNet.getType "Rectangle2D"
cls_type.Attributes
cls_type.BaseType
cls_type.Assembly
cls_type.ContainsGenericParameters
cls_type.CustomAttributes
cls_type.FullName 
cls_type.GUID 
cls_type.HasElementType
cls_type.IsClass
cls_type.IsArray
cls_type.IsAbstract
cls_type.IsInterface
cls_type.IsPublic
cls_type.Name
cls_type.Namespace
cls_type.Clone()
cls_type.GetMethods()
cls_type.GetProperties()
cls_type.GetMembers()
cls_type.GetEvents()
cls_type.GetType()
cls_type.ToString()
*/