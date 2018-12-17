clearListener()
 
 dotnet.loadassembly "System"
 uint64 = dotNetObject "System.UInt64" 50
 dec = dotNetObject "System.Decimal" uint64
 format "uint64: %\n" uint64
 format "dec: %\n" dec
 
 si = dotnetObject "single" 256.2589
si.ToString()
 
 
 dec = dotNetObject "System.Decimal" 2.589
 mc2system.show dec
 dec.GetBits(dec)
 dec.GetTypeCode()
 dec.GetType()
 dec.ToString()
 dec.ToUInt16(dec)
 dec.ToUInt32(dec)
 dec.ToUInt64(dec)
 
 
val = dotNetObject "System.Int32" 45