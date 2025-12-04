#!/bin/bash

# Atualizar sistema
apt update && apt upgrade -y

# Instalar Apache (já existente, mas reforçar)
apt install apache2 -y
systemctl enable apache2
systemctl start apache2

# Instalar MariaDB (MySQL compatível)
apt install mariadb-server mariadb-client -y
systemctl enable mariadb
systemctl start mariadb

# Configurar MariaDB com senha root segura
mysql_secure_installation <<EOF

y
sua_senha_root_aqui
sua_senha_root_aqui
y
y
y
y
EOF

# Instalar PHP 8.1 + módulos (mais estável que 7.2 para 2025)
apt install software-properties-common -y
add-apt-repository ppa:ondrej/php -y
apt update
apt install php8.1 libapache2-mod-php8.1 php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip php8.1-cli -y

# Reiniciar Apache para PHP
systemctl restart apache2

# Instalar phpMyAdmin
apt install phpmyadmin -y

# Configurar phpMyAdmin (blowfish secret e link simbólico)
echo "\$cfg['blowfish_secret'] = 'sua_chave_secreta_32_caracteres_aqui';" > /etc/phpmyadmin/blowfish_secret.inc.php
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Cloudflare Tunnel (manter existente)
# ... (código original do tunnel aqui: autenticação, nome, domínio)

echo "LAMP instalado! Acesse:"
echo "- Site: http://seu-ip ou domínio"
echo "- phpMyAdmin: http://seu-ip/phpmyadmin (user: root, senha: sua_senha_root)"
