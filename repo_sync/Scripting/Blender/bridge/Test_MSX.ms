HiddenDOSCommand cmd prompt:'Waiting for Blender response' --donotwait:true
HiddenDOSCommand cmd donotwait:true
sys.exit(1)import sys
https://docs.blender.org/manual/en/latest/advanced/command_line/arguments.html
https://blenderartists.org/t/import-obj-file-automatically-when-starting-blender/525992/6
https://janakiev.com/blog/blender-command-line/


blender_app			=@"D:\ReneBaca\Blender\v2.81a-win64\blender.exe"
blender_bridge_path	=@"D:\ReneBaca\Blender\v2.81a-win64\bridge"
blender_scene		=blender_bridge_path +@"\Test_Scene.blend"
blender_script		=blender_bridge_path +@"\Test_Script.py"
obj_file			=blender_bridge_path +@"\Test_Object.fbx"


if doesFilesExist #(blender_app, blender_bridge_path, blender_scene, blender_script, obj_file) do (




)
cmd = blender_app -- open Blender
cmd = blender_app + " " + blender_scene --open Blender with scene
cmd = blender_app + " " + blender_scene + " -P -con" + blender_script + " -- " + obj_file --open Blender with scene and run Python script to import object
cmd = blender_app + " " + blender_scene + " -P -con --python" + blender_script + " -- " + obj_file
HiddenDOSCommand cmd
HiddenDOSCommand cmd donotwait:true




cmd = blender_app + " " + blender_scene + " --background --python " + blender_script + " -- " + obj_file






import bpy
file_loc = "D:\\!2k_games\\scotch_dev\\exported\\a.fbx"
imported_object = bpy.ops.import_scene.fbx(filepath=file_loc)
print('Importing File: ', imported_object)

------------------------------------------------------------------------------------------------------

https://www.blender.org/forum/viewtopic.php?t=14046
TCP knihovna


https://github.com/nmalex/remote-maxscript.dlx
#include "stdafx.h"
#include "maxscript.server.h"

using namespace maxscript_server;

void HandleRequest(SOCKET clientSocket, const char* data) {
    printf("Received: %s\n", data);
    // TODO: handle data

    MAXScriptServer::Send(clientSocket, "OK"); // send back result "OK"
}

int main(int argc, char **argv)
{
    MAXScriptServer server((MAXScriptOutputCallback)&HandleRequest);
    server.Listen(29207);
    return 0;
}

------------------------------------------------------------------------------------------------------
IPAddress = DotNetClass "System.Net.IPAddress"
theIPAddress = IPAddress.Parse "127.0.0.1"
theTcpListener = DotNetObject "System.Net.Sockets.TcpListener" theIPAddress 5688
theTcpListener.Start()
theString=""
print "Socket Open!"
theSocket = theTcpListener.AcceptSocket()

Fn BackgroundTcpListenerDoWork= 
(
	while theString!="exit" do
	(
		theByteStream = DotNetObject "System.Byte[]" 10000
		theSocket.Receive theByteStream
		Encoding = DotnetClass "System.Text.Encoding"
		theString = trimright (Encoding.UTF8.GetString(theByteStream))
		if theString!="" do try(execute theString;)catch(print "Error Occured!")
	)
	
	theTcpListener.Stop()
theSocket.Close()
)

myTimer =DotNetObject "System.Timers.Timer"
myTimer.Interval = 5000
dotnet.addEventHandler myTimer "Elapsed" BackgroundTcpListenerDoWork
myTimer.Start()

rollout myRollout "My Dialog" width:162 height:147
(
	button btn1 "My Button" pos:[24,14] width:117 height:53
	checkbox chk2 "My Checkbox" pos:[17,89] width:133 height:19
)
createDialog myRollout
myTimer.Stop()


------------------------------------------------------------------------------------------------------
global theString=""

tt = dotnetobject "System.Windows.Forms.Timer"
tt.Interval = 1000

Fn BackgroundTcpListenerDoWork s e = 
(
IPAddress = DotNetClass "System.Net.IPAddress"
theIPAddress = IPAddress.Parse "127.0.0.1"
theTcpListener = DotNetObject "System.Net.Sockets.TcpListener" theIPAddress 7500
theTcpListener.Start()

theSocket = theTcpListener.AcceptSocket()
while theString!="exit" do
(
theByteStream = DotNetObject "System.Byte[]" 10000
theSocket.Receive theByteStream
Encoding = DotnetClass "System.Text.Encoding"
theString = trimright (Encoding.UTF8.GetString(theByteStream))
if theString!="" do (try(execute theString;theString="" )catch(print "Error Occured!") )
)
theTcpListener.Stop()
theSocket.Close()
s.stop()
)

