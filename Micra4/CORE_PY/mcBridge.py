import threading, socket, json
from mcFile import importFileFBXReplace, getFileName

def isPortOpen(host, port):
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	address = (host, port)
	is_open = False
	try:
		sent = s.sendto("msg", address)
		is_open = True
	except:
		is_open = False	
	finally:
		return is_open

# SERVER
class ServerThread(threading.Thread):
	def __init__(self, port):
		threading.Thread.__init__(self)
		self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		self.server_address = ('localhost', port)
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
				data = json.loads(data.decode('utf-8'))
				# print("CMD:", data)
				if data:
					cmd_type = data.get('type')
					print("CMD Type:", cmd_type)
					if cmd_type == 'quit': # Close Connection
					
						self.running = False
						self.sock.close() 
						print ("Connection {} Terminated.".format(address))
						break
						
					else: # Import FBX
					
						# print ("Receive CMD:", data)
						xml_file = data.get('xml')
						fbx_file = data.get('fbx') 
						print ("Import FBX\n\t{}\nBased On XML\n\t{}".format(
						
							getFileName(xml_file), 
							getFileName(fbx_file)
						))
						importFileFBXReplace(fbx_file, xml_file)
				else:
					print ("no more Data.")
			except: 
				pass
		print ("THREAD: end")

# CLIENT
def sendMessageToPort(msg_obj, port):
	# Create a TCP/IP socket
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	# sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	try:
		address = ('localhost', port)
		data = json.dumps(msg_obj)

		# Send data
		print('Sending {} bytes to {}'.format(len(data), address))
		# print('Sending to Blender CMD {!r}'.format(data))
		sent = sock.sendto(data.encode(), address)
		 
		# Receive response
		#~ print('waiting to receive')
		#~ data, server = sock.recvfrom(4096)
		#~ print('received {!r}'.format(data))
		
	finally:
		print('Closing socket to Blender')
		sock.close()
	
#~ Blender Crash and Backup Data location
# C:\Users\Orien Star\AppData\Local\Temp\quit.blend
	
# SERVER Example    
# print ("\n\n\nSCRIPT: start")
# thread = mcBridge.ServerThread(4568)
# thread.start()
# print ("SCRIPT: end, thread running:", thread.running)

#~ CLIENT Example		
#~ py_core_dir = mcFile.getPythonCoreDir()
#~ xml_file = py_core_dir + "blender\\blender_max_transfer_info.xml"
#~ fbx_file  = py_core_dir + "blender\\blender_max_transfer_scene.fbx"
#~ mcBridge.sendMessageToPort({'type':'Export', 'xml':xml_file, 'fbx':fbx_file}, 4568)
#~ mcBridge.sendMessageToPort({'type':'quit'}, 4568) 