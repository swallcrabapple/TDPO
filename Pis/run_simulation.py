
import random
import time
import numpy as np
from node import Agent, addr

n = 4

max_iter = 200

Adj =[]

Agent_list = []


initial_states = [agent.state for agent in Agent_list]
for agent in Agent_list:
    agent.local_sstore = np.array(initial_states, dtype=float)
    agent.sstore_prev = agent.local_sstore.copy()



for k in range(1, max_iter + 1):

    for agent in Agent_list:
        agent.bind()


    for agent in Agent_list:
        agent.send_data()

    time.sleep(0.01)

    for agent in Agent_list:
        agent.recv_data(max_packets)

    for agent in Agent_list:
        agent.socket.close()

