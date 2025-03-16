#!/bin/bash

# Define global constants
ADMIN_KIT_DIR="/opt/script/admin-kit"
COMMANDS=(
    "list-users"
    "system-info"
    "disk-usage"
    "add-dns-record"
    "add-ldap-user"
    "remove-ldap-user"
    "add-proxy-vhost"
    "add-proxy-cloudflared"
    "add-static-vhost"
    "add-static-cloudflared"
    "remove-nginx-vhost"
    "add-sftp-user"
    "remove-sftp-user"
)
INITCOMMANDS=(
    "init-sftp"
    "init-nginx"
)
# Ensure the admin-kit directory exists
mkdir -p "$ADMIN_KIT_DIR"

# Function to display available commands
list_commands() {
    printf "Available commands:\n"
    for cmd in "${COMMANDS[@]}"; do
        printf "  admin-kit %s\n" "$cmd"
    done
    printf "\n"
    printf "Init commands:\n"
    for cmd in "${INITCOMMANDS[@]}"; do
        printf "  admin-kit %s\n" "$cmd"
    done
}

# Function to call specific command scripts
call_command() {
    local cmd="$1"
    shift

    case "$cmd" in
        "list-users")
            "$ADMIN_KIT_DIR/utils/list-users.sh" "$@"
            ;;
        "system-info")
            "$ADMIN_KIT_DIR/utils/system-info.sh" "$@"
            ;;
        "disk-usage")
            "$ADMIN_KIT_DIR/utils/disk-usage.sh" "$@"
            ;;
        "add-dns-record")
            "$ADMIN_KIT_DIR/utils/add-dns-record.sh" "$@"
            ;;
        "add-ldap-user")
            "$ADMIN_KIT_DIR/utils/add-ldap-user.sh" "$@"
            ;;
        "remove-ldap-user")
            "$ADMIN_KIT_DIR/utils/remove-ldap-user.sh" "$@"
            ;;
        "add-sftp-user")
            "$ADMIN_KIT_DIR/utils/add-sftp-user.sh" "$@"
            ;;
        "add-proxy-vhost")
            "$ADMIN_KIT_DIR/utils/add-proxy-vhost.sh" "$@"
            ;;
        "add-proxy-cloudflared")
            "$ADMIN_KIT_DIR/utils/add-proxy-cloudflared.sh" "$@"
            ;;
        "add-static-vhost")
            "$ADMIN_KIT_DIR/utils/add-static-vhost.sh" "$@"
            ;;
        "add-static-cloudflared")
            "$ADMIN_KIT_DIR/utils/add-static-cloudflared.sh" "$@"
            ;;
        "remove-nginx-vhost")
            "$ADMIN_KIT_DIR/utils/remove-nginx-vhost.sh" "$@"
            ;;
        "init-sftp")
            "$ADMIN_KIT_DIR/init/init-sftp.sh" "$@"
            ;;
        "init-nginx")
            "$ADMIN_KIT_DIR/init/init-nginx.sh" "$@"
            ;;
        "remove-sftp-user")
            "$ADMIN_KIT_DIR/utils/remove-sftp-user.sh" "$@"
            ;;
        *)
            printf "Unknown command: %s\n" "$cmd" >&2
            list_commands
            return 1
            ;;
    esac
}

# Function to check and apply execute permissions to directories and their scripts
check_and_apply_permissions() {
    local dir=$1
    if [ -d "$ADMIN_KIT_DIR/$dir" ]; then
        if [ ! -x "$ADMIN_KIT_DIR/$dir" ]; then
            echo "Le répertoire $dir n'a pas les permissions d'exécution. Application de chmod +x."
            chmod +x "$ADMIN_KIT_DIR/$dir"
            if [ $? -eq 0 ]; then
                echo "Permissions d'exécution appliquées avec succès à $dir."
            else
                echo "Échec de l'application des permissions d'exécution à $dir."
            fi
        else
            echo "Le répertoire $dir a déjà les permissions d'exécution."
        fi

        # Apply execute permissions to all scripts in the directory
        for script in "$ADMIN_KIT_DIR/$dir"/*.sh; do
            if [ -f "$script" ] && [ ! -x "$script" ]; then
                echo "Le script $script n'a pas les permissions d'exécution. Application de chmod +x."
                chmod +x "$script"
                if [ $? -eq 0 ]; then
                    echo "Permissions d'exécution appliquées avec succès à $script."
                else
                    echo "Échec de l'application des permissions d'exécution à $script."
                fi
            fi
        done
    else
        echo "Le répertoire $dir n'existe pas."
    fi
}

# Main function
main() {
    # Check and apply permissions for required directories and their scripts
    check_and_apply_permissions "utils"
    check_and_apply_permissions "init"

    if [[ $# -eq 0 ]]; then
        list_commands
        return 0
    fi

    local cmd="$1"
    shift

    call_command "$cmd" "$@"
}

main "$@"
