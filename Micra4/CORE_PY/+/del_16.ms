global mxsPythonHelper
struct mxsPythonHelperStruct (
	
	py =  python.import("__builtin__"),
	json = python.import("json"),
	
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
	)	
)
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