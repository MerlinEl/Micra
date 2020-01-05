import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_address = ('localhost', 4568)

#~ message = b'Import fbx_file based on info xml_file'
message = b'quit'

try:

    # Send data
    print('sending {!r}'.format(message))
    sent = sock.sendto(message, server_address)

    # Receive response
    #~ print('waiting to receive')
    #~ data, server = sock.recvfrom(4096)
    #~ print('received {!r}'.format(data))

finally:
    print('closing socket')
    sock.close()