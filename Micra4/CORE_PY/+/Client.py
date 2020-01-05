import socket


def sendMessage(msg, socket):
    socket.send(msg)
    return s.recv(responseBufferSize)

## connect to the server
responseBufferSize = 1024
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('127.0.0.1', 5688))

## send messages
sendMessage(b'saveMaxFile \"C:/test.max\"', s)

## close the socket from server and client side
#sendMessage('socketClosing', s)
#s.shutdown(socket.SHUT_RDWR)
#s.close()