#! /bin/bash
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth0.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth0.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth0.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.lo.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.ip_vti0.rp_filter = 0" >> /etc/sysctl.conf
sysctl -p
echo "iptables -t mangle -A FORWARD -o eth0 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1360" >> /etc/rc.d/rc.local
iptables -t mangle -A FORWARD -o eth0 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1360
chmod +x /etc/rc.d/rc.local
yum install htop iptraf openswan -y
wget -O /etc/ipsec.d/cisco.conf https://s3.cn-north-1.amazonaws.com.cn/myworkshop-lxy/site-to-site-vpn/conn1.conf
wget -O /etc/ipsec.d/cisco.secrets https://s3.cn-north-1.amazonaws.com.cn/myworkshop-lxy/site-to-site-vpn/sec1.conf
echo "alias vi=vim" >> /etc/bashrc
yum update -y