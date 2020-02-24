--------------------------------------------------------------------------------
/* mcCSharp by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Created by MerlinEl 2020
*@Thanks to
	Mambo4 2014 http://discourse.techart.online/t/3ds-max-c-iterating-on-a-dll-using-visual-studio-unload-assemblies-in-max/4265/7
	ninianne98 2013 https://forums.asp.net/t/1905021.aspx?How+to+pass+your+constructor+parameters+using+System+Reflection
	Rod Stephens 2016 http://csharphelper.com/blog/2016/11/run-user-entered-code-in-c/
	
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
		--TODO trace these in source and import those modules
		--split first string from first USING in to last USING
		--split them by new line and import them each one by one
	using System;
	using System.Collections.Generic;
	using System.Linq;
	using System.Text;

	----------------------------------------------------
	csharp_object = mcCSharp.compile "MyNameSpace.MyClassWithArg" using:#("System") params:#("Pased arguments in to C# Class. Cool!!!")
	csharp_object.sayArg()
	----------------------------------------------------
	rect = mcCSharp.compile "Rectangle2D" using:#("System") params:#(154, 45)
	rect.Area()
	----------------------------------------------------
	source = mcCSharpUI.getClass "Circle2D"
*
*/
struct MICRA_CSHARP_STRUCTURE	(
	
	--variables
	debug=true,
	activator = dotNetClass "System.Activator",
	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider",
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn getUsingResources src = (
	
		local begin = findString src "using"
		
	),
	fn loadReferences using = (
	
		local cp = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
		if using.count > 0 do (
		
			if findItem using "System"	> 0 do cp.ReferencedAssemblies.AddRange #("System.dll")
			if findItem using "Core"		> 0 do cp.ReferencedAssemblies.Add("System.Core.dll");
			if findItem using "Forms"	> 0 do cp.ReferencedAssemblies.AddRange #("System.Drawing.dll")
			if findItem using "Drawing"	> 0 do cp.ReferencedAssemblies.AddRange #("System.Windows.Forms.dll")
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
	fn compile className using:#() params:#() instanced:true source:"" = (
		
		local src = if source == "" then mcCSharpUI.getClass className else source
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
			
			if not instanced then ( --load object in to memory (register only)
				format "mcCSharp > compile > In mem\n"
				compilerResults.CompiledAssembly
				
			) else ( --return object as instance
			
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
			)
			
		) catch (
			
			format "Unable to compile Assembly:\n\t%\n"  (getCurrentException())
			undefined
		)
	),	
	/**
	*@Example
		r1 = mcCSharp.new "Rectangle2D"  params:#(10, 122)
		r1.Area()

		r2 = mcCSharp.new "Rectangle2D"  params:#(100, 400)
		r2.Area()

		r = mcCSharp.new "MyNameSpace.MyClassWithArg"  params:#("pass")
		r.sayArg()
	*/
	fn new className params:#() = (
	
		local cls_type = dotNet.getType className
		if cls_type == undefined do (
			format "mcCSharp > new > compile\n"
			mcCSharp.compile className params:params
			cls_type = dotNet.getType className
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

/*

// C# Program to show the use 
// of the new Operator 
using System; 
  
namespace NewOperator { 
  
class Rectangle { 
  
    public int length, breadth; 
  
    // Parameterized Constructor 
    // User defined 
    public Rectangle(int l, int b) 
    { 
        length = l; 
        breadth = b; 
    } 
  
    // Method to Calculate Area 
    // of the rectangle 
    public int Area() 
    { 
        return length * breadth; 
    } 
} 
  
// Driver Class 
class Program { 
  
    // Main Method 
    static void Main(string[] args) 
    { 
        // Creating an object using 'new' 
        // Calling the parameterized constructor 
        // With parameters 10 and 12 
        Rectangle rect1 = new Rectangle(10, 12); 
        int area = rect1.Area(); 
        Console.WriteLine("The area of the"+ 
                   " Rectangle is " + area); 
    } 
} 
} 
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
rect = mcCSharp.compile "Rectangle2D" using:#("System") instanced:false
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