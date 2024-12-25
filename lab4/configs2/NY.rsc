/interface bridge
add name=loopback
add name=vpls protocol-mode=none

/routing bgp instance
set default as=65500 router-id=10.0.2.2

/routing ospf instance
set [ find default=yes ] router-id=10.0.2.2

/interface bridge port
add bridge=vpls interface=ether4

/interface vpls bgp-vpls
add bridge=vpls export-route-targets=1:2 import-route-targets=1:2 name=vpls route-distinguisher=1:2

/ip address
add address=10.0.2.2/32 interface=loopback network=10.0.2.2
add address=10.10.0.3/24 interface=vpls network=10.10.0.0
add address=10.0.2.101/30 interface=ether3 network=10.0.2.100
add address=10.0.5.101/30 interface=ether4 network=10.0.5.100

/ip dhcp-client
add disabled=no interface=ether1

/ip route vrf
add export-route-targets=65500:100 import-route-targets=65500:100 interfaces=ether3 route-distinguisher=65500:100 routing-mark=vrf1

/mpls ldp
set enabled=yes lsr-id=10.0.2.2 transport-address=10.0.2.2

/mpls ldp interface
add interface=ether3
add interface=ether4

/routing bgp instance vrf
add redistribute-connected=yes redistribute-ospf=yes routing-mark=vrf1

/routing bgp peer
add address-families=vpnv4 name=peer1 remote-address=10.0.5.2 remote-as=\
    65500 update-source=loopback
    
/routing ospf network
add area=backbone network=10.0.2.100/30
add area=backbone network=10.0.5.100/30
add area=backbone network=10.0.2.2/32

/quit
