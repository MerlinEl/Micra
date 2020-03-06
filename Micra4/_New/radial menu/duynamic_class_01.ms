-- (
	source = "
using System.IO;
using System.Dynamic;
using System.Collections.Generic; //internal
public class DynamicDictionary : DynamicObject
{
	// The inner dictionary.
	Dictionary<string, object> dictionary
		= new Dictionary<string, object>();

	// This property returns the number of elements
	// in the inner dictionary.
	public int Count
	{
		get
		{
			return dictionary.Count;
		}
	}
	// If you try to get a value of a property 
	// not defined in the class, this method is called.
	public override bool TryGetMember(
		GetMemberBinder binder, out object result)
	{
		// Converting the property name to lowercase
		// so that property names become case-insensitive.
		string name = binder.Name.ToLower();

		// If the property name is found in a dictionary,
		// set the result parameter to the property value and return true.
		// Otherwise, return false.
		return dictionary.TryGetValue(name, out result);
	}
	// If you try to set a value of a property that is
	// not defined in the class, this method is called.
	public override bool TrySetMember(
		SetMemberBinder binder, object value)
	{
		// Converting the property name to lowercase
		// so that property names become case-insensitive.
		dictionary[binder.Name.ToLower()] = value;

		// You can always add a value to a dictionary,
		// so this method always returns true.
		return true;
	}
}
"
source = "
using System.IO;
using System.Dynamic;
namespace Orien.Tools {
	public class mcDynObj : DynamicObject {
		 public void SetFirstName(string name) { firstName = name; }
	}
}
"
	 --getdir #maxroot + @"Autodesk.Max.dll"
	
	person = mcCSharp.compile "DynamicDictionary"  source:source
	
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	compilerParams.ReferencedAssemblies.AddRange #(
	
		"System.Dynamic.dll"
	)
	compilerParams.GenerateInMemory = true
	compilerParams.GenerateExecutable = false
	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	a = compilerResults.CompiledAssembly
	cls_type = dotNet.getType "DynamicDictionary"
	dc = a.CreateInstance
-- )
	
	
-- 	dotNetClass "System.Collections.Generic"
-- 	dotNetObject "System.Collections.Generic"
	
	
	
	
	dotNet.loadAssembly (micra.AssemblyDir + "Orien.Tools.dll") --load dll in to memory
cls = dotNet.getType "Orien.Tools.mcDynObj"
person = (dotNetClass "System.Activator").CreateInstance cls --create class instance 

person.FirstName = "Ellen"

person["FirstName"]
show person
TrySetMember "FirstName" 123
TryGetMember "FirstName"
p2.FirstName


--local space
(
	local p1 = p2 = undefined
	(
		struct Person (name, age)
		p1 = Person "Bill" 23
	)
	(
		struct Person (name, age, weight)
		p2 = Person "Natalia" 18 55
	)
	--Person = undefined
	format "persons:\n\t1:%\n\t2:%\n" p1 p2
)

person = {

	"name" : "John",
	"age" : 24,
	"country" : "Brno",
	"lang": "Eng"
}
"FirstName"

binder_type = dotNet.getType "System.Dynamic.SetMemberBinder"
binder_type.AsType()
SetMemberBinder = dotnetClass "System.Dynamic.SetMemberBinder" 
SetMemberBinder = dotnetObject "System.Dynamic.SetMemberBinder" "adsdas" false
person.TrySetMember ( "FirstName")



dotNet.loadAssembly (micra.AssemblyDir + "Orien.Tools.dll") --load dll in to memory
cls = dotNet.getType "Orien.Tools.mcDynObj"
inst = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
person = inst.GetBinderInstance "a" true
person.name
p = inst.TrySetMember person "strintGest"
inst.TryGetMember "a"
inst.TryGetMember


person.strintGest



source = "
using System.Collections.Generic;
using System.Dynamic;
public class mcDynObj : DynamicObject {
     public void SetFirstName(string name) { firstName = name; }
}
"