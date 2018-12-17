extractDir = "E:\\Merlin\\Micra\\temp\\"
msZip.fileInPackage "E:\Merlin\Micra\temp\Clr.mzp" &extractDir

local extractDir = "", dropFile = ""
msZip.unloadPackage' "E:\Merlin\Micra\temp\PB_Func.mse" &extractDir &dropFile



maz "E:\\Merlin\\Micra\\temp\\foo.mzp" LanfArr

unmaz "foo.mzp" "E:\\Merlin\\Micra\\temp\\"