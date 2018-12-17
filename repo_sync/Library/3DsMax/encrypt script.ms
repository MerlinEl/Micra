See this topiks
http://blog.duber.cz/3ds-max/checksums-in-3ds-max
http://forums.cgsociety.org/showthread.php?f=98&t=638998&page=2&pp=15


Example from cgsociety.org :

fn fl_getMacAdressByDotNet = (
upperStr="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
lowerStr="abcdefghijklmnopqrstuvwxyz"
NWIF = dotnetClass "System.Net.NetworkInformation.NetworkInterface" 
the_Mac_array = NWIF.GetAllNetworkInterfaces() -- this is an array of all the Networks 
the_Mac_Address = "" --The Mac Address with capital letter 
the_Hex_Array = #() -- Emty Array to hold the Bytes after converted to hex
for i = 1 to the_Mac_array.count do
(
The_Physical_Address = the_Mac_array[i].GetPhysicalAddress() -- Get The Physical Address of all the networks 
The_Physical_Address_Bytes = The_Physical_Address.GetAddressBytes() as array -- Get The Physical Address Bytes 
for foo in The_Physical_Address_Bytes do 
(
tempHex = bit.intashex foo -- convert to hex
if tempHex.count == 2 then 
(
if (idx = findString lowerStr tempHex[1]) != undefined then tempHex[1] = upperStr[idx]
if (idx = findString lowerStr tempHex[2]) != undefined then tempHex[2] = upperStr[idx]
the_Mac_Address += tempHex
)
else 
(
if (idx = findString lowerStr tempHex) != undefined then tempHex = upperStr[idx]
the_Mac_Address += "0" + tempHex
)
)
)
-- call the Mac Address
the_Mac_Address
) 
fl_getMacAdressByDotNet()