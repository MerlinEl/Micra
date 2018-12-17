r--red
g--green
b--blue
a--alpha

h--hue
s--saturation
v--value


fn rgbToHex clr =(bit.intAsHex clr.r + bit.intAsHex clr.g + bit.intAsHex clr.b)
rgbToHex (color 0 47 255)

--color blending
selection[2].wirecolor = (selection[1].wirecolor + selection[3].wirecolor)/2

fn blendColors c1 c2 = ((c1+c2)/2)


--color gradient
	fn objectGradient c1 c2 = -- 
	(
		local sel = selection as array
		if sel.count < 2 do return false
		
		stepsize_r = (c2.r - c1.r)/$.count
		stepsize_g = (c2.g - c1.g)/$.count
		stepsize_b = (c2.b - c1.b)/$.count
		
		for i=1 to sel.count do
		(
			local newColor = (color \
			((i*stepsize_r)+c1.r-stepsize_r) \
			((i*stepsize_g)+c1.g-stepsize_g) \
			((i*stepsize_b)+c1.b-stepsize_b))
			$[i].wirecolor = newColor
		)
	)
	objectGradient green blue
-------------------

fn colorAsInt col = --get color (color 255 255 0) return integer 16776960
(
	((col.r as integer)*256 + (col.g as integer))*256 + (col.b as integer)
)

fn intAsColor intArr = --get array  #(16776960) return array #((color 255 255 0))
( 
	for p in intArr collect (r=p/256^2; g=p/256-r*256; bmp=mod p 256; color r g bmp)
)
---------------------------------------------------------
color:[0, 255, 255]
color:red --red, blue,
---------------------------------------------------------
rollout test_bitmaps "Testing Bitmap"
(
bitmap BitmapImage bitmap:(bitmap 50 50 color:blue)
)
createDialog test_bitmaps
---------------------------------------------------------

