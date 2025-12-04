#!/bin/bash
clear
echo "=== Servidor LAMP + Cloudflare Tunnel para TV Box ==="

# Atualizar sistema
apt update && apt upgrade -y

# Instalar Apache
apt install apache2 -y
systemctl enable apache2 && systemctl start apache2

# Instalar MariaDB
apt install mariadb-server -y
systemctl enable mariadb && systemctl start mariadb

# Configurar MariaDB
mysql_secure_installation <<EOF
y
root123
root123
y
y
y
y
EOF

# Instalar PHP 8.1 + módulos
apt install software-properties-common -y
add-apt-repository ppa:ondrej/php -y
apt update
apt install php8.1 libapache2-mod-php8.1 php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip -y
systemctl restart apache2

# Instalar phpMyAdmin
apt install phpmyadmin -y
ln -sf /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Arquivo de teste PHP
cat > /var/www/html/info.php <<EOF
<?php phpinfo(); ?>
EOF

# Cloudflare Tunnel
echo "=== Configurando Cloudflare Tunnel ==="
cloudflared tunnel login
read -p "Nome do túnel (ex: meu-site): " TUNNEL_NAME
read -p "Domínio (ex: site.seudominio.com): " DOMAIN

cloudflared tunnel create $TUNNEL_NAME
cloudflared tunnel route dns $TUNNEL_NAME $DOMAIN

cat > /etc/cloudflared/config.yml <<EOF
tunnel: $TUNNEL_NAME
credentials-file: /root/.cloudflared/${TUNNEL_NAME}.json
ingress:
  - hostname: $DOMAIN
    service: http://localhost:80
  - service: http_status:404
EOF

systemctl enable cloudflared && systemctl start cloudflared

echo "✅ INSTALAÇÃO CONCLUÍDA!"
echo "🌐 Site: http://$DOMAIN"
echo "📊 phpMyAdmin: http://$DOMAIN/phpmyadmin (root/root123)"
echo "🔍 Teste PHP: http://$DOMAIN/info.php"
echo "📁 Arquivos: /var/www/html/"
