getUserProp <node> <key_string> 
setUserProp <node> <key_string> <value>
getUserPropBuffer <node> 
setUserPropBuffer <node> <string> 


#you can find the explanation in the 'MAXScript Editor - Defining Custom Keyboard Shortcuts' tread, from the maxscript help

#add extra keyboard shortcuts here
user.shortcuts=\
#local help file for max
Ctrl+F1|IDM_HELP_SCITE| 
#Abbrevation shortcut
Ctrl+Shift+A|IDM_ABBREV|


#autocomplete from Maxscript.Api file
autocompleteword.automatic=1
autocomplete.*.ignorecase=1
autocomplete.choose.single=0

autocomplete.*.start.characters=$(chars.alpha)$(chars.numeric)$_@#.
api.*.ms=maxscript.api;maxscript_mc.api



#Custom Color Scheme 7b1406

#~ Default font settings
font.base=font:Verdana,size:10
font.comment=font:Verdana,size:10
colour.code.comment.box=fore:#0A8282,italics
colour.code.comment.line=fore:#0A8282,italics

#~ Sets the color used for the caret (cursor).
caret.fore=#f92672
caret.line.back=#a69186
caret.line.back.alpha=50

# Background and Text for Maxscript
style.MAXScript.32=$(font.base),back:#e3d8d1,fore:#1c1c1c
# Background and Text for All languages
style.*.32=$(font.base),back:#e3d8d1,fore:#1c1c1c
# End of line where string is not closed
style.MAXScript.6=fore:#000000,$(font.monospace),back:#E0C0E0,eolfilled
# Keywords2 - Rollout controls
style.MAXScript.13=fore:#faaa3c,bold
 # String
 style.MAXScript.4=fore:#AD5E5E
 
 
#keywordclass.MAXScript=\
#and\
#animate\
#attributes\
#by\
#collect \
#else\
#exit\
#for\
#from\
#function\
#rollout\
#struct\
#set\
#then





