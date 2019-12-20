import socket

PORT = 8081
HOST = "localhost"	

def sendCommandToPort(cmd):
	#~ Establishing a port connection
	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.connect((HOST, PORT))
	#~ Send command that will be executed from Blender
	sock.send(cmd)
	# sock.send('D:\\ReneBaca\\Blender\\v2.81a-win64\\bridge\\import_test_01.py')
	# sock.send("quit")