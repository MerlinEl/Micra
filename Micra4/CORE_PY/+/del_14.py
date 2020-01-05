from mcBridge import isPortOpen
from mcLoader import HOST, PORT


print ( "Port {} is open? {} ".format(PORT, isPortOpen(HOST, PORT)) )

import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
address = (HOST, PORT)
s.shutdown(socket.SHUT_RDWR)
s.close()