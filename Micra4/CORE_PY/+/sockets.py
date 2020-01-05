--------------------------
echo-server.py
--------------------------

import socket

HOST = '127.0.0.1'  # Standard loopback interface address (localhost)
PORT = 65432        # Port to listen on (non-privileged ports are > 1023)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen(1)
    conn, addr = s.accept()
    with conn:
        print('Connected by', addr)
        while True:
            data = conn.recv(1024)
            if not data:
                break
            conn.sendall(data)
			
			
			

--------------------------
echo-client.py
--------------------------

import socket

HOST = '127.0.0.1'  # The server's hostname or IP address
PORT = 65432        # The port used by the server

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    s.sendall(b'Hello, world')
    data = s.recv(1024)

print('Received', repr(data))


--------------------------
multi
--------------------------

import selectors, socket
HOST = '127.0.0.1'  # The server's hostname or IP address
PORT = 65432        # The port used by the server
sel = selectors.DefaultSelector()
lsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
lsock.bind((HOST, PORT))
lsock.listen()
print('listening on', (HOST, PORT))
lsock.setblocking(False)
sel.register(lsock, selectors.EVENT_READ, data=None)





--------------------------
echo-server.py
--------------------------


import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print('Connected by', 1)
s.bind(('localhost', 4567))
print('Connected by', 2)
s.listen(1)
print('Connected by', 3)
conn, addr = s.accept() # here is freezes Blender before con.close()
print('Connected by', addr)
while 1:
    data = conn.recv(1024)
    if not data:
        break
    conn.sendall(data)
conn.close()
print('Connection closed')


--------------------------
echo-client.py
--------------------------

import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('localhost', 50000))
s.sendall('Hello, world')
data = s.recv(1024)
s.close()
print 'Received', repr(data)




-------------------------------


import socket

# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to the port
server_address = ('localhost', 10000)
print('Starting up on {} port {}'.format(*server_address))
sock.bind(server_address)

# Listen for incoming connections
sock.listen(1)

while True:
    # Wait for a connection
    print('waiting for a connection')
    connection, client_address = sock.accept()
    try:
        print('connection from', client_address)

        # Receive the data in small chunks and retransmit it
        while True:
            data = connection.recv(16)
            print('received {!r}'.format(data))
            if data:
                print('sending data back to the client')
                connection.sendall(data)
            else:
                print('no data from', client_address)
                break
    finally:
        # Clean up the connection
        print("Closing current connection")
        connection.close()
		
		
-------------------------------		

import socket




while True:
    print('\nwaiting to receive message')
    data, address = sock.recvfrom(4096)

    print('received {} bytes from {}'.format(
        len(data), address))
    print(data)

    if data:
		close_connection = data.find('quit') != -1
        print ('ready to exit:{}'.format(close_connection))
        if close_connection:
			sent = sock.sendto(data, address)
            break
        else:
            sent = sock.sendto(data, address)
            print('sent {} bytes back to {}'.format(
                sent, address))
					
-------------------------------

import threading, time, socket
from mcBlender import importFileFBXReplace, getFileName

class BlenderThread(threading.Thread):
    def __init__(self, xml_file, fbx_file):
        threading.Thread.__init__(self)
        self.xml_file = xml_file
        self.fbx_file = fbx_file
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.server_address = ('localhost', 4568)
        print('starting up on {} port {}'.format(*self.server_address))
        self.sock.bind(self.server_address)
        self.running = True

    def run(self):
        while self.running:
            print('\nwaiting to receive message')
            
            # return value is a pair (string(bytes), address(array))
            data, address = self.sock.recvfrom(4096) # bufsize 4096
            
            try:
                print('received {} bytes from {}'.format(len(data), address))
                data = data.decode('utf-8') # convert bytes in to string
                print("CMD:", data)
                if data:
                    if data.find('quit') != -1: # Close Connection
                        self.running = False
                        self.sock.close() 
                        print ("Connection {} Terminated.".format(address))
                        break
                    else: #import FBX
                        print ("Import FBX\n\t{}\nBasef On XML\n\t{}".format(
                            getFileName(self.xml_file), 
                            getFileName(self.fbx_file)
                        ))
                        # importFileFBXReplace(self.fbx_file, self.xml_file)
                        # break
                else:
                    print ("no more Data.")
            except: 
                pass
        print ("THREAD: end")
        
thread = BlenderThread("xml_file", "fbx_file")
thread.start()
print ("SCRIPT: end, thread running:", thread.running)

# Example
# print ("\n\n\nSCRIPT: start")
# from mcLoader import Micra_Blender_Dir
# xml_file = Micra_Blender_Dir + '\\blender_max_transfer_info.xml'
# fbx_file = Micra_Blender_Dir + '\\blender_max_transfer_scene.fbx'
# thread = BlenderThread(xml_file, fbx_file)
# thread.start()
# print ("SCRIPT: end, thread running:", thread.running)
				
				
				
				
-------------------------------				
import threading, time, socket, pickle
from mcBlender import importFileFBXReplace, getFileName

class BlenderThread(threading.Thread):
    def __init__(self, xml_file, fbx_file):
        threading.Thread.__init__(self)
        self.xml_file = xml_file
        self.fbx_file = fbx_file
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.server_address = ('localhost', 4568)
        print('starting up on {} port {}'.format(*self.server_address))
        self.sock.bind(self.server_address)
        self.running = True

    def run(self):
        while self.running:
            print('\nwaiting to receive message')
            
            # return value is a pair (string(bytes), address(array))
            data, address = self.sock.recvfrom(4096) # bufsize 4096
            
            try:
                print('received {} bytes from {}'.format(len(data), address))
                print("DATA BTYES:", data)
                if data:
                    data_obj = pickle.loads(data) # convert to object
                    print("DATA OBJECT:", data_obj)
                    print("DATA OBJECT Type:", data_obj.type) #not passs !!!!!!!!!!
                    cmd_type = data_obj.type.decode('utf-8') # convert bytes in to string
                    print("CMD Decoded Type:", cmd_type)
                    print("CMD Decoded All:", data)
                    if cmd_type == 'quit': # Close Connection
                        self.running = False
                        self.sock.close() 
                        print ("Connection {} Terminated.".format(address))
                        break
                    else: #import FBX
                        print ("Import FBX\n\t{}\nBased On XML\n\t{}".format(
                        
                            data_obj[1],
                            data_obj[2]
#                            getFileName(self.xml_file), 
#                            getFileName(self.fbx_file)
                        ))
                        # importFileFBXReplace(self.fbx_file, self.xml_file)
                else:
                    print ("no more Data.")
            except: 
                pass
        print ("THREAD: end")
        
thread = BlenderThread("xml_file", "fbx_file")
thread.start()
#print ("SCRIPT: end, thread running:", thread.running)