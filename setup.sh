#!/bin/bash
clear
echo "=== Servidor LAMP + Cloudflare Tunnel para TV Box ==="

# Atualizar sistema
apt update && apt upgrade -y

# INSTALAR CLOUDFLARED PRIMEIRO
echo "📦 Instalando Cloudflared..."
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared focal main' | tee /etc/apt/sources.list.d/cloudflared.list
apt update
apt install cloudflared -y

# Instalar Apache
apt install apache2 -y
systemctl enable apache2 && systemctl start apache2

# Instalar MariaDB
apt install mariadb-server -y
systemctl enable mariadb && systemctl start mariadb

# Configurar MariaDB (senha root123)
echo "🔐 Configurando MariaDB..."
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root123';"
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
echo "🐘 Instalando PHP 8.1..."
apt install software-properties-common -y
add-apt-repository ppa:ondrej/php -y 2>/dev/null || true
apt update
apt install php8.1 libapache2-mod-php8.1 php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip php8.1-cli unzip wget -y
a2enmod php8.1
systemctl restart apache2

# Instalar phpMyAdmin
echo "🗄️ Instalando phpMyAdmin..."
apt install phpmyadmin -y
ln -sf /usr/share/phpmyadmin /var/www/html/phpmyadmin
chown -R www-data:www-data /var/www/html/phpmyadmin

# Arquivo de teste PHP
cat > /var/www/html/info.php <<EOF
<?php phpinfo(); ?>
<h1>✅ LAMP Funcionando! PHP $(php -r "echo PHP_VERSION;")</h1>
EOF

# Cloudflare Tunnel (AGORA FUNCIONA)
echo "=== Configurando Cloudflare Tunnel ==="
cloudflared tunnel login
read -p "Nome do túnel (ex: meu-site): " TUNNEL_NAME
read -p "Domínio (ex: site.seudominio.com): " DOMAIN

# Criar tunnel
cloudflared tunnel create $TUNNEL_NAME
cloudflared tunnel route dns $TUNNEL_NAME $DOMAIN

# Configurar serviço systemd
cat > /etc/cloudflared/config.yml <<EOF
tunnel: $TUNNEL_NAME
credentials-file: /root/.cloudflared/${TUNNEL_NAME}.json
ingress:
  - hostname: $DOMAIN
    service: http://localhost:80
  - service: http_status:404
EOF

# Criar serviço systemd
cat > /etc/systemd/system/cloudflared.service <<EOF
[Unit]
Description=Cloudflared Tunnel
After=network.target

[Service]
ExecStart=/usr/bin/cloudflared tunnel --config /etc/cloudflared/config.yml run
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable cloudflared
systemctl start cloudflared

# Página inicial
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>Servidor LAMP Macb ✅</title>
<style>body{font-family:Arial;text-align:center;padding:50px;background:#f0f8ff;}
.status{background:#d4edda;color:#155724;padding:20px;border-radius:10px;margin:20px;}
.btn{background:#007cba;color:white;padding:15px 30px;text-decoration:none;border-radius:5px;display:inline-block;margin:10px;}</style>
</head>
<body>
<h1>🎉 Servidor LAMP Instalado!</h1>
<div class="status">
<h2>✅ Serviços ativos:</h2>
<ul style="text-align:left;display:inline-block;">
<li>Apache 2.4</li>
<li>PHP 8.1</li>
<li>MariaDB 10.x (root/root123)</li>
<li>phpMyAdmin (/phpmyadmin)</li>
<li>Cloudflare Tunnel</li>
</ul>
</div>
<a href="/phpmyadmin" class="btn">🗄️ phpMyAdmin</a>
<a href="/info.php" class="btn">⚙️ PHP Info</a>
<p>📁 Arquivos: <code>/var/www/html/</code></p>
</body>
</html>
EOF

chown -R www-data:www-data /var/www/html/
echo "✅ INSTALAÇÃO CONCLUÍDA!"
echo "🌐 Site: http://$DOMAIN"
echo "📊 phpMyAdmin: http://$DOMAIN/phpmyadmin (root/root123)"
echo "🔍 PHP Info: http://$DOMAIN/info.php"
echo "📁 Arquivos: /var/www/html/"
echo "🔄 Status tunnel: systemctl status cloudflared"
