#!/bin/bash

# Nom de domaine fixe
DOMAIN="test.admin-sys.be"
ZONE_FILE="/etc/bind/${DOMAIN}.zone"

# Function to add DNS record
add_dns_record() {
    # Vérifie si le fichier de zone existe
    if [[ ! -f "$ZONE_FILE" ]]; then
        printf "Error: Zone file not found: %s\n" "$ZONE_FILE" >&2
        return 1
    fi

    # Demande à l'utilisateur de saisir le nom du record
    local record_name
    read -p "Enter the record name: " record_name

    # Demande à l'utilisateur de saisir le type d'enregistrement
    local record_type
    read -p "Enter the record type (e.g., A, CNAME, MX): " record_type

    # Demande à l'utilisateur de saisir la valeur de l'enregistrement
    local record_value
    read -p "Enter the record value: " record_value

    # Ajoute l'enregistrement au fichier de zone
    printf "%s.%s. IN %s %s\n" "$record_name" "$DOMAIN" "$record_type" "$record_value" >> "$ZONE_FILE"

    # Redémarre le service BIND pour appliquer les modifications
    if systemctl restart bind9; then
        printf "Record added successfully for domain %s: %s.%s IN %s %s\n" "$DOMAIN" "$record_name" "$DOMAIN" "$record_type" "$record_value"
    else
        printf "Error: Failed to restart BIND service\n" >&2
        return 1
    fi
}

add_dns_record
