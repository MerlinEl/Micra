import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('localhost', 10000))

s.sendall('quit')

#~ s.sendall('Hello, world')
#~ data = s.recv(1024)
#~ s.close()
#~ print 'Received', repr(data)