/interface bridge
add name=loopback

/routing bgp instance
set default as=65500 router-id=10.0.6.2

/routing ospf instance
set [ find default=yes ] router-id=10.0.6.2

/ip address
add address=10.0.6.2/32 interface=loopback network=10.0.6.2
add address=10.0.6.102/30 interface=ether3 network=10.0.6.100
add address=10.0.8.101/30 interface=ether4 network=10.0.8.100
add address=10.0.9.102/30 interface=ether5 network=10.0.9.100

/ip dhcp-client
add disabled=no interface=ether1

/mpls ldp
set enabled=yes lsr-id=10.0.6.2 transport-address=10.0.6.2

/mpls ldp interface
add interface=ether3
add interface=ether4
add interface=ether5

/routing bgp peer
add address-families=vpnv4 name=peer1 remote-address=10.0.3.2 \
    remote-as=65500 update-source=loopback
add address-families=vpnv4 name=peer2 remote-address=10.0.4.2 \
    remote-as=65500 route-reflect=yes update-source=loopback
add address-families=vpnv4 name=peer3 remote-address=10.0.5.2 \
    remote-as=65500 route-reflect=yes update-source=loopback
    
/routing ospf network
add area=backbone network=10.0.6.100/30
add area=backbone network=10.0.8.100/30
add area=backbone network=10.0.9.100/30
add area=backbone network=10.0.6.2/32

/quit
