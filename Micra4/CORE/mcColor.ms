--------------------------------------------------------------------------------
/* mcColor by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*/
struct MICRA_COLOR (

	alphaStr = "0123456789ABCDEF",
	alphaArr = #("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"),
	fn getSource = getSourceFileName(), --get path of this script
	fn hexToDec num = -- used to convert single hex bit to 0-255 color value
	(
		n_ = findString alphaStr (substring num 1 1);
		_n = findString alphaStr (substring num 2 1);
		_n -= 1
		n_ -= 1
		return (n_ * 16 + _n);
	),
	fn decToHex dec = -- used to convert single color value 0-255 to hex bit
	(
		n_ = floor (dec / 16)
		_n = dec - n_ * 16
		n_ += 1
		_n += 1
		return alphaArr[n_] + alphaArr[_n]
	),
	/**
	* @example mcColor.rgbToHex (color 60 32 104)
	*/
	fn rgbToHex c= ( --thanks to Mark Tsang
		
		if classOf c != Color do return undefined
		ret = "#"
		h = bit.intashex c.r
		if h.count < 2 then
		(
			h = ("0"+h)
		)
		ret+= h

		h = bit.intashex c.g
		if h.count < 2 then
		(
			h = ("0"+h)
		)
		ret+= h

		h = bit.intashex c.b
		if h.count < 2 then
		(
			h = ("0"+h)
		)
		ret+= h
		execute ret
	),
	/**
	* @example	mcColor.hexToRGB #3c2068
	* @example	mcColor.hexToRGB dcfd38
	*/
	fn hexToRGB hex_color= ( --thanks to Mark Tsang
		
		local hex_string = substituteString hex_color "#" "" -- audits string for pound sign and deletes it
		hex_string = toUpper hex_string
		local r = hexToDec (substring hex_string 1 2)
		local g = hexToDec (substring hex_string 3 2)
		local b = hexToDec (substring hex_string 5 2)
		color r  g  b
	),
	
	/* hex to rgb explnation
	cb = "f26d7d"
	colRed = ("0x" + substring cb 1 2) as integer
      colGreen = ("0x" + substring cb 3 2) as integer
       colBlue = ("0x" + substring cb 5 2) as integer
      color colRed colGreen colBlue
	
	fn hexToRGB hex = -- converts HEX code to RGB code
	(
		hex = substituteString hex "#" "" -- audits string for pound sign and deletes it
		hex = toUpper hex	
		if hex_string.count != 6 do return undefined
		colorArray = #()
		for i = 1 to 6 by 2 do (
			
			local two_chars = subString hex_string i 2
			local cv = (("0X"+two_chars) as integer)
			if cv != undefined then
			(
				append colorArray cv
			)
			else 
			(
				format "invalid hex string supplied\n"
				return undefined
			)
		)
		return color colorArray[1] colorArray[2] colorArray[3]
	)	
	fn rgbToHEX clr =-- converts RGB code to HEX code
	(
		return ("#"+decToHex clr.r + decToHex clr.g + decToHex clr.b )
	)
	*/
	fn colorAsInt col = --get color (color 255 255 0) return integer 16776960
	(
		((col.r as integer)*256 + (col.g as integer))*256 + (col.b as integer)
	),
	fn intAsColor int = --get integer 16776960 return color (color 255 255 0)
	( 
		(r=int/256^2; g=int/256-r*256; bmp=mod int 256; color r g bmp)
	),
	fn blendColors c1 c2 = ((c1+c2)/2),
	fn randomColor=(color (random 1 255)  (random 1 255) (random 1 255)) 
	/*<end>*/
)
--create instance
Global mcColor = mcStructMan.instanceStructure MICRA_COLOR "mcColor"