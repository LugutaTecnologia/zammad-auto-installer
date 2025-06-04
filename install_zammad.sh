#!/usr/bin/env bash

# ============================
# Instalador Automatizado Zammad
# ============================
# Criado por Luguta com auxílio do ChatGPT
# ============================
# Ubuntu 22.04+ | Nginx | Certbot | Elasticsearch | SSL

set -e

echo "==> 🧼 Verificando atualizações do sistema base (apt update, upgrade e autoremove)"
apt update && apt upgrade -y && apt autoremove -y

echo "==> ⚙️  Iniciando instalação automatizada do Zammad"

# Solicita informações
read -p "Digite o domínio para instalação (ex: zammad.seudominio.com.br): " DOMAIN
read -p "Digite seu e-mail para Certbot (Let's Encrypt): " EMAIL
read -s -p "Digite a senha desejada para o Zammad (será usada no ElasticSearch): " ZAMMAD_PASSWORD
echo

# Configura timezone e locale
echo "==> ⏰ Configurando timezone e locale"
timedatectl set-timezone America/Sao_Paulo
locale-gen pt_BR.UTF-8
echo "LANG=pt_BR.UTF-8" | tee /etc/default/locale
update-locale LANG=pt_BR.UTF-8

# Atualiza pacotes
echo "==> 🔄 Atualizando pacotes"
apt update && apt upgrade -y

# Instala dependências básicas
echo "==> 📦 Instalando dependências"
apt install -y curl gnupg apt-transport-https software-properties-common lsb-release ca-certificates wget

# Instala Elasticsearch 7.x
echo "==> 🔍 Instalando Elasticsearch 7.x"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor | tee /usr/share/keyrings/elastic.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
apt update
apt install elasticsearch -y
systemctl enable --now elasticsearch

# Adiciona repositório do Zammad
echo "==> ➕ Adicionando repositório do Zammad"
curl -fsSL https://dl.packager.io/srv/zammad/zammad/key | gpg --dearmor | tee /usr/share/keyrings/zammad.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/zammad.gpg] https://dl.packager.io/srv/deb/zammad/zammad/stable/ubuntu 22.04 main" > /etc/apt/sources.list.d/zammad.list

apt update
apt install zammad -y

# Instala nginx e certbot
echo "==> 🌐 Instalando Nginx e Certbot"
apt install nginx certbot python3-certbot-nginx -y

# Cria bloco inicial HTTP no nginx
echo "==> ⚙️  Criando configuração inicial no Nginx"
mkdir -p /var/www/html
cat > /etc/nginx/sites-available/zammad <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}
EOF

ln -sf /etc/nginx/sites-available/zammad /etc/nginx/sites-enabled/zammad
nginx -t && systemctl restart nginx

# Solicita certificado SSL
echo "==> 🔐 Solicitando certificado SSL com Certbot"
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect

# Recria o virtual host com HTTPS completo
cat > /etc/nginx/sites-available/zammad <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    access_log /var/log/nginx/zammad.access.log;
    error_log  /var/log/nginx/zammad.error.log;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

nginx -t && systemctl reload nginx

# Integração com Elasticsearch no Zammad
echo "==> 🔗 Integrando Zammad com ElasticSearch"
zammad run rails r "Setting.set('es_url', 'http://localhost:9200')"
zammad run rails r "Setting.set('es_password', '$ZAMMAD_PASSWORD')"
zammad run rake zammad:searchindex:rebuild

echo "==> ✅ Instalação concluída com sucesso!"
echo "Acesse: https://$DOMAIN para começar a configurar o Zammad."
