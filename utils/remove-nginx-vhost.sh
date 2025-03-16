#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté en tant que root"
    exit 1
fi

if [ $# -ne 1 ]; then
    echo "Usage: $0 <subdomain>"
    exit 1
fi

subdomain=$1

if [ -f "/etc/nginx/sites-available/$subdomain" ]; then
    rm "/etc/nginx/sites-available/$subdomain"
fi

if [ -L "/etc/nginx/sites-enabled/$subdomain" ]; then
    rm "/etc/nginx/sites-enabled/$subdomain"
fi

nginx -t && systemctl reload nginx
echo "Le vhost $subdomain a été supprimé."
