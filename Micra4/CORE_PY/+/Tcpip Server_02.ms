fn executeMsg msg = (
	
	format "Got message:%\n" msg
-- 					try(
-- 						----
-- 					) catch (
-- 						format "Error:%\n" + getCurrentException() 
-- 					)
)

fn isSocketConnected s = ( --not tested

    local part1 = s.Poll 1000  s.SelectMode.SelectRead
    local part2 = s.Available == 0
    if part1 and part2 then false else true
)

fn createServer ip_address port =  (
	
	local ip = (DotNetClass "System.Net.IPAddress").Parse ip_address
	local tcpListener = DotNetObject "System.Net.Sockets.TcpListener" ip port
	tcpListener.Start()
	local msg = "", is_enabled = true
	print ("listening on " + (ip as string) + ":" + (port as string))
	while is_enabled do (
		print("waiting for a client socket")
		local socket = tcpListener.AcceptSocket()
		print("client socket accepted")
		while msg != "exit" do (
		
			try (
				
				local bytes = DotNetObject "System.Byte[]" 10000
				socket.Receive bytes
				local encoding = DotnetClass "System.Text.UTF8Encoding"
				msg = trimright (encoding.UTF8.GetString(bytes))
				if msg == "quit" then (
		
					is_enabled = false
					print("closing socket"); socket.Close(); exit
					
				) else if msg != "" do executeMsg(msg)
			) catch (
				
				format "Parse Error:%\n" + getCurrentException() 
			)
		)
	)
)

fn BackgroundTcpListenerDoWork theSender theEvent = (
	try (
		createServer "127.0.0.1" 5688
		exit
	)
	catch(
		print("server crashed or port 5688 is already used")
	)
)

BackgroundWorker = DotNetObject "System.ComponentModel.BackgroundWorker"
DotNet.AddEventHandler BackgroundWorker "DoWork" BackgroundTcpListenerDoWork
BackgroundWorker.WorkerSupportsCancellation = true
BackgroundWorker.RunWorkerAsync()



/*
telnet client can be installed from Windows Control Panel->Programs&Features->Turn Windows Features or of off->Telnet client
telnet 127.0.0.1 5688 :Text to send
dosCommand "taskkill /F /PID 5688"
*/

/*
import socket, json

## connect to the server
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
adress = ('127.0.0.1', 5688)
s.connect(adress)

## send messages
data = json.dumps('import XML')
sent = s.send(data.encode())
s.shutdown(socket.SHUT_RDWR)
s.close()
*/


/*
import socket


def sendMessage(msg, socket):
	socket.send(msg)
	return s.recv(responseBufferSize)

## connect to the server
responseBufferSize = 1024
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('127.0.0.1', 7500))

## send messages
sendMessage('saveMaxFile \"C:/test.max\"', s)

## close the socket from server and client side
sendMessage('socketClosing', s)
s.shutdown(socket.SHUT_RDWR)
s.close()
*/
