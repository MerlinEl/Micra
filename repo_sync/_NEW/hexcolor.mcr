---------------------------------------------------------------------
/*
This script converts a hex string into a color value in max
useful for copying a hex string from photoshop directly into max

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT 
HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS 
OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

copyright mark tsang 2011
info@marktsang.com

*/
macroScript marktsang_hexColor 
category:"Mark Tsang" 
buttonText:"HexColor"
toolTip:"HexColor"
(
	fn colorToHex c=
	(
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
		ret
	)


	fn hexToColor h=
	(
		if h[1] == "#" then
		(
			if h.count == 7 then
			(
				colorArray = #()
				for i = 2 to 6 by 2 do
				(
					hexString = subString h i 2
					cv = (("0X"+hexString) as integer)
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
				c = color colorArray[1] colorArray[2] colorArray[3]
			)
		)
		else
		(
			if h.count == 6 then
			(
				colorArray = #()
				for i = 1 to 5 by 2 do
				(
					hexString = subString h i 2
					cv = (("0X"+hexString) as integer)
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
				c = color colorArray[1] colorArray[2] colorArray[3]
			)
		)
		c
	)

	rollout hexColorRoll "hex Color" width:105 height:50
	(
		editText hexString_edt "hex:" text:"" labelOnTop:false
		colorpicker hexColor_clr "Color:" color:[0,0,255] modal:false
		on hexString_edt changed txt do 
		(
			c = hexToColor txt
			if c != undefined then
			(
				hexColor_clr.color = c
			)
		)
		
		on hexColor_clr changed c do 
		(
			str = colorToHex c
			hexString_edt.text = str
		)
		--on theColor changed new_col do selection.wirecolor = new_col
	)
	createDialog hexColorRoll
)