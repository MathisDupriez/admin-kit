#!/bin/bash

USERNAME=$1
PASSWORD=$2

# Vérifier que les arguments sont passés
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

# Vérification que l'utilisateur n'existe pas déjà
if id "$USERNAME" >/dev/null 2>&1; then
    echo "L'utilisateur $USERNAME existe déjà."
    exit 1
fi

# Créer l'utilisateur avec un dossier home restreint
sudo useradd -m -d /home/$USERNAME -s /usr/sbin/nologin $USERNAME
if [ $? -ne 0 ]; then
    echo "Échec de la création de l'utilisateur $USERNAME."
    exit 1
fi

# Définir le mot de passe de l'utilisateur
echo "$USERNAME:$PASSWORD" | sudo chpasswd
if [ $? -ne 0 ]; then
    echo "Échec de la définition du mot de passe pour l'utilisateur $USERNAME."
    exit 1
fi

# Ajouter l'utilisateur au groupe sftpusers
sudo groupadd sftpusers 2>/dev/null
sudo usermod -aG sftpusers $USERNAME
if [ $? -ne 0 ]; then
    echo "Échec de l'ajout de l'utilisateur $USERNAME au groupe sftpusers."
    exit 1
fi

# Définir les permissions correctes
sudo chmod 755 /home/$USERNAME
if [ $? -ne 0 ]; then
    echo "Échec de la définition des permissions sur /home/$USERNAME."
    exit 1
fi

sudo chown root:root /home/$USERNAME
if [ $? -ne 0 ]; then
    echo "Échec de la définition des permissions de propriété sur /home/$USERNAME."
    exit 1
fi

sudo mkdir /home/$USERNAME/upload
if [ $? -ne 0 ]; then
    echo "Échec de la création du répertoire /home/$USERNAME/upload."
    exit 1
fi

sudo chown $USERNAME:sftpusers /home/$USERNAME/upload
if [ $? -ne 0 ]; then
    echo "Échec de la définition des permissions de propriété sur /home/$USERNAME/upload."
    exit 1
fi

sudo chmod 770 /home/$USERNAME/upload
if [ $? -ne 0 ]; then
    echo "Échec de la définition des permissions sur /home/$USERNAME/upload."
    exit 1
fi

echo "Utilisateur SFTP $USERNAME créé avec succès."
