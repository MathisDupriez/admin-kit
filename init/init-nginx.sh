#!/bin/bash

# Fonction pour vérifier si Nginx est installé
is_nginx_installed() {
    if nginx -v &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Fonction pour installer et configurer Nginx
install_nginx() {
    echo "Installation de Nginx..."
    sudo apt update
    sudo apt install -y nginx

    echo "Configuration de base de Nginx..."

    # Désactiver le numéro de version dans les en-têtes de réponse
    sudo sed -i 's/# server_tokens off;/server_tokens off;/' /etc/nginx/nginx.conf

    # Créer un fichier de configuration de site par défaut
    sudo bash -c 'cat > /etc/nginx/sites-available/default <<EOL
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL'

    # Créer un fichier index.html de base
    sudo bash -c 'echo "<!DOCTYPE html><html><head><title>Welcome to Nginx</title></head><body><h1>Success! Nginx is installed and configured.</h1></body></html>" > /var/www/html/index.html'

    # Redémarrer Nginx pour appliquer les changements
    sudo systemctl restart nginx

    echo "Nginx a été installé et configuré avec succès."
}

# Vérification de l'installation de Nginx
if is_nginx_installed; then
    echo "Nginx est déjà installé. Aucune action nécessaire."
else
    install_nginx
fi
