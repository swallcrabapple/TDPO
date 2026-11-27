
from time import sleep
import socket

def client(host,port):

    udp_addr = (host,port)
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    while True:
        for i in range(10):
            udp_socket.sendto(("Hello,I am a UDP socket for: " + str(9-i)).encode('utf-8'), udp_addr)
            j = 9-i
            print("send %d message" % j)
            sleep(1)
        #startflag = "begin"
        #udp_socket.sendto(startflag.encode('utf-8'), udp_addr)


