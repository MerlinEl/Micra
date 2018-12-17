	listener_handles=(windows.getchildhwnd 0 "MaxScript Listener")  --get editor dialog handles
	uiaccessor.openDialog listener_handles[1]
	
	
	MAXScript Listener
	
	clearListener() --will clear lower part of listener
	edit <filename_string>
	
	edit "my_script.ms"

	actionMan.executeAction 0 "40408" --add maxscript listener as extended viewport
	actionMan.executeAction 0 "40839" --open maxscript editor
	actionMan.executeAction 0 "40472" -- Open the Listener
--------------------------------------------------------------------------
--Accessing Maxscript Listener
--------------------------------------------------------------------------
listener_handles=(windows.getchildhwnd 0 "MaxScript Listener")  --get editor dialog handles
1:HWND 
2:parent's HWND 
3:ancestor's HWND 
4:class name as a string 
5:window text as a string  
listener_handle = listener_handles[1]
  
listener_childerns = windows.getChildrenHWND listener_handle --get 2 Arrays from Maxscript Listener handle 
print listener_childerns
  
Array_1:  lower window
1:close window lower part from listener
2:"MAXScript Listener"
3:"MAXScript Listener"
4:"MXS_Scintilla"
5:All text from lower window -- listener_childerns[1][5]  
6:undefined
7:"MAXScript Listener"
8:"MAXScript Listener"

Array_2: upper window
1:close window upper part from listener
2:"MAXScript Listener"
3:"MAXScript Listener"
4:"MXS_Scintilla"
5:All text from upper window -- listener_childerns[2][5]  
6:undefined
7:"MAXScript Listener"
8:"MAXScript Listener"
  
UIAccessor.GetWindowText listener_childerns[2][8] 
uiaccessor.IsWindow  listener_childerns[2][8] 
uiaccessor.closedialog listener_childerns[1][8]



 
fn MCR_SendKeys sysKey = 
(
	local WM_ACTIVATE = 0x6
	local SendKeys = dotNetClass "System.Windows.Forms.SendKeys"
	ListenerHWND = (windows.getChildHWND 0 "MAXScript Listener")[1]
	MacroChHWND = (windows.getChildrenHWND ListenerHWND)[2][1]
 
	Windows.sendMessage MacroChHWND WM_ACTIVATE MacroChHWND 0
	SendKeys.SendWait sysKey
)
 
MCR_SendKeys "{E}" -- send Escape key to MacroRecorder sub-window


Fn BackgroundTcpListenerDoWork theSender theEvent = 
 (
 	IPAddress = DotNetClass "System.Net.IPAddress"
 	theIPAddress = IPAddress.Parse "127.0.0.1"
 	theTcpListener = DotNetObject "System.Net.Sockets.TcpListener" theIPAddress 7500
 	theTcpListener.Start()
 	
 	theString="";
 	
 	print "listening"
 	
 	theSocket = theTcpListener.AcceptSocket()
    
 	
 	while  theString!="exit" do
 	(
 		theByteStream = DotNetObject "System.Byte[]" 10000
 		theSocket.Receive theByteStream
 		Encoding = DotnetClass  "System.Text.Encoding"
 		theString = trimright (Encoding.UTF8.GetString(theByteStream))
 
 		if theString!="" do (
 			
 			print theString
 
 			ascii_encoder = dotNetObject "System.Text.ASCIIEncoding"  
 			bytes = ascii_encoder.GetBytes ( "Hi, I've recieved: "+theString+" \n" as string )  
 			result = theSocket.Send bytes  
 					
 		)
 		 
 	)
 	
 	print "stopped"
 	
 	theTcpListener.Stop()
 	theSocket.Close()
 )
 
 BackgroundWorker = DotNetObject "System.ComponentModel.BackgroundWorker"
 DotNet.AddEventHandler BackgroundWorker "DoWork" BackgroundTcpListenerDoWork 
 BackgroundWorker.WorkerSupportsCancellation = true
 BackgroundWorker.RunWorkerAsync()
 
 
 
 
 
 
 
 
 actionMan.executeAction 0 "40472" -- Open the Listener
global SendKeys = dotNetClass "System.Windows.Forms.SendKeys"
fn MCR_SendKeys sysKey = 
 (
  local WM_ACTIVATE = 0x6
  ListenerHWND = (windows.getChildHWND 0 "MAXScript Listener")[1]
  MacroChHWND = (windows.getChildrenHWND ListenerHWND)[1][1]
  Windows.sendMessage MacroChHWND WM_ACTIVATE MacroChHWND 0
  SendKeys.SendWait sysKey
 )
 
fn checkedbtn o a =
 (
  if o.checked == true then
   (
    o.backcolor = o.backcolor.gold
    obj = pickobject filter:shapeFilt forceListenerFocus:false
    if obj != #escape and obj != undefined then
     (
      o.text = obj.name
      o.checked = false
     )
   )
  else
   (
    MCR_SendKeys "{Escape}" -- send Escape key to the Listener sub-window
    o.backcolor = o.backcolor.azure
   )
 )
dotnet.addEventHandler checkBox0 "checkedChanged" checkedbtn
	
 
 
 
 
 
 actionMan.executeAction 0 "40472" -- Open the Listener
 
fn MCR_SendKeys sysKey = 
(
	local WM_ACTIVATE = 0x6
	local SendKeys = dotNetClass "System.Windows.Forms.SendKeys"
	ListenerHWND = (windows.getChildHWND 0 "MAXScript Listener")[1]
	MacroChHWND = (windows.getChildrenHWND ListenerHWND)[2][1]
 
	Windows.sendMessage MacroChHWND WM_ACTIVATE MacroChHWND 0
	SendKeys.SendWait sysKey
)
 
MCR_SendKeys "{ESC}" -- send Escape key to MacroRecorder sub-window