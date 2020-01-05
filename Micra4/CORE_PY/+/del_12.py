import mcFile, socket, json

#~ Send Blende event by port
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
try:
	server_address = ('localhost', 4568)
	py_core_dir = mcFile.getPythonCoreDir()
	xml_file = py_core_dir + "blender\\blender_max_transfer_info.xml"
	fbx_file  = py_core_dir + "blender\\blender_max_transfer_scene.fbx"
	data = json.dumps({'type':'Export', 'xml':xml_file, 'fbx':fbx_file})
	#~ data = json.dumps({'type':'quit'}) 
	  
	  
	# Send data
	print('Sending to Blender CMD {!r}'.format(data))
	sent = sock.sendto(data.encode(), server_address)
	 
	# Receive response
	#~ print('waiting to receive')
	#~ data, server = sock.recvfrom(4096)
	#~ print('received {!r}'.format(data))
	
finally:
	print('Closing socket to Blender')
	sock.close()