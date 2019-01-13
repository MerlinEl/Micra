-------------------------------------------------------------------------------------------------------------------------------------------
---- MXSEditor Global Utility Plugin V1.0
-------------------------------------------------------------------------------------------------------------------------------------------
---- Author:    Josef Wienerroither
---- Created:   August 2011
---- Modified:  September 30th, 2018
-------------------------------------------------------------------------------------------------------------------------------------------


HISTORY:
---- Version:  V1.0, RELEASE DC20180930, 
----	Added Max 2018 and Max 2019 versions
----
---- Version:  V1.0, RELEASE DC20170720, 
----	First public final release version
----	Added documentation
---- 
---- Version:  V1.0, DC20160606, 
----	Updated to Unicode, Compatible with Max 2008 - Max2017, x86 and x64
----	Implemented, fixed callback functionality
----	Lots of other fixes and updates
----
---- Version:  V0.50 - Beta 1, DC20120214, 
----    First public release
----
---- Author:   
----    Josef Wienerroither aka "spacefrog"  www.frogsinspace.at  | spacefrog@chello.at
-------------------------------------------------------------------------------------------------------------------------------------------

INSTALL:
----    Copy the appropiate file according to your 3ds Max version into your plugins folder
----    restart 3ds Max. The plugin should now be operational
----    You simply can check this by typein "showinterface MXSEditor" in the listener
----    If you get the public properties and functions listed, the plugin was loaded successfully
-------------------------------------------------------------------------------------------------------------------------------------------

FEATURES:
----	Usage of Maxscript Editor as Extended Viewport
----    Control the Maxscript Editor via maxscript
----    one direct benefit when the plugin is installed, is that it registers the Maxscript Editor as Extended Viewport
-------------------------------------------------------------------------------------------------------------------------------------------

USAGE ( PLEASE REFER TO THE PDF FOR DETAILED USAGE ! )
----	If you just want to use the maxscript editor in an extended viewport, you can do so right after installation
----	There are some limitations to that though, which are also true for the 3ds Max built in Listener in an extended viewport though
----    eg. if you close the Maxscript editor while it's in the extended viewport via the 3ds Max "Maxscript" menu, or via keyboard shortcut,
----	you well end up with a blank viewport that seems to be dead. Actually the Maxscript editor just gets hidden in this case, so you simply can reopen it 
----	and everything will keep working. So it's better to end the extended viewport by switching the viewport to a standard view like "Top" etc.., using the 
----	right mousebutton menu while hovering the mouse cursor over the maxscript editors menu area. This is essentially standard behavior for extended viewports in Max.
----	
----	Right after installation you will get several addional Maxscript interfaces and structs at your disposal
----    Most of the functionality is documented in the accompanying PDF or on the plugin's website. As the topic of the plugin is for advanced usage anyways,
----    you will have to figure it out yourself. Should be fun enough and done in no time via experimenting ;-)
----
----    Those are the basic maxscript calls/ interfaces for you to use:
----    
----    MXSEditor :  
----		main interface to control the maxscript editor, type "showinterface mxseditor" to learn about functions and properties it provides

		  Interface: MXSEditor
		   Properties:
			.x : integer : Read|Write
			.y : integer : Read|Write
			.width : integer : Read|Write
			.height : integer : Read|Write
			.enableCallbacks : boolean : Read|Write
			.isVisible : boolean : Read|Write
			.verbose : boolean : Read|Write
			.isExtendedVP : boolean : Read
			.mainHWND : HWND : Read
			.editHWND : HWND : Read
			.documentCount : integer : Read
			.currentDocument : string : Read
		   Methods:
			<void>redraw()
			<void>show()
			<boolean>endExtendedVP()
			<void>reloadOptions()
			<boolean>editFile <string>filename quiet:<boolean>
			   quiet default value: false
			<string>documentAtNumber <integer>index
			<void>menuCommand <string>menucode
			<boolean>setWindowPosition <integer>x <integer>y <integer>width <integer>height
			<string>getConfigProperty <string>name
			<integer>getConfigIntProperty <string>name
			<void>setConfigProperty <string>name <string>value
			<integer>listFunctions()
			<integer>listConstants()
			<integer>listProperties()
			<integer>listMenucodes()

----    
----     MXSEFuncs :
----        interface to MXS Editor's Scintilla edit component functionionality. Functions are called using the internal Scintilla messaging system, 
----        see some more docs here http://www.scintilla.org/ScintillaDoc.html and find the most complete info by studying the scintilla source code ;-)
----
----        mxsefuncs.list() ... list all scintilla internal functions, including parameter types and return type (function signature)
----
----        mxsefuncs.call() ... call a scintilla internal function, function name is passed as string value ( without braces ) followed by parameters
----                            function parameters/return values are past as their respective maxscript equivalents
----                                
----                            eg.: set the background color of selected text, mxsefuncs.list() returns the following function signature: 
----                                    
----                                    void SetSelBack(bool, color)
----                                    
----                            thus to set the background color for selected text to some random color we enter the following in the listener:
----                                    
----                                mxsefuncs.call "SetSelBack" true new (color 100 200 30 128)
----                                    
----                            see http://www.scintilla.org/ScintillaDoc.html#SCI_SETSELBACK what the boolean parameter does...
----                                    
----                            you can pass maxscript variables by reference on functions that require data to be returned ( eg. the selected text)
----                            so if you do this:
----                                    
----                                mxsefuncs.call "GetSelText" &myText
----                                        
----                            the Maxscript variable myText will recieve the currently selected text ( selected text in  the Maxscript editor )
----                                
----                            Best way to find out how those functions work, is by experiment and study of the docs at 
----                            http://www.scintilla.org/ScintillaDoc.html
----
----
----
----     MXSEProps :        
----        struct to get, set and list all current scintilla config properties, essentially the internal settings of the editor component
----        see Scintilla documentation ->http://www.scintilla.org/ScintillaDoc.html
----                
----        mxseprops.list() ... list all the available properties and their signature ( mxseprops.dump() is exactly the same )
----                             ... Note:  those are not properties defined in the external scintilla "options" files 
----            
----        mxseprops.get()
----        mxseprops.set()  ... Set or get a specific property, see mxsefuncs.call() for examples how parameters and property names are passed
----
----
----
----    MXSECallback : 
----        struct to allow you to hook maxscript functions onto specific editor events ( eg. an entered character etc.. )
----        This is the part where i hit a roadblock, because i was not able to figure out how to keep passed maxscript function values valid
----        inside my code after they possibly got garbage collected in maxscript ( i know i have to protect them inside my code etc.. 
----        but that never worked out  as expected. After some time trying i simply lost focus on the project and stopped further efforts.....
----
-------------------------------------------------------------------------------------------------------------------------------------------
