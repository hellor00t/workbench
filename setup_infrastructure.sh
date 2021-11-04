#!/bin/bash

serverIP=`curl -s -4 icanhazip.com`
domain="testdomain.com"
port="443"
OS=`lsb_release -i | awk '{print $3}' | tail -n 1`

# Build NGINX Server on Kali/Ubuntu Host

if [ `uname` != "Linux" ]
  then echo "[!] Must be run on Linux system"
  exit
fi
if [ $OS != "Ubuntu" ]
  then echo "[!] Must be run on Kali or Ubuntu"
  exit
fi
if [ `id -u` -ne 0 ]
  then echo "[!] Must be run as root!"
  exit
fi

apt update
apt install nginx curl certbot python3-certbot-nginx


echo "[-] Adding Allow HTTPS 443 & HTTP 80 Firewall Rule"
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

        server_name ${domain} www.${domain};

        location / {
                try_files $uri $uri/ =404;
        }
}
EOL

sudo ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
echo "[-] Obtaining Certificate for ${domain}"
certbot --nginx -d ${domain} -d www.${domain}
