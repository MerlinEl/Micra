reg=dotNetClass "Microsoft.Win32.Registry"
reg.localMachine


	reg=dotNetClass "Microsoft.Win32.Registry"
 	
 	reg.LocalMachine.GetSubKeyNames()
 	
 	softWare=reg.LocalMachine.OpenSubKey "SOFTWARE" true --Opens key and makes it writable.
 	pen=softWare.CreateSubKey "Pen" --Creates a new key. 
 	
 	dnStr = dotNetObject "System.String" "1.0"
 	
 	--This isn't working. Can any one shed any light on it?
 	pen.SetValue "Version" dnStr --Errors
 	
 	format "%\n" (pen.GetValue("Version"))
 	
 	pen.close()
 	softWare.close()



setValue("DWordValue", 42, RegistryValueKind.DWord)
System.Double.TryParse "1.0"


local dValue = (dotnetclass "System.Convert").toDouble("1.1")