--------------------------------------------------------------------------------
/* mcMsxPy by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct MC_MSX_PY	(
	
	--variables
	py =  python.import("__builtin__"),
	json = python.import("json"),
	sys = python.import("sys"),
	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn buildPyDictFromArray keyArray valueArray =  (	
		
		local pyDict
		if keyArray.count == valueArray.count then (		
			
			pyDict = py.dict()
			for each = 1 to keyArray.count do				
				pyDict[keyArray[each]] = valueArray[each]		
		)
		pyDict		
	),	
	fn writeJson file data = (		
		jsonFile = py.open file "wb"
		json.dump data jsonFile indent:4
		jsonFile.close()
	),
	fn readJson file asDataPair:false = (
		jsonFile = py.open file "r"
		dLoad =json.load jsonFile
		jsonFile.close()
		
		if asDatapair then
			for each in (dLoad.items() as array) collect (dataPair key:each[1] value:each[2])
		else
			dLoad
	),
	/**
	*@Example
		mcMsxPy.printSysPaths()
	*/
	fn printSysPaths = (
	
		for i = 0 to sys.path.count - 1 do format "%\n" sys.path[i]
	),
	/**
	*@Example
		core_py_dir = trimRight micra.CorePyDir "\\"
		core_py_dir = mcString.replaceAll core_py_dir "\\" "\\\\"
		mcMsxPy.isDirRegistred core_py_dir
	*/
	fn isDirRegistred dir = (
	
		local result = false
		for i = 0 to sys.path.count - 1 do (
			if sys.path[i] == dir do (
				result = true
				exit
			)
		)
		result
	)
	/*<end>*/
)	
 --create instance
Global mcMsxPy = mcStructMan.instanceStructure MC_MSX_PY "mcMsxPy"



/*
mxsPythonHelper = mxsPythonHelperStruct()
dictObj = mxsPythonHelper.buildPyDictFromArray #("woop", "yeah", "cmon") #(true, "meh", 2017)
strJPath =  @"C:\Temp\Woop.json" 

mxsPythonHelper.writeJson strJPath dictObj
rj = mxsPythonHelper.readJson strJPath asDatapair:true

Woop.json
{
    "cmon": 2017, 
    "yeah": "meh", 
    "woop": true
}
*/




/*
-----in_maxscript-----

temp = "flux"

-----in_python(max)–

msString ="'temp'"
ret = MaxPlus.Core.EvalMAXScript(msString)
print ret.Get()
--> flux
        ↑
        ↓
-----in_python(max)–

msString ='temp = "capacitor"'
MaxPlus.Core.EvalMAXScript(msString)
--> <MaxPlus.FPValue; proxy of <Swig Object of type 'Autodesk::Max::FPValue *' at 0x000001E4B8A75690> >
-----in_maxscript-----

print temp
--> "capacitor"





core_py_dir = trimRight micra.CorePyDir "\\"
core_py_dir = mcString.replaceAll core_py_dir "\\" "\\\\"
py_str = "import sys\n " + core_py_dir + " in sys.path"
installed = python.execute(py_str)
installed = python.execute("1 == 2")



py =  python.import("__builtin__")
sys = python.import("sys")
py_dict = py.dict()
for i = 0 to sys.path.count - 1 do print sys.path[i]
sys.path[0]
sys.path.append(core_py_dir) 


core_py_dir = trimRight micra.CorePyDir "\\"
core_py_dir = mcString.replaceAll core_py_dir "\\" "\\\\"
mcMsxPy.isDirRegistred core_py_dir
mcMsxPy.printSysPaths()

python.execute("import MAX_PORT")
python.execute("var_str in vars() or var_str in globals() or 'var_str in vars(__builtins__)")


python.execute("MAX_PORT in vars() or MAX_PORT in globals()")

var_str = "MAX_PORT"
py_cmd = "if "+var_str+" is None:
	print ('undefined')
else:
	print ('var:', "+var_str+")\n"
python.execute(py_cmd)


var_str = "MAX_PORT"
py_cmd = "try:"+var_str+"\nexcept NameError: print ('undefined')"
result = python.execute(py_cmd)
py_cmd = "def checkVar(var_str):\n\ttry:\n\t\tvar_str\n\t\treturn true\n\texcept:\n\t\treturn None\n"
python.import(py_cmd)
var_str = python.execute("from 'mcLoader' import 'MAX_PORT'")
var_str = python.import('mcLoader')
*/