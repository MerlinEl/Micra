-- specify an array of points

PlusGDIArray = dotNetObject "System.drawing.point[]" 12

-- and a byte array of the same size

ByteArray = dotNetObject "System.byte[]" 12

-- store the points you want to place in the array


netPointClass = dotnetClass "Drawing.Point"
pointloop = #((pt1 = dotNetObject netPointClass 8 2),
(pt2= dotNetObject netPointClass 8 8),
(pt3= dotNetObject netPointClass 2 8),
(pt4 = dotNetObject netPointClass 2 16),
(pt5 = dotNetObject netPointClass 8 16),
(pt6 = dotNetObject netPointClass 8 22),
(pt7= dotNetObject netPointClass 16 22),
(pt8 = dotNetObject netPointClass 16 16),
(pt9 = dotNetObject netPointClass 22 16),
(pt10 = dotNetObject netPointClass 22 8),
(pt11 = dotNetObject netPointClass 16 8),
(pt12 = dotNetObject netPointClass 16 2))

-- and apply them into the dotnetarray
--for i = 1 to pointloop.count do PlusGDIArray.setvalue pointloop[i] (i-1)
PlusGDIArray = dotNetArray pointloop byte:true

--repeat for the byte array
byteloop = #((Byte1 = dotNetObject netByteClass 0),
(Byte2= dotNetObject netByteClass 1),
(Byte3= dotNetObject netByteClass 1),
(Byte4 = dotNetObject netByteClass 1),
(Byte5 = dotNetObject netByteClass 1),
(Byte6 = dotNetObject netByteClass 1),
(Byte7= dotNetObject netByteClass 1),
(Byte8 = dotNetObject netByteClass 1),
(Byte9 = dotNetObject netByteClass 1),
(Byte10 = dotNetObject netByteClass 1),
(Byte11 = dotNetObject netByteClass 1),
(Byte12 = dotNetObject netByteClass 129))

ByteArray = dotNetArray byteloop byte:true
--for i = 1 to byteloop.count do ByteArray.setvalue Byteloop[i] (i-1)

-- finally add both arrays to a graphicspath object
--System.Drawing.Drawing2D.GraphicsPath <System.Drawing.Point[]>pts <System.Byte[]>types
ClosedPath = dotnetobject "System.Drawing.Drawing2D.GraphicsPath" PlusGDIArray ByteArray
--ClosedPath = dotnetobject "System.Drawing.Drawing2D.GraphicsPath" pointloop byteloop