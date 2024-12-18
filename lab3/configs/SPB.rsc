/interface bridge
add name=loopback

/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no

/interface vpls
add disabled=no l2mtu=1500 mac-address=02:E6:CD:B4:8E:EA name=eovpls remote-peer=10.0.1.2 vpls-id=65500:666

/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik

/ip pool
add name=dhcp_pool_vpn ranges=10.10.66.3-10.10.66.254

/ip dhcp-server
add address-pool=dhcp_pool_vpn disabled=no interface=vpn name=dhcp_vpn

/routing ospf instance
set [ find default=yes ] router-id=10.0.4.2

/interface bridge port
add bridge=vpn interface=ether3
add bridge=vpn interface=eovpls

/ip address
add address=10.0.4.2 interface=loopback network=10.0.4.2
add address=10.0.4.101/30 interface=ether3 network=10.0.4.100
add address=10.0.3.102/30 interface=ether4 network=10.0.3.100
add address=10.0.9.101/30 interface=ether5 network=10.0.9.100
add address=10.10.66.2/24 interface=vpn network=10.10.66.0

/ip dhcp-client
add disabled=no interface=ether1

/ip dhcp-server network
add address=10.10.66.0/29 dns-server=8.8.8.8,8.8.4.4 gateway=10.10.66.1

/mpls interface set [find default=yes] mpls-mtu=1526

/mpls ldp
set enabled=yes lsr-id=10.0.4.2 transport-address=10.0.4.2

/mpls ldp interface
add interface=ether3
add interface=ether4
add interface=ether5

/routing ospf network
add area=backbone network=10.0.3.100/30
add area=backbone network=10.0.4.100/30
add area=backbone network=10.0.9.100/30
add area=backbone network=10.0.4.2/32

/system identity
set name=SPB
