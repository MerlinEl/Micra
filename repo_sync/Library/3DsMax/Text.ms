--Returns a Point2 value containing the size of the string in pixels if it was displayed in a command panel.
<Point2> GetTextExtent<string>


viewtext = "Vertices: " + ($.selectedverts.count) as string+"\\"+(getPolygoncount $)[2] as string
-----------------------------------------------------------
/*
\" -- a double quote character
\n -- a newline character
\r -- a carriage return character
\t -- a TAB character
\* -- an asterisk character
\? -- a question mark character
\\ -- a single "\" character
\% -- a percent character
\x{d} -- a hexadecimal character
*/
-----------------------------------------------------------
as string   | "#("Box02", "Sphere02")"
as array    |  #("Box02", "Sphere02")
as bitarray |  #{"Box02", "Sphere02"}
-----------------------------------------------------------
format ", " -- write a comma
-----------------------------------------------------------
x = "Copyright \xa9 1997, FrabWorks, Inc"
--Result:
"Copyright © 1997, FrabWorks, Inc"
--Hexadecimal a9 is the code for ©
-----------------------------------------------------------
char="0123456789abcdef"
for i=1 to char.count do
format "%\n" char[i]
-----------------------------------------------------------
char="0123456789abcdef"
for i=1 to char.count do
for j=1 to char.count do
(
format "%\n" char[i] char[j]
)
-----------------------------------------------------------
char="0123456789abcdef"
for i=1 to char.count do
format " %," char[i]
--Result:
 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, a, b, c, d, e, f,OK
-----------------------------------------------------------