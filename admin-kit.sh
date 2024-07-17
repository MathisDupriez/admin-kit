#!/bin/bash

# Define global constants
ADMIN_KIT_DIR="/opt/script/admin-kit"
COMMANDS=(
    "list-users"
    "system-info" 
    "disk-usage" 
    "add-dns-record" 
    "add-user" 
    "remove-user")

# Ensure the admin-kit directory exists
mkdir -p "$ADMIN_KIT_DIR"

# Function to display available commands
list_commands() {
    printf "Available commands:\n"
    for cmd in "${COMMANDS[@]}"; do
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
        "add-user")
            "$ADMIN_KIT_DIR/utils/add-user.sh" "$@"
            ;;
        "remove-user")
            "$ADMIN_KIT_DIR/utils/remove-user.sh" "$@"
            ;;
        *)
            printf "Unknown command: %s\n" "$cmd" >&2
            list_commands
            return 1
            ;;
    esac
}

# Main function
main() {
    if [[ $# -eq 0 ]]; then
        list_commands
        return 0
    fi

    local cmd="$1"
    shift

    call_command "$cmd" "$@"
}

main "$@"
