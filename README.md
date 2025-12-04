# 🚀 Servidor LAMP Macb para TV Box

Script **one-click** instala **LAMP completo** (Apache + MariaDB + PHP 8.1 + phpMyAdmin) + **Cloudflare Tunnel** em Ubuntu TV Box.

## 📋 Como Usar

bash <(curl -sSL https://raw.githubusercontent.com/macbservices/Servidor-Lamp-Macb/main/setup.sh)


**O script faz tudo automaticamente:**
- ✅ Atualiza sistema Ubuntu
- ✅ Instala Apache, MariaDB, PHP 8.1
- ✅ Configura phpMyAdmin (/phpmyadmin)
- ✅ Autentica Cloudflare Tunnel
- ✅ Cria tunnel com seu domínio

## 🔑 Credenciais Padrão
- **phpMyAdmin**: `root` / `root123`
- **Arquivos site**: `/var/www/html/`

## 🧪 Testes
- Site: `http://seudominio.com`
- PHP Info: `http://seudominio.com/info.php`
- phpMyAdmin: `http://seudominio.com/phpmyadmin`

## ⚙️ Requisitos
- TV Box com Ubuntu 18.04+
- Conta Cloudflare com domínio
- Internet estável

**Autor: macbservices** | [GitHub](https://github.com/macbservices/Servidor-Lamp-Macb)

