/interface bridge
add name=loopback

/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no

/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik

/routing ospf instance
set [ find default=yes ] router-id=10.0.2.2

/ip address
add address=10.0.2.2 interface=loopback network=10.0.2.2
add address=10.0.2.101/30 interface=ether3 network=10.0.2.100
add address=10.0.1.102/30 interface=ether4 network=10.0.1.100

/ip dhcp-client
add disabled=no interface=ether1

/mpls interface set [find default=yes] mpls-mtu=1526

/mpls ldp
set enabled=yes lsr-id=10.0.2.2 transport-address=10.0.2.2

/mpls ldp interface
add interface=ether3
add interface=ether4

/routing ospf network
add area=backbone network=10.0.1.100/30
add area=backbone network=10.0.2.100/30
add area=backbone network=10.0.2.2/32

/system identity
set name=LND