((colorMan.getColor #timeSliderBg)*255)as color
((colorMan.getColor #background)*255)as color
((colorMan.getColor #pressedButton)*255)as color

---------------------------------------------------------
rollout xx "Untitled" width:264 height:132
(
	Local bgColor = ((colorMan.getColor #background)*255)
	Local fgColor = ((colorMan.getColor #pressedButton)*255)
	
	bitmap bmp1 "Bitmap" pos:[4,4] width:256 height:124 bitmap:(bitmap 258 76 color:bgColor)
	groupBox grp1 "" pos:[10,4] width:242 height:116
	
	on xx rbuttonup pos do
		(
		destroyDialog xx
		)
)
createdialog xx style:#(#style_sysMenu) bitmap:(bitmap 264 132 color:fgColor)
---------------------------------------------------------
red
green
blue
white
black
orange
yellow
brown
gray

(color 0, 0, 0) is black
(color 255, 255, 255) is white
(color 255, 0, 0) is red
(color 0, 255, 0) is green
(color 0, 0, 255) is blue
(color 255, 255, 0) is yellow
(color 0, 255, 255) is cyan
(color 255, 0, 255) is magenta

<color>.red or .r : Float
<color>.green or .g : Float
<color>.blue or .b : Float
<color>.alpha or .a : Float
color component properties
<color>.hue or .h : Float
<color>.saturation or .s : Float
<color>.value or .v : Float


fn setObjectsGradient color_1 color_2 =
(
	local sel = selection as array
	if sel.count < 3 do return false
	sel[1        ].wirecolor = color_1
	sel[sel.count].wirecolor = color_2
	for i=1 to (sel.count-2) do
	(
			color_1.alpha         = (255/(sel.count-2))*i
			color_2.alpha         = (255/(sel.count-2))*i
			format "color_1:%\tcolor_2:%\n" color_1 color_2
			sel[i+2].wirecolor = (composite color_1 color_2)
	)
)
setObjectsGradient blue red



fn cToV colorVal =
(
tempVal = colorVal as point3
return [(tempVal.x/255), (tempVal.y/255), (tempVal.z/255)]
)
fn vToC valueVal =
(
return [(valueVal.x*255 as integer), (valueVal.y*255 as integer), (valueVal.z*255 as integer)] as color
)
fn opacityMod pixelR pixelB opacityV =
(
pixelR.x = pixelB.x + (pixelR.x - pixelB.x)*opacityV
pixelR.y = pixelB.y + (pixelR.y - pixelB.y)*opacityV
pixelR.z = pixelB.z + (pixelR.z - pixelB.z)*opacityV
return pixelR
)
 
fn normalBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [pixelS.x, pixelS.y, pixelS.z]
 
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR 
)
fn averageBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [(pixelB.x+pixelS.x)/2, (pixelB.y+pixelS.y)/2, (pixelB.z+pixelS.z)/2]
 
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR
)
fn multiplyBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [pixelB.x*pixelS.x, pixelB.y*pixelS.y, pixelB.z*pixelS.z]
 
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR
)
fn screenBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [pixelB.x+pixelS.x-pixelB.x*pixelS.x, pixelB.y+pixelS.y-pixelB.y*pixelS.y, pixelB.z+pixelS.z-pixelB.z*pixelS.z]
 
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR
)
fn darkenBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [0,0,0] 
if pixelB.x > pixelS.x then pixelR.x = pixelS.x else pixelR.x = pixelB.x
if pixelB.y > pixelS.y then pixelR.y = pixelS.y else pixelR.y = pixelB.y
if pixelB.z > pixelS.z then pixelR.z = pixelS.z else pixelR.z = pixelB.z 
 
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR
)
fn lightenBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [0,0,0] 
if pixelB.x < pixelS.x then pixelR.x = pixelS.x else pixelR.x = pixelB.x
if pixelB.y < pixelS.y then pixelR.y = pixelS.y else pixelR.y = pixelB.y
if pixelB.z < pixelS.z then pixelR.z = pixelS.z else pixelR.z = pixelB.z 
 
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR
)
fn differenceBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [abs (pixelB.x-pixelS.x), abs (pixelB.y-pixelS.y), abs (pixelB.z-pixelS.z)]
 
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR
)
fn negationBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [1-(abs (1-pixelB.x-pixelS.x)), 1-(abs (1-pixelB.y-pixelS.y)), 1-(abs (1-pixelB.z-pixelS.z))]
 
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR 
)
fn exclusionBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [pixelB.x+pixelS.x-2*pixelB.x*pixelS.x, pixelB.y+pixelS.y-2*pixelB.y*pixelS.y, pixelB.z+pixelS.z-2*pixelB.z*pixelS.z]
 
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR 
)
fn overlayBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [0,0,0]
 
if pixelB.x <= 0.5 then
(
pixelR.x = 2*pixelB.x*pixelS.x
)
else
(
pixelR.x = 1-2*(1-pixelB.x)*(1-pixelS.x)
)
 
if pixelB.y <= 0.5 then
(
pixelR.y = 2*pixelB.y*pixelS.y
)
else
(
pixelR.y = 1-2*(1-pixelB.y)*(1-pixelS.y)
)
 
if pixelB.z <= 0.5 then
(
pixelR.z = 2*pixelB.z*pixelS.z
)
else
(
pixelR.z = 1-2*(1-pixelB.z)*(1-pixelS.z)
)
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR
)
fn hardLightBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [0,0,0]
 
if pixelS.x <= 0.5 then
(
pixelR.x = 2*pixelB.x*pixelS.x
)
else
(
pixelR.x = 1-2*(1-pixelB.x)*(1-pixelS.x)
)
 
if pixelS.y <= 0.5 then
(
pixelR.y = 2*pixelB.y*pixelS.y
)
else
(
pixelR.y = 1-2*(1-pixelB.y)*(1-pixelS.y)
)
 
