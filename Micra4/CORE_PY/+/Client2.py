import socket, json
# solution will be to set socket as global withou closing hm ???? maybe


## connect to the server
#s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
adress = ('127.0.0.1', 5688)
s.connect(adress)

## send messages
data = json.dumps('import XML')
sent = s.send(data.encode())
s.shutdown(socket.SHUT_RDWR)
s.close()

