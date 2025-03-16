#!/bin/bash

# Vérifier que SSH est installé
if ! command -v ssh >/dev/null 2>&1; then
    echo "SSH n'est pas installé. Installation de SSH..."
    sudo apt-get update
    sudo apt-get install -y openssh-server
    if [ $? -ne 0 ]; then
        echo "Échec de l'installation de SSH."
        exit 1
    fi
else
    echo "SSH est déjà installé."
fi

# Fichier de configuration SSH
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# Sauvegarder la configuration SSH actuelle
sudo cp $SSH_CONFIG_FILE ${SSH_CONFIG_FILE}.bak
if [ $? -ne 0 ]; then
    echo "Échec de la sauvegarde du fichier de configuration SSH."
    exit 1
fi
echo "Sauvegarde de la configuration SSH effectuée."

# Retirer toute configuration SFTP existante
sudo sed -i '/^Subsystem sftp/d' $SSH_CONFIG_FILE
sudo sed -i '/^Match Group sftpusers/,/^$/d' $SSH_CONFIG_FILE
echo "Ancienne configuration SFTP supprimée."

# Ajouter la nouvelle configuration SFTP
sudo tee -a $SSH_CONFIG_FILE > /dev/null <<EOT
Subsystem sftp internal-sftp

Match Group sftpusers
    ChrootDirectory /home/%u
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
    PasswordAuthentication yes
EOT
if [ $? -ne 0 ]; then
    echo "Échec de la mise à jour du fichier de configuration SSH."
    exit 1
fi
echo "Nouvelle configuration SFTP ajoutée."

# Redémarrer le service SSH
sudo systemctl restart sshd
if [ $? -ne 0 ]; then
    echo "Échec du redémarrage du service SSH."
    exit 1
fi
echo "Service SSH redémarré avec succès."

echo "Configuration SFTP initialisée avec succès."
