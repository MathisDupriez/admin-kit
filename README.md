# Admin Kit

Admin Kit est un ensemble d'outils de gestion et d'administration de serveur pour les administrateurs système.
Il comprend des scripts pour gérer les utilisateurs SFTP, configurer des hôtes virtuels Nginx, ajouter des enregistrements DNS, et bien plus encore.

## Table des matières

- [Installation](#installation)
- [Utilisation](#utilisation)
- [Commandes Disponibles](#commandes-disponibles)
  - [Commandes de Gestion](#commandes-de-gestion)
  - [Commandes d'Initialisation](#commandes-dinitialisation)
- [Contribuer](#contribuer)
- [Licence](#licence)

## Installation

Pour installer Admin Kit, clonez ce dépôt sur votre serveur et configurez les permissions nécessaires :

```bash
mkdir /opt/script
git clone https://github.com/MathisDupriez/admin-kit.git /opt/script/admin-kit
cd /opt/script/admin-kit
chmod +x admin-kit.sh
```

Assurez-vous que les répertoires `utils` et `init` ont les permissions d'exécution :

```bash
./admin-kit.sh
```

## Utilisation

Pour utiliser Admin Kit, exécutez le script principal avec la commande souhaitée. Voici un exemple pour lister les utilisateurs :

```bash
./admin-kit.sh list-users
```

## Création d'Alias Bash pour Admin Kit

Pour simplifier l'utilisation d'Admin Kit, vous pouvez créer un alias bash. Cela vous permettra d'exécuter les commandes sans avoir à spécifier le chemin complet du script. Suivez ces étapes pour créer un alias :

1. Ouvrez votre fichier `.bashrc` ou `.bash_profile` dans un éditeur de texte :
   
   ```bash
   nano ~/.bashrc
   ```
   Il est fortement recommandé de créer cette alias uniquement dans l'utilisation root.

2. Ajoutez la ligne suivante pour créer un alias pour Admin Kit :

   ```bash
   alias admin-kit='/opt/script/admin-kit/admin-kit.sh'
   ```
   Modifier "admin-kit" comme vous le souhaiter pour une utilisation correct.
   
4. Sauvegardez le fichier et fermez l'éditeur de texte.

5. Rechargez votre fichier `.bashrc` pour appliquer les changements :

   ```bash
   source ~/.bashrc
   ```

Désormais, vous pouvez utiliser `admin-kit` comme commande dans votre terminal pour accéder aux fonctionnalités d'Admin Kit. Par exemple, pour lister les utilisateurs, vous pouvez simplement exécuter :

```bash
admin-kit list-users
```

Si vous ne spécifiez aucune commande, le script affichera la liste des commandes disponibles.

## Commandes Disponibles

### Commandes de Gestion

- **list-users** : Liste tous les utilisateurs du système.
- **system-info** : Affiche des informations système.
- **disk-usage** : Affiche l'utilisation du disque.
- **add-dns-record** : Ajoute un enregistrement DNS pour un serveur bind.
- **add-ldap-user** : Ajoute un compte d'adresse email lier à un utilisateur système (script d'initalisation en cours de création, sera disponible : UN JOUR).
- **remove-ldap-user** : Supprime un compte d'adresse email lier à un utilisateur système.
- **add-proxy-vhost** : Ajoute un hôte virtuel reverse-proxy Nginx.
- **add-static-vhost** : Ajoute un hôte virtuel statique Nginx.
- **add-sftp-user** : Ajoute un utilisateur SFTP.
- **remove-sftp-user** : Supprime un utilisateur SFTP.

### Commandes d'Initialisation

- **init-sftp** : Initialise la configuration SFTP.
- **init-nginx** : Installe Nginx et initialise Nginx avec une configuration de base.

## Contribuer

Les contributions sont les bienvenues ! Si vous souhaitez contribuer à ce projet, veuillez suivre les étapes ci-dessous :

1. Fork le dépôt
2. Créez votre branche de fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Commit vos modifications (`git commit -m 'Add some AmazingFeature'`)
4. Poussez votre branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request
