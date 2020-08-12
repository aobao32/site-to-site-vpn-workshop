#! /bin/bash
amazon-linux-extras install -y php7.3
yum install httpd git -y
git clone https://github.com/awslabs/ecs-demo-php-simple-app
mv /ecs-demo-php-simple-app/src/* /var/www/html
rm -rf /ecs-demo-php-simple-app
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "alias vi=vim" >> /etc/bashrc
systemctl restart php-fpm
systemctl restart httpd
yum install rrdtool wqy* fping curl bind-utils httpd httpd-devel perl perl-FCGI perl-CGI perl-CGI-SpeedyCGI perl-libwww-perl perl-Socket6 perl-Net-Telnet perl-Net-OpenSSH perl-Net-DNS perl-LDAP perl-IO-Socket-SSL perl-ExtUtils-MakeMaker rrdtool-perl perl-Sys-Sysloghttpd httpd-devel mod_fcgid rrdtool perl-CGI-SpeedyCGI fping rrdtool-perl perl-Sys-Syslog perl-CPAN perl-local-lib perl-Time-HiRes
yum update -y
amazon-linux-extras install epel -y
yum install smokeping -y
rm -f /etc/httpd/conf.d/smokeping.conf
wget -O /etc/httpd/conf.d/smokeping.conf https://s3.cn-north-1.amazonaws.com.cn/myworkshop-lxy/site-to-site-vpn/apache-smokeping.conf
rm -f /etc/smokeping/config
wget -O /etc/smokeping/config https://s3.cn-north-1.amazonaws.com.cn/myworkshop-lxy/site-to-site-vpn/smokping-config.conf
systemctl restart smokeping
systemctl restart httpd