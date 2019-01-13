28-Feb-2016
Robert Chandler<support@helpwareGroup.com>
KeyHelp 1.2

This 32bit app has problems installing under Windows 8/10 64bit.
However if I grab the KeyHelp files and installed on a Win7 machine,
and copy & register the KeyHelp.ocx to a common location like C:\Windows\SysWOW64
then KeyHelp.CHM will work without errors if I open KeyHelp.CHM using KeyHH.exe
instead of opening with the default HTML Help launcher hh.exe.

This zip contains the files installed by KeyHelpSetup.exe (1.2)
since the old 32bit installer wont work under Win 8/10 64bit.

To proceed
1. Unzip all files to a folder
2. Register KeyHelp.ocx (I've included MJsDiags.exe for easy registration)
3. Open KeyHelp.chm using KeyHH.exe (just drag the chm onto KeyHH.exe) 
   instead of the default Microsoft HH.exe. (I've included KeyHH.exe 1.1 to make this easy)
   http://keyworks.helpmvp.com/home/keyhh

Note that when installing to a customers machine we register KeyHelp.ocx 
to a common folder (since only one instance of an ocx will register).
