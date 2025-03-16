#!/bin/bash

# Vérifie si le script est exécuté en tant que root
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté en tant que root"
    exit 1
fi

# Vérifie le nombre d'arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <subdomain> <document_root>"
    echo "Exemple: $0 static.example.com /var/www/static-site"
    exit 1
fi

subdomain=$1
document_root=$2

# Vérifications du format du sous-domaine
if ! [[ $subdomain =~ ^[a-zA-Z0-9.-]+$ ]]; then
    echo "Le sous-domaine ne doit contenir que des lettres, des chiffres, des tirets et des points"
    exit 1
fi

# Vérifie si un vhost existe déjà
if [ -f "/etc/nginx/sites-available/$subdomain" ] || [ -L "/etc/nginx/sites-enabled/$subdomain" ]; then
    echo "Un vhost Nginx existe déjà pour ce sous-domaine"
    exit 1
fi

# Vérifie que le dossier des fichiers statiques existe
if [ ! -d "$document_root" ]; then
    echo "Le dossier $document_root n'existe pas. Voulez-vous le créer ? (y/n)"
    read -r create_dir
    if [[ "$create_dir" == "y" ]]; then
        mkdir -p "$document_root"
        echo "Dossier $document_root créé."
    else
        echo "Abandon de la configuration."
        exit 1
    fi
fi

# Vérifie que Certbot est installé
if ! command -v certbot &> /dev/null; then
    echo "Certbot n'est pas installé. Veuillez l'installer avant de continuer."
    exit 1
fi

# Exécute Certbot pour obtenir le certificat SSL via Cloudflare
echo "Obtention du certificat SSL pour $subdomain via Certbot..."
if certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/.secrets/certbot/cloudflare.ini -d "$subdomain"; then
    echo "Certificat SSL obtenu avec succès pour $subdomain."
else
    echo "Échec de l'obtention du certificat SSL. Vérifiez les logs de Certbot."
    exit 1
fi

# Création du fichier de configuration Nginx pour le site statique
config_file="/etc/nginx/sites-available/$subdomain"
echo "server {
    listen 80;
    server_name $subdomain;

    # Redirige HTTP vers HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $subdomain;

    ssl_certificate /etc/letsencrypt/live/$subdomain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$subdomain/privkey.pem;

    root $document_root;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ /\.ht {
        deny all;
    }

    listen [::]:443 ssl;  # Support IPv6
}" > "$config_file"

# Création du lien symbolique
ln -s "$config_file" /etc/nginx/sites-enabled/

# Test et redémarrage de Nginx
echo "Vérification de la configuration Nginx..."
if nginx -t; then
    echo "Configuration valide, redémarrage de Nginx..."
    systemctl restart nginx
    echo "Le serveur statique est en place pour $subdomain → $document_root"
else
    echo "Erreur dans la configuration Nginx. Vérifiez le fichier $config_file."
    exit 1
fi
