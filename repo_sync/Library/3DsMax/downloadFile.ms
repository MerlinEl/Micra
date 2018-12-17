try 
(
 (dotNetObject "System.Net.WebClient").downloadFile "http://www.313designstudio.com/rappatools/version.dat" "c:\\somedir\\somefile.ext"
)
 catch (
try ((dotNetObject "System.Net.WebClient").downloadString "http://www.mirvadim.com/file.txt") catch () 