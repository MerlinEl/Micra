clearListener()
 dotnet.loadassembly "System"
 uint64 = dotNetObject "System.UInt64" 50
 dec = dotNetObject "System.Decimal" uint64
 format "uint64: %\n" uint64
 format "dec: %\n" dec