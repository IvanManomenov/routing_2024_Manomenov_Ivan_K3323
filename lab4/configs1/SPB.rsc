/interface bridge
add name=loopback

/routing bgp instance
set default as=65500 router-id=10.0.1.2

/routing ospf instance
set [ find default=yes ] router-id=10.0.1.2

/ip address
add address=10.0.1.2/32 interface=loopback network=10.0.1.2
add address=10.0.1.101/30 interface=ether3 network=10.0.1.100
add address=10.0.4.101/30 interface=ether4 network=10.0.4.100

/ip dhcp-client
add disabled=no interface=ether1

/ip route vrf
add export-route-targets=65500:100 import-route-targets=65500:100 interfaces=ether3 route-distinguisher=65500:100 routing-mark=vrf1

/mpls ldp
set enabled=yes lsr-id=10.0.1.2 transport-address=10.0.1.2

/mpls ldp interface
add interface=ether3
add interface=ether4

/routing bgp instance vrf
add redistribute-connected=yes redistribute-ospf=yes routing-mark=vrf1

/routing bgp peer
add address-families=vpnv4 name=peer1 remote-address=10.0.4.2 remote-as=\
    65500 update-source=loopback
    
/routing ospf network
add area=backbone network=10.0.1.100/30
add area=backbone network=10.0.4.100/30
add area=backbone network=10.0.1.2/32

/quit