if pixelS.z <= 0.5 then
(
pixelR.z = 2*pixelB.z*pixelS.z
)
else
(
pixelR.z = 1-2*(1-pixelB.z)*(1-pixelS.z)
)
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR
)
fn softLightBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [2*pixelB.x*pixelS.x+(pow pixelB.x 2)-2*(pow pixelB.x 2)*pixelS.x, 2*pixelB.y*pixelS.y+(pow pixelB.y 2)-2*(pow pixelB.y 2)*pixelS.y, 2*pixelB.z*pixelS.z+(pow pixelB.z 2)-2*(pow pixelB.z 2)*pixelS.z]
 
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR 
)
fn colorDodgeBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [pixelB.x/(1-pixelS.x), pixelB.y/(1-pixelS.y), pixelB.z/(1-pixelS.z)]
 
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR 
)
fn inverseDodgeBlend pixelB pixelS opacityV: =
(
pixelB = cToV pixelB
pixelS = cToV pixelS
pixelR = [pixelS.x/(1-pixelB.x), pixelS.y/(1-pixelB.y), pixelS.z/(1-pixelB.z)]
 
if not opacityV == unsupplied then
return vToC (opacityMod pixelR pixelB opacityV)
else
return vToC pixelR 
)


	fn getColor num =
	(
		case num of --Table 32 colors
		(
			1: color 255 255 255 --bila
			2: color 252 241 3 --zluta
			3: color 254 252 20 --zluta2
			4: color 254 95 4 --oranz
			5: color 230 68 30 --oranz2
			6: color 230 38 23 --cervena
			7: color 203 22 37 --cervena2
			8: color 147 27 24 --cervena3
			9: color 90 62 110 --fialova
			10: color 115 98 168 --levandulova
			11: color 196 142 200 --serikova
			12: color 236 0 140 --ruzova
			13: color 240 110 169 --ruzova2
			14: color 24 42 170 --modra
			15: color 9 79 177 --horcova
			16: color 4 141 222 --modra3
			17: color 154 163 162 --stribrna
			18: color 168 151 82 --zlata
			19: color 138 112 55 --medena
			20: color 32 71 53 --zelena 
			21: color 0 133 62 --zelena2
			22: color 4 160 14 --zelena3
			23: color 60 173 33 --limetka
			24: color 109 124 105 --salvejova
			25: color 209 207 166 --bezova
			26: color 61 41 42 --hneda
			27: color 96 57 19 --hneda2
			28: color 177 98 31 --oriskova
			29: color  198 156 109 --pletova
			30: color 160 143 87 --hneda3
			31: color 35 35 35 --cerna
			32: color 108 129 124 --seda
		)
	)
	
	
	
	---------
	---XML---
	---------
	function GetElementsWithClassName(elementName,className) {
	var allElements = document.getElementsByTagName(elementName);
	var elemColl = new Array();
	for (i = 0; i< allElements.length; i++) {
		if (allElements[i].className == className) {
			elemColl[elemColl.length] = allElements[i];
		}
	}
	return elemColl;
}

function Color(r,g,b) {
	this.r = r;
	this.g = g;
	this.b = b;
	this.coll = new Array(r,g,b);
	this.valid = cVerify(this.coll);
	this.text = cText(this.coll);
	this.bg = cText(this.coll);
}

function cVerify(c) {
	var valid = 'n';
	if ((!isNaN(c[0])) && (!isNaN(c[1])) && (!isNaN(c[2]))) {valid = 'y'}
	return valid;
}

function cText(c) {
	var result = '';
	var d = 1;
	if (colType == 'rgbp') {d = 2.55}
	for (k = 0; k < 3; k++) {
		val = Math.round(c[k]/d);
		piece = val.toString(base);
		if (colType == 'hex' && piece.length < 2) {piece = '0' + piece;}
		if (colType == 'rgbp') {piece = piece + '%'};
		if (colType != 'hex' && k < 2) {piece = piece + ',';}
		result = result + piece;
	}
	if (colType == 'hex') {result = '#' + result.toUpperCase();}
		else {result = 'rgb(' + result + ')';}
	return result;
}

