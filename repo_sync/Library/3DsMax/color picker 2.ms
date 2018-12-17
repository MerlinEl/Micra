-- -- -- -- About
-- Created by John Martini
-- www.JokerMartini.com
-- JokerMartini@hotmail.com

--Additonal Help
-- Andru Phoenix


-- -- -- -- Color Pick Converter
(
--//Additional Functions
CNA = #(
#("ALICEBLUE","F0F8FF"),
#("ANTIQUEWHITE","FAEBD7"),
#("AQUA","00FFFF"),
#("AQUAMARINE","7FFFD4"),
#("AZURE","F0FFFF"),
#("BEIGE","F5F5DC"),
#("BISQUE","FFE4C4"),
#("BLACK","000000"),
#("BLANCHEDALMOND","FFEBCD"),
#("BLUE","0000FF"),
#("BLUEVIOLET","8A2BE2"),
#("BROWN","A52A2A"),
#("BURLYWOOD","DEB887"),
#("CADETBLUE","5F9EA0"),
#("CHARTREUSE","7FFF00"),
#("CHOCOLATE","D2691E"),
#("CORAL","FF7F50"),
#("CORNFLOWERBLUE","6495ED"),
#("CORNSILK","FFF8DC"),
#("CRIMSON","DC143C"),
#("CYAN","00FFFF"),
#("DARKBLUE","00008B"),
#("DARKCYAN","008B8B"),
#("DARKGOLDENROD","B8860B"),
#("DARKGRAY","A9A9A9"),
#("DARKGREEN","006400"),
#("DARKKHAKI","BDB76B"),
#("DARKMAGENTA","8B008B"),
#("DARKOLIVEGREEN","556B2F"),
#("DARKORANGE","FF8C00"),
#("DARKORCHID","9932CC"),
#("DARKRED","8B0000"),
#("DARKSALMON","E9967A"),
#("DARKSEAGREEN","8FBC8F"),
#("DARKSLATEBLUE","483D8B"),
#("DARKSLATEGRAY","2F4F4F"),
#("DARKTURQUOISE","00CED1"),
#("DARKVIOLET","9400D3"),
#("DEEPPINK","FF1493"),
#("DEEPSKYBLUE","00BFFF"),
#("DIMGRAY","696969"),
#("DODGERBLUE","1E90FF"),
#("FIREBRICK","B22222"),
#("FLORALWHITE","FFFAF0"),
#("FORESTGREEN","228B22"),
#("GAINSBORO","DCDCDC"),
#("GHOSTWHITE","F8F8FF"),
#("GOLD","FFD700"),
#("GOLDENROD","DAA520"),
#("GRAY","808080"),
#("GREEN","008000"),
#("GREENYELLOW","ADFF2F"),
#("HONEYDEW","F0FFF0"),
#("HOTPINK","FF69B4"),
#("INDIANRED","CD5C5C"),
#("INDIGO","4B0082"),
#("IVORY","FFFFF0"),
#("KHAKI","F0E68C"),
#("LAVENDER","E6E6FA"),
#("LAVENDERBLUSH","FFF0F5"),
#("LAWNGREEN","7CFC00"),
#("LEMONCHIFFON","FFFACD"),
#("LIGHTBLUE","ADD8E6"),
#("LIGHTCORAL","F08080"),
#("LIGHTCYAN","E0FFFF"),
#("LIGHTGOLDENRODYELLOW","FAFAD2"),
#("LIGHTGRAY","D3D3D3"),
#("LIGHTGREEN","90EE90"),
#("LIGHTPINK","FFB6C1"),
#("LIGHTSALMON","FFA07A"),
#("LIGHTSEAGREEN","20B2AA"),
#("LIGHTSKYBLUE","87CEFA"),
#("LIGHTSLATEBLUE","8470FF"),
#("LIGHTSLATEGRAY","778899"),
#("LIGHTSTEELBLUE","B0C4DE"),
#("LIGHTYELLOW","FFFFE0"),
#("LIME","00FF00"),
#("LIMEGREEN","32CD32"),
#("LINEN","FAF0E6"),
#("MAGENTA","FF00FF"),
#("MAROON","800000"),
#("MEDIUMAQUAMARINE","66CDAA"),
#("MEDIUMBLUE","0000CD"),
#("MEDIUMORCHID","BA55D3"),
#("MEDIUMPURPLE","9370D8"),
#("MEDIUMSEAGREEN","3CB371"),
#("MEDIUMSLATEBLUE","7B68EE"),
#("MEDIUMSPRINGGREEN","00FA9A"),
#("MEDIUMTURQUOISE","48D1CC"),
#("MEDIUMVIOLETRED","C71585"),
#("MIDNIGHTBLUE","191970"),
#("MINTCREAM","F5FFFA"),
#("MISTYROSE","FFE4E1"),
#("MOCCASIN","FFE4B5"),
#("NAVAJOWHITE","FFDEAD"),
#("NAVY","000080"),
#("OLDLACE","FDF5E6"),
#("OLIVE","808000"),
#("OLIVEDRAB","6B8E23"),
#("ORANGE","FFA500"),
#("ORANGERED","FF4500"),
#("ORCHID","DA70D6"),
#("PALEGOLDENROD","EEE8AA"),
#("PALEGREEN","98FB98"),
#("PALETURQUOISE","AFEEEE"),
#("PALEVIOLETRED","D87093"),
#("PAPAYAWHIP","FFEFD5"),
#("PEACHPUFF","FFDAB9"),
#("PERU","CD853F"),
#("PINK","FFC0CB"),
#("PLUM","DDA0DD"),
#("POWDERBLUE","B0E0E6"),
#("PURPLE","800080"),
#("RED","FF0000"),
#("ROSYBROWN","BC8F8F"),
#("ROYALBLUE","4169E1"),
#("SADDLEBROWN","8B4513"),
#("SALMON","FA8072"),
#("SANDYBROWN","F4A460"),
#("SEAGREEN","2E8B57"),
#("SEASHELL","FFF5EE"),
#("SIENNA","A0522D"),
#("SILVER","C0C0C0"),
#("SKYBLUE","87CEEB"),
#("SLATEBLUE","6A5ACD"),
#("SLATEGRAY","708090"),
#("SNOW","FFFAFA"),
#("SPRINGGREEN","00FF7F"),
#("STEELBLUE","4682B4"),
#("TAN","D2B48C"),
#("TEAL","008080"),
#("THISTLE","D8BFD8"),
#("TOMATO","FF6347"),
#("TURQUOISE","40E0D0"),
#("VIOLET","EE82EE"),
#("VIOLETRED","D02090"),
#("WHEAT","F5DEB3"),
#("WHITE","FFFFFF"),
#("WHITESMOKE","F5F5F5"),
#("YELLOW","FFFF00"),
#("YELLOWGREEN","9ACD32")
);

