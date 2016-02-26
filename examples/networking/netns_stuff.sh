#!/bin/bash

[ ! -d /var/run/netns ] && sudo mkdir -p /var/run/netns 

echo "Clearing any previous verizon containers"
if docker ps -a | grep verizon | awk '{print $1}' ; then
    if docker ps | grep verizon | awk '{print $1}' ; then
        docker kill $(docker ps -a | grep verizon | awk '{print $1}')
    fi
    docker rm $(docker ps -a | grep verizon | awk '{print $1}')
fi

docker run --net=none --dns=8.8.8.8 --name=verizon -d ubuntu /bin/sh -c "while true; do echo ""; done"
pid=$(docker inspect -f '{{.State.Pid}}' verizon)
if [ -L /var/run/netns/verizon ]; then
  sudo rm /var/run/netns/verizon
fi

sudo ln -s /proc/$pid/ns/net /var/run/netns/verizon

echo "Clearing any previous router containers"
if docker ps -a | grep router | awk '{print $1}' ; then
    if docker ps | grep router | awk '{print $1}' ; then
        docker kill $(docker ps -a | grep router | awk '{print $1}')
    fi
    docker rm $(docker ps -a | grep router | awk '{print $1}')
fi

docker run --net=none --dns=8.8.8.8 --name=router -d ubuntu /bin/sh -c "while true; do echo ""; done"
pid=$(docker inspect -f '{{.State.Pid}}' router)
if [ -L /var/run/netns/router ]; then
  sudo rm /var/run/netns/router
fi
sudo ln -s /proc/$pid/ns/net /var/run/netns/router

echo "Clearing any previous laptop containers"
if docker ps -a | grep laptop | awk '{print $1}' ; then
    if docker ps | grep laptop | awk '{print $1}' ; then
        docker kill $(docker ps -a | grep laptop | awk '{print $1}')
    fi
    docker rm $(docker ps -a | grep laptop | awk '{print $1}')
fi

docker run --net=none --dns=8.8.8.8 --name=laptop -d ubuntu /bin/sh -c "while true; do echo ""; done"
pid=$(docker inspect -f '{{.State.Pid}}' laptop)
if [ -L /var/run/netns/laptop ]; then
  sudo rm /var/run/netns/laptop
fi
sudo ln -s /proc/$pid/ns/net /var/run/netns/laptop

echo "create_intreface verizon_eth0 --> eth1"
sudo ip link add verizon_eth0 type veth peer name P
sudo ip link set P netns verizon
sudo ip netns exec verizon ip link set dev P name eth0
sudo ip netns exec verizon ip link set eth0 up

echo "connection verizon to docker0"
sudo brctl addif docker0 verizon_eth0
sudo ip link set dev verizon_eth0 up


echo "create_intreface router_eth1"
sudo ip link add router_eth1 type veth peer name P
sudo ip link set P netns router
sudo ip netns exec router ip link set dev P name eth1
sudo ip netns exec router ip link set eth1 up

echo "create_interface laptop_eth1"

sudo ip link add laptop_eth1 type veth peer name P
sudo ip link set P netns laptop
sudo ip netns exec laptop ip link set dev P name eth1
sudo ip netns exec laptop ip link set eth1 up

echo "start_bridge home"
sudo brctl addbr home
sudo ip link set home up

echo "bridge_add_interface home laptop_eth1"
sudo brctl addif home laptop_eth1
sudo ip link set dev laptop_eth1 up

echo "bridge_add_interface home router_eth1"
sudo brctl addif home router_eth1
sudo ip link set dev router_eth1 up

echo "create_point_to_point verizon eth1 router eth0"
sudo ip netns exec verizon ip link set eth1 up
sudo ip link add P type veth peer name Q

echo "give_interface_to_container P verzion eth1"
sudo ip link set P netns verizon
sudo ip netns exec verizon ip link set dev P name eth1
sudo ip netns exec verizon ip link set eth1 up

echo "give_interface_to_container Q router eth0"
sudo ip link set Q netns router
sudo ip netns exec router ip link set dev Q name eth0
sudo ip netns exec router ip link set eth0 up

echo "Add IP info for verizon's eths"
sudo ip netns exec verizon ip addr add 172.17.42.10/16 dev eth0
sudo ip netns exec verizon ip addr add 10.25.1.1/32 dev eth1

echo "Add route info for verizon's eths"
sudo ip netns exec verizon ip route add default via 172.17.42.1
sudo ip netns exec verizon ip route add 172.17.42.1 dev eth0
sudo ip netns exec verizon ip route add 10.25.1.65/32 dev eth1
sudo ip netns exec verizon iptables --table nat \
    --append POSTROUTING --out-interface eth0 -j MASQUERADE

echo "Add IP info for router's eths"
sudo ip netns exec router ip addr add 10.25.1.65/16 dev eth0
sudo ip netns exec router ip addr add 192.168.1.1/24 dev eth1

echo "Add route info for router's eths"
sudo ip netns exec router ip route add default via 10.25.1.1
sudo ip netns exec router iptables --table nat \
    --append POSTROUTING --out-interface eth0 -j MASQUERADE

sudo ip netns exec laptop ip route del default

echo "Add ip info for laptop's ips"
sudo ip netns exec laptop ip addr add 192.168.1.10/24 dev eth1

echo "Add route info for laptop's ips"
sudo ip netns exec laptop ip route add default via 192.168.1.1
