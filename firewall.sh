#!/bin/sh
# ------------------------------------------------------------------------------
# TTTTTTTTTTTTTTTTTTTTTTT  1111111    333333333333333   RRRRRRRRRRRRRRRRR   
# T:::::::::::::::::::::T 1::::::1   3:::::::::::::::33 R::::::::::::::::R  
# T:::::::::::::::::::::T1:::::::1   3::::::33333::::::3R::::::RRRRRR:::::R 
# T:::::TT:::::::TT:::::T111:::::1   3333333     3:::::3RR:::::R     R:::::R
# TTTTTT  T:::::T  TTTTTT   1::::1               3:::::3  R::::R     R:::::R
#        T:::::T           1::::1               3:::::3  R::::R     R:::::R
#        T:::::T           1::::1       33333333:::::3   R::::RRRRRR:::::R 
#        T:::::T           1::::l       3:::::::::::3    R:::::::::::::RR  
#        T:::::T           1::::l       33333333:::::3   R::::RRRRRR:::::R 
#        T:::::T           1::::l               3:::::3  R::::R     R:::::R
#        T:::::T           1::::l               3:::::3  R::::R     R:::::R
#        T:::::T           1::::l               3:::::3  R::::R     R:::::R
#      TT:::::::TT      111::::::1113333333     3:::::3RR:::::R     R:::::R
#      T:::::::::T      1::::::::::13::::::33333::::::3R::::::R     R:::::R
#      T:::::::::T      1::::::::::13:::::::::::::::33 R::::::R     R:::::R
#      TTTTTTTTTTT      111111111111 333333333333333   RRRRRRRR     RRRRRRR
# ------------------------------------------------------------------------------
#       www.Obir.Ninja | T13R / Tier - Minecraft (Linux) AntiDDoS Rules
# ------------------------------------------------------------------------------
IPTABLES="/sbin/iptables"

if ! [ $(id -u) = 0 ]; then
   echo "Sadece root kullanicida calistirin!"
   exit 1
# Iptables Bazlı Minecraft Özel Kurallar.
# ------------------------------------------------------------------------------
$IPTABLES -A INPUT -p udp -j DROP
$IPTABLES -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP  
$IPTABLES -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP  
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP  
$IPTABLES -t mangle -A PREROUTING -s 224.0.0.0/3 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 172.16.0.0/12 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 192.168.0.0/16 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 10.0.0.0/8 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 0.0.0.0/8 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP  
$IPTABLES -t mangle -A PREROUTING -p icmp -j DROP  
$IPTABLES -A INPUT -p tcp -m connlimit --connlimit-above 6 -j REJECT --reject-with tcp-reset  
$IPTABLES -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT 
$IPTABLES -A INPUT -p tcp --tcp-flags RST RST -j DROP  
$IPTABLES -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set 
$IPTABLES -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP  
$IPTABLES -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set 
$IPTABLES -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP 
$IPTABLES -N port-scanning 
$IPTABLES -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN 
$IPTABLES -A port-scanning -j DROP