alphaStr = "0123456789ABCDEF";
alphaArr = #("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F")




fn DEC_to_HEX dec = -- used to convert single color value 0-255 to hex bit
(
	n_ = floor (dec / 16)
	_n = dec - n_ * 16
	n_ += 1
	_n += 1
	return alphaArr[n_] + alphaArr[_n]
)

fn HEX_to_DEC hex = -- used to convert single hex bit to 0-255 color value
(
	n_ = findString alphaStr (substring hex 1 1);
	_n = findString alphaStr (substring hex 2 1);
	_n -= 1
	n_ -= 1
	return (n_ * 16 + _n);
)

function hexIsValid theCode =
(
		if theCode.count != 6 then return false;
		theCode = toUpper theCode
		indicator = #(false,false,false,false,false,false)
		for i = 1 to theCode.count do
		(
			for j = 1 to alphaArr.count do
			(
				if (substring theCode i 1) == alphaArr[j] then
				(
					indicator[i] = true
				)				
			)
		)
		for i = 1 to theCode.count do
		(
			if indicator[i] == false then return false
		)
		return true
)

function RGB_to_HEX r g b= -- converts RGB code to HEX code
(
	_r = DEC_to_HEX r
	_g = DEC_to_HEX g
	_b = DEC_to_HEX b
	theCode = _r + _g + _b
	return theCode
)

function HEX_to_RGB theCode = -- converts HEX code to RGB code
(
	theCode = substituteString theCode "#" "" -- audits string for pound sign and deletes it
	theCode = toUpper theCode	
	for i = 1 to CNA.count do ( -- checks if hex is a color string and converts it to hex code
		if theCode == CNA[i][1] then (
			theCode = CNA[i][2] 
		)
	)		
	_r = HEX_to_DEC (substring theCode 1 2)
	_g = HEX_to_DEC (substring theCode 3 2)
	_b = HEX_to_DEC (substring theCode 5 2)
	return #(_r, _g,_b)
)	
--//End Addtional Functions
	
