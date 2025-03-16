#!/bin/bash

USERNAME=$1

# Vérifier que l'argument est passé
if [ -z "$USERNAME" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# Vérifier que l'utilisateur existe
if ! id "$USERNAME" >/dev/null 2>&1; then
    echo "L'utilisateur $USERNAME n'existe pas."
    exit 1
fi

# Supprimer l'utilisateur
sudo userdel $USERNAME
if [ $? -ne 0 ]; then
    echo "Échec de la suppression de l'utilisateur $USERNAME."
    exit 1
fi

# Supprimer le répertoire home de l'utilisateur
sudo rm -rf /home/$USERNAME
if [ $? -ne 0 ]; then
    echo "Échec de la suppression du répertoire home de l'utilisateur $USERNAME."
    exit 1
fi

# Vérifier si le groupe sftpusers existe et supprimer s'il est vide
if getent group sftpusers >/dev/null; then
    if [ -z "$(getent group sftpusers | awk -F: '{print $4}')" ]; then
        sudo groupdel sftpusers
        if [ $? -ne 0 ]; then
            echo "Échec de la suppression du groupe sftpusers."
            exit 1
        fi
    fi
fi

echo "Utilisateur SFTP $USERNAME supprimé avec succès."