dotnet.addEventHandler tt "Tick" BackgroundTcpListenerDoWork
tt.Start()

fn DoWork =
(
	tt.Start()
)

BackgroundWorker = dotnetobject "CSharpUtilities.SynchronizingBackgroundWorker"
BackgroundWorker.WorkerSupportsCancellation = on	
dotNet.addEventHandler BackgroundWorker "DoWork" DoWork

if not BackgroundWorker.isBusy do BackgroundWorker.RunWorkerAsync()
BackgroundWorker.Dispose()



global data
tt = timer
bw = backgroungworker
fn onDoWork =
(
data = (read socket) to string
start timer 
)
fn onTick =
(
execute data
stop timer
)

------------------------------------------------------------------------------------------------------

global theString=""
Fn BackgroundTcpListenerDoWork theSender theEvent = (
	
	IPAddress = DotNetClass "System.Net.IPAddress"
	theIPAddress = IPAddress.Parse "127.0.0.1"
	theTcpListener = DotNetObject "System.Net.Sockets.TcpListener" theIPAddress 5688
	theTcpListener.Start()

	theSocket = theTcpListener.AcceptSocket()
	while theString!="exit" do (
		
		theByteStream = DotNetObject "System.Byte[]" 10000
		theSocket.Receive theByteStream
		Encoding = DotnetClass "System.Text.Encoding"
		theString = trimright (Encoding.UTF8.GetString(theByteStream))
	)
	theTcpListener.Stop()
	theSocket.Close()
	tt.stop()
)
BackgroundWorker = DotNetObject "System.ComponentModel.BackgroundWorker"
DotNet.AddEventHandler BackgroundWorker "DoWork" BackgroundTcpListenerDoWork 
BackgroundWorker.WorkerSupportsCancellation = true
BackgroundWorker.RunWorkerAsync()

tt = dotnetobject "System.Windows.Forms.Timer"
tt.Interval = 1000
fn makeRollout s e = (
	
	if theString!="" do (try(execute theString;theString="" )catch(print "Error Occured!") )
 )
dotnet.addEventHandler tt "Tick" makeRollout
tt.Start()

------------------------------------------------------------------------------------------------------

tt = dotnetobject "System.Windows.Forms.Timer"
tt.Interval = 1000

fn makeRollout s e = 
(
	rollout rol "From Timer" width:200
	(
		button bt "Button" pos:[4,4] width:190 
	)
	createDialog rol
	s.Stop()
)
dotnet.addEventHandler tt "Tick" makeRollout
tt.Start()

fn DoWork =
(
	tt.Start()
)

BackgroundWorker = dotnetobject "CSharpUtilities.SynchronizingBackgroundWorker"
BackgroundWorker.WorkerSupportsCancellation = on	
dotNet.addEventHandler BackgroundWorker "DoWork" DoWork

if not BackgroundWorker.isBusy do BackgroundWorker.RunWorkerAsync()
BackgroundWorker.Dispose()

------------------------------------------------------------------------------------------------------


# UDP server example!!
import socket, time, struct, sys
server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#We allow the call to recvfrom to timeout after 1 second...
server_socket.settimeout(1)
server_socket.bind(("", 7771))

finished = False

while False == finished:
    try:
        data, address = server_socket.recvfrom(256)
        print "data ", data

        #This does not work very well, so you might want to comment it out.
        if True == Blender.Window.TestBreak():
            finished = True
            print "User pressed Escape"
    except socket.error, msg:
       print "socket timeout %s " % (msg)

print "Finished"



# SPACEHANDLER.VIEW3D.DRAW
import Blender
selDict = Blender.Registry.GetKey('SelChange', False)
if selDict:
  if selDict['selChange']:
    print Blender.Object.GetSelected()[0].getName()
	
	
	
	
	
	
	
while 1:
    print ('waiting for a connection')
    conn, addr = s.accept()
    try:
        print ('Client coinnected:', addr)
        def main():
            while True:
                data = conn.recv(BUFFER_SIZE)
                if data:                
                    doMyBusiness(data)
                else :
                    break
    finally:
        print('client disconnected:',addr)
        conn.close()
        break
		
		
		
def doMyBusiness(data):
	print ("received data:", data)
	if (data == b'1'):
	    x = x+10
	    arm.channels['Upperarm.Right'].rotation_euler=[-r(x),r(26.639),r(0.576)]
	    arm.update() 
	elif (data == b'2'):
	    x= x-10   
	    arm.channels['Upperarm.Right'].rotation_euler=[-r(x),r(26.639),r(0.576)]
	    arm.update()                   
	else :
	    continue   
		
		
	def doMyBusiness(data):
	print ("received data:", data)	
		
		
		
		------------------------------------------------------------------------------------------------------
		
		
		
		