rollout roColorPickConverter "Color Pick Converter 2.0"
(
	colorPicker colorPick "" width:80 height:24 color:[0,0,0] pos:[3,7]
	groupbox gpHex"" width:75 height:30 pos:[89,1]
		label lbHex "#" pos:[96,12]
		edittext etHexColor "" align:#right Text:"000000" fieldWidth:50 pos:[106,10]
	groupbox gp8bit"0-255" width:75 height:84 pos:[7,32]
		spinner spnR1 "R: " width:50 height:14 range:[0,255,0] type:#integer pos:[23,51]
		spinner spnG1 "G: " width:50 height:14 range:[0,255,0] type:#integer pos:[23,71]
		spinner spnB1 "B: " width:49 height:14 range:[0,255,0] type:#integer pos:[24,91]
	groupbox gpArithmetic "0-1.0" width:75 height:84 pos:[89,32]
		spinner spnR2 "R: " width:50 height:14 range:[0,1,0] scale:0.01 pos:[105,51]
		spinner spnG2 "G: " width:50 height:14 range:[0,1,0] scale:0.01 pos:[105,71]
		spinner spnB2 "B: " width:49 height:14 range:[0,1,0] scale:0.01 pos:[106,91]
	
--// Functions
	fn convertColor hexColor = 
	(
		value1= 0
		value2= 0
		
		case hexColor[1] of 
		(
			"1":(value1=1*16)
			"2":(value1=2*16)
			"3":(value1=3*16)
			"4":(value1=4*16)
			"5":(value1=5*16)
			"6":(value1=6*16)
			"7":(value1=7*16)
			"8":(value1=8*16)
			"9":(value1=9*16)
			"A":(value1=10*16)
			"B":(value1=11*16)
			"C":(value1=12*16)
			"D":(value1=13*16)
			"E":(value1=14*16)
			"F":(value1=15*16)
			"a":(value1=10*16)
			"b":(value1=11*16)
			"c":(value1=12*16)
			"d":(value1=13*16)
			"e":(value1=14*16)
			"f":(value1=15*16)
		)
		case hexColor[2] of 
		(
			"1":(value2=1)
			"2":(value2=2)
			"3":(value2=3)
			"4":(value2=4)
			"5":(value2=5)
			"6":(value2=6)
			"7":(value2=7)
			"8":(value2=8)
			"9":(value2=9)
			"A":(value2=10)
			"B":(value2=11)
			"C":(value2=12)
			"D":(value2=13)
			"E":(value2=14)
			"F":(value2=15)
			"a":(value2=10)
			"b":(value2=11)
			"c":(value2=12)
			"d":(value2=13)
			"e":(value2=14)
			"f":(value2=15)
		)
		newDecValue = value1 + value2
		return newDecValue
	)
	
	fn updateValues =
	(
	colorPick.color = (color spnR1.value spnG1.value spnB1.value)
	myHEX = RGB_to_HEX (colorPick.color.r) (colorPick.color.g) (colorPick.color.b)
	etHexColor.text = "" + (myHEX) as string + ""
	)
	
--// Color Picker Actions
	on colorPick changed col do 
	( 
	spnR1.value = col.r
	spnG1.value = col.g
	spnB1.value = col.b
	spnR2.value = col.r/255
	spnG2.value = col.g/255
	spnB2.value = col.b/255
	
	myHEX = RGB_to_HEX (col.r) (col.g) (col.b)
	etHexColor.text = "" + (myHEX) as string + ""
	)
	
--// 8 Bit Spinners
	on spnR1 changed val do
	(
	spnR2.value = ((val as float)/255)
	updateValues()
	)
	on spnG1 changed val do
	(
	spnG2.value = ((val as float)/255)
	updateValues()
	)
	on spnB1 changed val do
	(
	spnB2.value = ((val as float)/255)
	updateValues()
	)

--// Arithmetic Spinners
	on spnR2 changed val do
	(
	spnR1.value = val*255
	updateValues()
	)
	on spnG2 changed val do
	(
	spnG1.value = val*255
	updateValues()
	)
	on spnB2 changed val do
	(
	spnB1.value = val*255
	updateValues()
	)
	
--// Hex Color Field
	on etHexColor entered text do 
	(
		if text.count == 6 then 
		(
		part1 = text[1] + text[2]
		part2 = text[3] + text[4]
		part3 = text[5] + text[6]

		hexColorPart1 = convertColor(part1)
		hexColorPart2 = convertColor(part2)
		hexColorPart3 = convertColor(part3)
		myNewColor = color hexColorPart1 hexColorPart2 hexColorPart3
		colorPick.color = myNewColor
		
		spnR1.value = colorPick.color.r
		spnG1.value = colorPick.color.g
		spnB1.value = colorPick.color.b
		spnR2.value = colorPick.color.r/255
		spnG2.value = colorPick.color.g/255
		spnB2.value = colorPick.color.b/255
		
		)
		else
		(
		print "Invalid 6 digit hex color!"
		)
	)

)
	try(destroyDialog roColorPickConverter )catch()
	createDialog roColorPickConverter 171 123 style:#(#style_SysMenu, #style_ToolWindow)
)