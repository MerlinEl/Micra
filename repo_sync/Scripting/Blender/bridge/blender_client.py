#!/usr/bin/env python
# Script to send paths to run in blender:
#   blender_client.py script1.py script2.py

PORT = 8081
HOST = "localhost"

def main():
    import sys
    import socket

    clientsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    clientsocket.connect((HOST, PORT))

    for arg in sys.argv[1:]:
        clientsocket.sendall(arg.encode("utf-8") + b'\x00')


if __name__ == "__main__":
    main()
	
	
	
	"""
	msdos > 
		list all used ports > netstat -tan
		ping 127.0.0.1
		send message to port > net send 172.0.0.1 "hello" --net send ComputerNameHere "some messages overhere"
		https://www.itnetwork.cz/csharp/pokrocile/csharp-tutorial-tcp-pripojeni-komunikace
	
	msx > send - get commands trough port socket
		127.0.0.1:8081
		
		IPAddress = DotNetClass "System.Net.IPAddress"
		theIPAddress = IPAddress.Parse "127.0.0.1"
		theTcpListener = DotNetObject "System.Net.Sockets.TcpListener" theIPAddress 8081
		theTcpListener.Start()
		theString=""
		print "Socket Open!"
		theSocket = theTcpListener.AcceptSocket()
		theTcpListener.stop()
		
		
		
		
		PORT = 8081
		HOST = "localhost"

		def main():
			import sys
			import socket

			clientsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			print ("cl cocket", clientsocket)
			clientsocket.connect((HOST, PORT))
			clientsocket.sendall("EXIT")

		if __name__ == "__main__":
			main()
	"""