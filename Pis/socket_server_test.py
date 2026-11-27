import os
import struct
import socket
import threading

def server(host,port):
    # host='192.168.43.87'
    # port = 10002
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    udp_socket.bind((host, port))
    udp_socket.listen(10)
    while True:

        client_socket, addr = udp_socket.accept()
        print("Address: %s" % str(addr))

        data= client_socket.recv(1024).decode()
        return data

    #udp_socket.close()
