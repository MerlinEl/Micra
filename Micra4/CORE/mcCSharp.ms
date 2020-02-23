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
	source = "
	using System;
	namespace MyNameSpace {
		public class MyClassWithArg {
			public string arg;
			public MyClassWithArg(string thisArg) {

				arg = thisArg;
			}
			public string sayArg() {

			   return (\"MyClassWithArg.sayArg has been called.MyClassWithArg.arg = \"+ arg + \".\");
			}
		}
	}"
	csharp_object = mcCSharp.compile source className:"MyNameSpace.MyClassWithArg" using:#("System") params:#("Pased arguments in to C# Class. Cool!!!")
	csharp_object.sayArg()
	----------------------------------------------------
	source = "
	using System;
	public class Rectangle2D {
		public int length, width;
		// Parameterized Constructor 
		public Rectangle2D(int l, int b) {
			length = l;
			width = b;
		}
		// Method to Calculate Area  of the rectangle 
		public int Area() 
		{ 
			return length * width; 
		} 
	}
	"
	
	rect = mcCSharp.compile source className:"Rectangle2D" using:#("System") params:#(154, 45)
	rect.Area()
	----------------------------------------------------
*
*/
struct MICRA_CSHARP_STRUCTURE	(
	
	--variables
	debug=true,
	activator = dotNetClass "System.Activator",
	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider",
	--functions
	fn getSource = getSourceFileName(), --get path of this script
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
		
			format "mcCSharp > compile > Load Assemblies(%)\n" cp.ReferencedAssemblies.count
			for i=0 to cp.ReferencedAssemblies.count-1 do (
			
				format "\t%\n" cp.ReferencedAssemblies.item[i]
			)
		)
		cp
	),
	fn compile src className:"" using:#() params:#() = (
		
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
			
			if className == "" then ( --load object in to memory
			
				compilerResults.CompiledAssembly
				
			) else ( --return object as instance
			
				if params.count == 0 then ( --object instance
				
					compilerResults.CompiledAssembly.CreateInstance className
					
				) else ( --object instance with pased parameters
								
					local a = compilerResults.CompiledAssembly
					local obj_type = a.getType className
					local args = dotNet.ValueToDotNetObject params (dotNetObject "System.Object")
					activator.CreateInstance obj_type args
				)
			)
			
		) catch (
			
			format "Unable to compile Assembly:\n\t%\n"  (getCurrentException())
			undefined
		)
	),	
	--TEST
	fn getSourceByClassName className = (
	
		case className of (
			"Rectangle2D" : (
"
using System;
public class Rectangle2D {
	public int length, width;
	public Rectangle2D() {}
	public int Area() { 
		return length * width; 
	} 
}
"
			)
			"Circle2D" : (
			
			)
		)
	),
	fn compileClass className args = (
	
		local source = getSourceByClassName className --maybe pass params as strings
		case className of (
		--???? use auto using search
			"Rectangle2D" : mcCSharp.compile source className:className using:#("System") params:args
		)
	),
	/**
	*@Example
		rect = mcCSharp.new "Rectangle2D"  args:#(10, 122)
		rect.Area()
	*/
	fn new className args:#() type:#object = (
	
		if dotnetClass className == undefined then (
		
			compileClass className args
		)
		if type == #object then dotnetObject className else cotnetClass className
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