# Kernel Bazlı Minecraft Özel Ayarlar.
# ------------------------------------------------------------------------------
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 0 > /proc/sys/net/ipv4/ip_forward
for i in /proc/sys/net/ipv4/conf/*/rp_filter; do echo 1 > $i; done
echo 1 > /proc/sys/net/ipv4/tcp_syncookies
echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_all
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
for i in /proc/sys/net/ipv4/conf/*/log_martians; do echo 1 > $i; done
echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
for i in /proc/sys/net/ipv4/conf/*/accept_redirects; do echo 0 > $i; done
for i in /proc/sys/net/ipv4/conf/*/send_redirects; do echo 0 > $i; done
for i in /proc/sys/net/ipv4/conf/*/accept_source_route; do echo 0 > $i; done
for i in /proc/sys/net/ipv4/conf/*/mc_forwarding; do echo 0 > $i; done
for i in /proc/sys/net/ipv4/conf/*/proxy_arp; do echo 0 > $i; done
for i in /proc/sys/net/ipv4/conf/*/secure_redirects; do echo 1 > $i; done
for i in /proc/sys/net/ipv4/conf/*/bootp_relay; do echo 0 > $i; done
sh -c 'echo 2000000 > /sys/module/nf_conntrack/parameters/hashsize'
echo "a2VybmVsLnByaW50ayA9IDQgNCAxIDcgCmtlcm5lbC5wYW5pYyA9IDEwIAprZXJuZWwuc3lzcnEgPSAwIAprZXJuZWwuc2htbWF4ID0gNDI5NDk2NzI5NiAKa2VybmVsLnNobWFsbCA9IDQxOTQzMDQgCmtlcm5lbC5jb3JlX3VzZXNfcGlkID0gMSAKa2VybmVsLm1zZ21uYiA9IDY1NTM2IAprZXJuZWwubXNnbWF4ID0gNjU1MzYgCnZtLnN3YXBwaW5lc3MgPSAyMCAKdm0uZGlydHlfcmF0aW8gPSA4MCAKdm0uZGlydHlfYmFja2dyb3VuZF9yYXRpbyA9IDUgCmZzLmZpbGUtbWF4ID0gMjA5NzE1MiAKbmV0LmNvcmUubmV0ZGV2X21heF9iYWNrbG9nID0gMjYyMTQ0IApuZXQuY29yZS5ybWVtX2RlZmF1bHQgPSAzMTQ1NzI4MCAKbmV0LmNvcmUucm1lbV9tYXggPSA2NzEwODg2NCAKbmV0LmNvcmUud21lbV9kZWZhdWx0ID0gMzE0NTcyODAgCm5ldC5jb3JlLndtZW1fbWF4ID0gNjcxMDg4NjQgCm5ldC5jb3JlLnNvbWF4Y29ubiA9IDY1NTM1IApuZXQuY29yZS5vcHRtZW1fbWF4ID0gMjUxNjU4MjQgCm5ldC5pcHY0Lm5laWdoLmRlZmF1bHQuZ2NfdGhyZXNoMSA9IDQwOTYgCm5ldC5pcHY0Lm5laWdoLmRlZmF1bHQuZ2NfdGhyZXNoMiA9IDgxOTIgCm5ldC5pcHY0Lm5laWdoLmRlZmF1bHQuZ2NfdGhyZXNoMyA9IDE2Mzg0IApuZXQuaXB2NC5uZWlnaC5kZWZhdWx0LmdjX2ludGVydmFsID0gNSAKbmV0LmlwdjQubmVpZ2guZGVmYXVsdC5nY19zdGFsZV90aW1lID0gMTIwIApuZXQubmV0ZmlsdGVyLm5mX2Nvbm50cmFja19tYXggPSAxMDAwMDAwMCAKbmV0Lm5ldGZpbHRlci5uZl9jb25udHJhY2tfdGNwX2xvb3NlID0gMCAKbmV0Lm5ldGZpbHRlci5uZl9jb25udHJhY2tfdGNwX3RpbWVvdXRfZXN0YWJsaXNoZWQgPSAxODAwIApuZXQubmV0ZmlsdGVyLm5mX2Nvbm50cmFja190Y3BfdGltZW91dF9jbG9zZSA9IDEwIApuZXQubmV0ZmlsdGVyLm5mX2Nvbm50cmFja190Y3BfdGltZW91dF9jbG9zZV93YWl0ID0gMTAgCm5ldC5uZXRmaWx0ZXIubmZfY29ubnRyYWNrX3RjcF90aW1lb3V0X2Zpbl93YWl0ID0gMjAgCm5ldC5uZXRmaWx0ZXIubmZfY29ubnRyYWNrX3RjcF90aW1lb3V0X2xhc3RfYWNrID0gMjAgCm5ldC5uZXRmaWx0ZXIubmZfY29ubnRyYWNrX3RjcF90aW1lb3V0X3N5bl9yZWN2ID0gMjAgCm5ldC5uZXRmaWx0ZXIubmZfY29ubnRyYWNrX3RjcF90aW1lb3V0X3N5bl9zZW50ID0gMjAgCm5ldC5uZXRmaWx0ZXIubmZfY29ubnRyYWNrX3RjcF90aW1lb3V0X3RpbWVfd2FpdCA9IDEwIApuZXQuaXB2NC50Y3Bfc2xvd19zdGFydF9hZnRlcl9pZGxlID0gMCAKbmV0LmlwdjQuaXBfbG9jYWxfcG9ydF9yYW5nZSA9IDEwMjQgNjUwMDAgCm5ldC5pcHY0LmlwX25vX3BtdHVfZGlzYyA9IDEgCm5ldC5pcHY0LnJvdXRlLmZsdXNoID0gMSAKbmV0LmlwdjQucm91dGUubWF4X3NpemUgPSA4MDQ4NTc2IApuZXQuaXB2NC5pY21wX2VjaG9faWdub3JlX2Jyb2FkY2FzdHMgPSAxIApuZXQuaXB2NC5pY21wX2lnbm9yZV9ib2d1c19lcnJvcl9yZXNwb25zZXMgPSAxIApuZXQuaXB2NC50Y3BfY29uZ2VzdGlvbl9jb250cm9sID0gaHRjcCAKbmV0LmlwdjQudGNwX21lbSA9IDY1NTM2IDEzMTA3MiAyNjIxNDQgCm5ldC5pcHY0LnVkcF9tZW0gPSA2NTUzNiAxMzEwNzIgMjYyMTQ0IApuZXQuaXB2NC50Y3Bfcm1lbSA9IDQwOTYgODczODAgMzM1NTQ0MzIgCm5ldC5pcHY0LnVkcF9ybWVtX21pbiA9IDE2Mzg0IApuZXQuaXB2NC50Y3Bfd21lbSA9IDQwOTYgODczODAgMzM1NTQ0MzIgCm5ldC5pcHY0LnVkcF93bWVtX21pbiA9IDE2Mzg0IApuZXQuaXB2NC50Y3BfbWF4X3R3X2J1Y2tldHMgPSAxNDQwMDAwIApuZXQuaXB2NC50Y3BfdHdfcmVjeWNsZSA9IDAgCm5ldC5pcHY0LnRjcF90d19yZXVzZSA9IDEgCm5ldC5pcHY0LnRjcF9tYXhfb3JwaGFucyA9IDQwMDAwMCAKbmV0LmlwdjQudGNwX3dpbmRvd19zY2FsaW5nID0gMSAKbmV0LmlwdjQudGNwX3JmYzEzMzcgPSAxIApuZXQuaXB2NC50Y3Bfc3luY29va2llcyA9IDEgCm5ldC5pcHY0LnRjcF9zeW5hY2tfcmV0cmllcyA9IDEgCm5ldC5pcHY0LnRjcF9zeW5fcmV0cmllcyA9IDIgCm5ldC5pcHY0LnRjcF9tYXhfc3luX2JhY2tsb2cgPSAxNjM4NCAKbmV0LmlwdjQudGNwX3RpbWVzdGFtcHMgPSAxIApuZXQuaXB2NC50Y3Bfc2FjayA9IDEgCm5ldC5pcHY0LnRjcF9mYWNrID0gMSAKbmV0LmlwdjQudGNwX2VjbiA9IDIgCm5ldC5pcHY0LnRjcF9maW5fdGltZW91dCA9IDEwIApuZXQuaXB2NC50Y3Bfa2VlcGFsaXZlX3RpbWUgPSA2MDAgCm5ldC5pcHY0LnRjcF9rZWVwYWxpdmVfaW50dmwgPSA2MCAKbmV0LmlwdjQudGNwX2tlZXBhbGl2ZV9wcm9iZXMgPSAxMCAKbmV0LmlwdjQudGNwX25vX21ldHJpY3Nfc2F2ZSA9IDEgCm5ldC5pcHY0LmlwX2ZvcndhcmQgPSAwIApuZXQuaXB2NC5jb25mLmFsbC5hY2NlcHRfcmVkaXJlY3RzID0gMCAKbmV0LmlwdjQuY29uZi5hbGwuc2VuZF9yZWRpcmVjdHMgPSAwIApuZXQuaXB2NC5jb25mLmFsbC5hY2NlcHRfc291cmNlX3JvdXRlID0gMCAKbmV0LmlwdjQuY29uZi5hbGwucnBfZmlsdGVyID0gMQ==" | base64 -d > /etc/sysctl.conf
sysctl -p
clear
echo "Anti-DDoS Aktif!!! - www.Obir.Ninja/T13R"
    exit 0
