from mcBridge import isPortOpen
from mcLoader import HOST, MAX_PORT, BLENDER_PORT


print ( "Max Port {} is open? {} ".format(MAX_PORT, isPortOpen(HOST, MAX_PORT)) )
print ( "Blender Port {} is open? {} ".format(BLENDER_PORT, isPortOpen(HOST, BLENDER_PORT)) )


# start Max Server at Thread
print ('Init Bridge at:', 5688)
from mcBridge import ServerThread
thread = ServerThread(5688)
thread.run()

#~ import socket
#~ s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#~ address = (HOST, PORT)
#~ s.shutdown(socket.SHUT_RDWR)
#~ s.close()