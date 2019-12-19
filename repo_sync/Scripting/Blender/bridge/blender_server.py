# Script to run from blender:
# blender --python blender_server.py

PORT = 8081
HOST = "localhost"
PATH_MAX = 4096


def execfile(filepath):
    import os
    global_namespace = {
        "__file__": filepath,
        "__name__": "__main__",
    }
    with open(filepath, 'rb') as file:
        exec(compile(file.read(), filepath, 'exec'), global_namespace)


def main():
    import socket

    serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serversocket.bind((HOST, PORT))
    serversocket.listen(1)

    print("Listening on %s:%s" % (HOST, PORT))
    while True:
        connection, address = serversocket.accept()
        buf = connection.recv(PATH_MAX)

        for filepath in buf.split(b'\x00'):
            if filepath:
                print("Executing:", filepath)
                try:
                    execfile(filepath)
                except:
                    import traceback
                    traceback.print_exc()


if __name__ == "__main__":
    main()