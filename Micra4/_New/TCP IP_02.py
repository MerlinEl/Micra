import win32gui, win32con

hwnd = win32gui.GetForegroundWindow()
win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)



import socket
PORT = 8081
HOST = "localhost"
#~ Establishing a port connection
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((HOST, PORT))
#~ Send command with file that will be executed from Blender
sock.send('D:\\ReneBaca\\Blender\\v2.81a-win64\\bridge\\import_test_01.py')
sock.send("quit")


print ( "TCP-IP message was Sended.")
#~ data, addr = sock.recvfrom(1024)
#~ print ( "message From: " + str(addr))
#~ print ( "from connected user: " + data.decode())

