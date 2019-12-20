# Imports
import socket 
import packet
import sys
import os
from time import sleep
import multiprocessing as mp
import pickle
import io

# Constants
DEGREE_OF_PARALLELISM = 4
DEFAULT_HOST = ""
DEFAULT_PORT = 0

def _parse_cmd_line_args():
    arguments = sys.argv
    if len(arguments) == 1:
        return DEFAULT_HOST, DEFAULT_PORT
    else:
        raise NotImplemented()

def debug(data):
    pid = os.getpid()
    with open('C:\\Users\\Trauer\\Desktop\\debug\\'+str(pid)+'.txt', mode='a',
              encoding='utf8') as file:
        file.write(str(data) + '\n')

def handle_connection(client):
    client_data = client.recv(packet.MAX_PACKET_SIZE_BYTES)
    debug('received data from client: ' + str(len(client_data)))
    response = client_data.upper()
    client.send(response)    
    debug('sent data from client: ' + str(response))

def listen(picklez):    
    debug('started listen function')

    pid = os.getpid()
    server_socket = pickle.loads(picklez)
    debug('acquired socket')

    while True:
        debug('Sub process {0} is waiting for connection...'.format(str(pid)))

        client, address = server_socket.accept()
        debug('Sub process {0} accepted connection {1}'.format(str(pid),
              str(client)))

        handle_connection(client)        
        client.close()
        debug('Sub process {0} finished handling connection {1}'.
              format(str(pid),str(client)))

if __name__ == "__main__":    
#   Since most python interpreters have a GIL, multithreading won't cut
#   it... Oughta bust out some process, yo!
    host_port = _parse_cmd_line_args()
    print('Server is running...')
    print('Degree of parallelism: ' + str(DEGREE_OF_PARALLELISM))

    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    print('Socket created.')

    server_socket.bind(host_port)
    server_socket.listen(DEGREE_OF_PARALLELISM)
    print('Socket bount to: ' + str(host_port))        

    buffer = io.BytesIO()
    mp.reduction.ForkingPickler(buffer).dump(server_socket)
    picklez = buffer.getvalue()

    children = []
    for i in range(DEGREE_OF_PARALLELISM):        
        child_process = mp.Process(target=listen, args=(picklez,))
        child_process.daemon = True
        child_process.start()
        children.append(child_process)

        while not child_process.pid:
            sleep(.25)

        print('Process {0} is alive: {1}'.format(str(child_process.pid), 
              str(child_process.is_alive())))     
    print()    

    kids_are_alive = True
    while kids_are_alive:
        print('Press ctrl+c to kill all processes.\n')
        sleep(1) 

        exit_codes = []
        for child_process in children:
            print('Process {0} is alive: {1}'.format(str(child_process.pid), 
              str(child_process.is_alive())))
            print('Process {0} exit code: {1}'.format(str(child_process.pid), 
              str(child_process.exitcode)))
            exit_codes.append(child_process.exitcode)

        if all(exit_codes):
            # Why do they die so young? :(
            print('The children died...')
            print('Why god?')
            print('WHYYyyyyy!!?!?!?')
            kids_are_alive = False