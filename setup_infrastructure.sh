#!/bin/bash

###################################################################
#Script Name    : setup_infrastructure.sh
#Description    : setup offsec relay/pivot point
#Version        : .01
#Author         : Scott
#Twitter        : @hellor00t
#Notes          : Don't change port
###################################################################
 
serverIP=`curl -s -4 icanhazip.com`
domain="<fqdn>" #change this
port="80"
OS=`lsb_release -i | awk '{print $3}' | tail -n 1`
 
if [ `id -u` -ne 0 ]
  then echo "[!] Must be run as root!"
  exit
fi

apt update
apt install nginx curl certbot python3-certbot-nginx -y
 
echo "[-] Adding Allow HTTP 80 Firewall Rule for CertBot"
ufw allow 'Nginx HTTP'
 
if [ `systemctl is-active nginx` != "active" ]
  then systemctl start nginx
fi
 
echo "[-] Setting up domain directory"
 
mkdir -p /var/www/${domain}/html
sudo chown -R $USER:$USER /var/www/${domain}/html
sudo chmod -R 755 /var/www/${domain}
 
cat > /etc/nginx/sites-available/${domain} <<EOL
server {
        listen ${port};
        listen [::]:${port};
 
        root /var/www/${domain}/html;
        index index.html index.htm index.nginx-debian.html;
}
EOL
 
sudo ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
echo "[-] Obtaining Certificate for ${domain}"
certbot --nginx -d ${domain}
ufw allow "Nginx HTTPS"
ufw disable "Nginx HTTP"

echo "[-] Setting up Burp Collab"
#https://teamrot.fi/self-hosted-burp-collaborator-with-custom-domain/