function colorParse(c,t) {
	var m = 1;
	c = c.toUpperCase();
	col = c.replace(/[\#rgb\(]*/,'');
	if (t == 'hex') {
		if (col.length == 3) {
			a = col.substr(0,1);
			b = col.substr(1,1);
			c = col.substr(2,1);
			col = a + a + b + b + c + c;
		}
		var num = new Array(col.substr(0,2),col.substr(2,2),col.substr(4,2));
		var base = 16;
	} else {
		var num = col.split(',');
		var base = 10;
	}
	if (t == 'rgbp') {m = 2.55}
	var ret = new Array(parseInt(num[0],base)*m,parseInt(num[1],base)*m,parseInt(num[2],base)*m);
	return(ret);
}

function colorPour(pt,n) {
	var textObj = document.getElementById(pt + n.toString());
	var colObj = document.getElementById(pt.substring(0,1) + n.toString());
	if (pt == 'col') {temp = ends[n]} else {temp = palette[n]}
	if (temp.valid == 'y') {
		textObj.value = temp.text;
		colObj.style.backgroundColor = temp.bg;
	}
}

function colorStore(n) {
	var inVal = 'col'+n.toString();
	var inCol = document.getElementById(inVal).value;
	var c = colorParse(inCol,colType);
	ends[n] = new Color(c[0],c[1],c[2]);
	if (ends[n].valid == 'y') {colorPour('col',n)}
}

function stepCalc() {
	var steps = parseInt(document.getElementById('steps').value) + 1;
	step[0] = (ends[1].r - ends[0].r) / steps;
	step[1] = (ends[1].g - ends[0].g) / steps;
	step[2] = (ends[1].b - ends[0].b) / steps;
}

function mixPalette() {
	var steps = parseInt(document.getElementById('steps').value);
	var count = steps + 1;
	palette[0] = new Color(ends[0].r,ends[0].g,ends[0].b);
	palette[count] = new Color(ends[1].r,ends[1].g,ends[1].b);
	for (i = 1; i < count; i++) {
		var r = (ends[0].r + (step[0] * i));
		var g = (ends[0].g + (step[1] * i));
		var b = (ends[0].b + (step[2] * i));
			palette[i] = new Color(r,g,b);
	}
	for (j = count + 1; j < 12; j++) {
		palette[j].text = '';
		palette[j].bg = 'white';
	}
}

function drawPalette() {
	stepCalc();
	mixPalette();
	for (i = 0; i < 12; i++) {
		colorPour('pal',i);
	}		
}

function setCursor(n) {
	cursor = n;
	var obj1 = document.getElementById('col0');
	var obj2 = document.getElementById('col1');
	obj1.style.backgroundColor = '';
	obj2.style.backgroundColor = '';
	if (cursor >= 0 && cursor <= 1) {
		document.getElementById('col'+cursor).style.backgroundColor = '#FF9';
	}
}

function colorIns(c) {
	var obj = document.getElementById('col'+cursor);
	var result = colorParse(c,'hex');
	ends[cursor] = new Color(result[0],result[1],result[2]);
	obj.value = ends[cursor].text;
	if (ends[cursor].valid == 'y') {colorPour('col',cursor)}
}

function setType(inp) {
	colType = inp;
	if (inp == 'hex') {base = 16;} else {base = 10;}
	for (i = 0; i < 2; i++) {
		var obj = document.getElementById('col' + i);
		if (ends[i].valid == 'y') {
			ends[i] = new Color(ends[i].r,ends[i].g,ends[i].b);
			obj.value = ends[i].text;
		}
	}
	drawPalette();
	document.getElementById('hex').className = '';
	document.getElementById('rgbd').className = '';
	document.getElementById('rgbp').className = '';
	document.getElementById(inp).className = 'coltype';	
}

function init(inp) {
	if (!inp) {
		obj = GetElementsWithClassName('a','coltype');
		inp = obj[0].id;
	}
	document.getElementById(inp).className = 'coltype';
	for (i = 0; i < 2; i++) {
		ends[i] = new Color;
		document.getElementById('col'+i).value = '';
		document.getElementById('c'+i).style.background = 'white';
	}
	for (j = 0; j < 12; j++) {
		palette[j] = new Color;
		document.getElementById('pal'+j).value = '';
		document.getElementById('p'+j).style.background = 'white';
	}
	document.getElementById('steps').value = '0';
	document.getElementById('col0').focus();
}


function rgbToHex(R,G,B) {return toHex(R)+toHex(G)+toHex(B)}
function toHex(n) 
{
	 n = parseInt(n,10);
	 if (isNaN(n)) return "00";
	 n = Math.max(0,Math.min(n,255));
	 return "0123456789ABCDEF".charAt((n-n%16)/16)
		  + "0123456789ABCDEF".charAt(n%16);
}
 
 
 

 