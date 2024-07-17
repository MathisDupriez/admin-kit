#!/bin/bash

# Vérifie si le script est exécuté en tant que root
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté en tant que root"
    exit 1
fi

# Vérifie si le nombre d'arguments est correct
if [ $# -ne 2 ]; then
    echo "Usage: $0 <subdomain> <port>"
    echo "Exemple: $0 subdomain.example.com 3000"
    exit 1
fi
if ! [[ $2 =~ ^[0-9]+$ ]]; then
    echo "Le port doit être un nombre entier"
    exit 1
fi
if [ $2 -lt 1 ] || [ $2 -gt 65535 ]; then
    echo "Le port doit être compris entre 1 et 65535"
    exit 1
fi
if ! [[ $1 =~ ^[a-zA-Z0-9.-]*$ ]]; then
    echo "Le sous-domaine ne doit contenir que des lettres, des chiffres, des tirets et des points"
    exit 1
fi
if [ -f "/etc/nginx/sites-available/$1" ]; then
    echo "Un fichier de configuration Nginx existe déjà pour ce sous-domaine"
    exit 1
fi
if [ -L "/etc/nginx/sites-enabled/$1" ]; then
    echo "Un lien symbolique existe déjà pour ce sous-domaine"
    exit 1
fi
if ! command -v certbot &> /dev/null; then
    echo "Certbot n'est pas installé. Veuillez installer Certbot avant de continuer."
    exit 1
fi
# si on utilise help 
if [ $1 == "help" ]; then
    echo "Usage: $0 <subdomain> <port>"
    echo "Exemple: $0 subdomain.example.com 3000"
    exit 1
fi

subdomain=$1
port=$2

echo "Création du fichier de configuration Nginx pour le sous-domaine $subdomain..."

# Crée un fichier de configuration pour le sous-domaine spécifié
config_file="/etc/nginx/sites-available/$subdomain"
# better security 
echo "server {
    listen 80;
    server_name $subdomain;

    location / {
        proxy_pass http://localhost:$port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}" > $config_file

echo "Création du lien symbolique vers le répertoire sites-enabled..."

# Crée un lien symbolique vers le répertoire sites-enabled
ln -s $config_file /etc/nginx/sites-enabled/

echo "Redémarrage de Nginx pour appliquer les changements..."

# Redémarre Nginx pour appliquer les changements
systemctl restart nginx

echo "Exécution de Certbot pour obtenir un certificat SSL pour le sous-domaine $subdomain..."

# Exécute Certbot pour obtenir un certificat SSL pour le sous-domaine spécifié
sudo certbot --nginx -d $subdomain

echo "Configuration terminée pour le sous-domaine $subdomain. Nginx a été redémarré et HTTPS a été configuré avec succès."
echo "Ce vhost a une sécurité minimal, ajuster les paramètres de sécurité selon vos besoins."
echo "Pour plus de sécurité, vous pouvez ajouter des paramètres de sécurité suivants:"
echo "  - Ajouter des en-têtes de sécurité HTTP (HSTS, CSP, etc.)"
echo "  - Configurer un pare-feu pour limiter l'accès au port $port"
echo "  - Configurer un pare-feu pour limiter l'accès au sous-domaine $subdomain"
echo "  - Configurer un pare-feu pour limiter l'accès à l'adresse IP du serveur"
echo "  Voir la documentation de Nginx et Certbot pour plus d'informations sur la configuration de la sécurité."
echo "  Voir également : https://admin-sys.be pour plus d'informations sur la sécurité Nginx."
