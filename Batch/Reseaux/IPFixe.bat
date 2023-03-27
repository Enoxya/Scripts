@echo Be sure Network Cable is unplugged and
@pause

netsh int ipv4 set address name="Ethernet" source=static address=172.16.35.7 mask=255.255.255.0 gateway=172.16.35.6
netsh interface ip add dns name="Ethernet" addr 172.16.0.2 index=1
netsh interface ip add dns name="Ethernet" addr 172.16.0.11 index=2
