# Script to run from blender:
# blender --python blender_server.py

PORT = 8081
HOST = "localhost"
PATH_MAX = 4096


def execFile(filepath):
    import os
    global_namespace = {
        "__file__": filepath,
        "__name__": "__main__",
    }
    with open(filepath, 'rb') as file:
        exec(compile(file.read(), filepath, 'exec'), global_namespace)


def main():
    import socket

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((HOST, PORT))
    request = None
    server.listen(1)
    # server.settimeout(0) # this ensures non-blocking
    print("Listening on %s:%s" % (HOST, PORT))
    while True:
        connection, address = server.accept()
        request = connection.recv(PATH_MAX).decode('utf8')
        if request == 'quit':
			print("Executing request:", request)
			False
			break
        elif request :
		    print("Executing request:", request)
            try:
                execFile(request)
            except:
                import traceback
                traceback.print_exc()
                server.close()
            
    server.close()
if __name__ == "__main__":
    main()
	
	
	"""
	
	server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.connect(('localhost', 15555))
request = None

try:
    while request != 'quit':
        request = input('>> ')
        if request:
            server.send(request.encode('utf8'))
            response = server.recv(255).decode('utf8')
            print(response)
except KeyboardInterrupt:
    server.close()
	
	
	
	connection.close()
	
	
	you need to make it asynchronous
	help(__import__("asyncio"))
	"""