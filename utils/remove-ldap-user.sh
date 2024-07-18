#!/bin/bash

LDAP_ADMIN_PASS="B5H8J4625kzvnG6U6fXx"

# Function to remove user from LDAP
remove_user_from_ldap() {
    local username="$1"
    local fullname="$2"

    ldapdelete -x -D "cn=admin,dc=admin-sys,dc=be" -w "$LDAP_ADMIN_PASS" "cn=${fullname},ou=mail account,dc=admin-sys,dc=be"
    if [[ $? -ne 0 ]]; then
        printf "Error: Failed to remove user from LDAP\n" >&2
        return 1
    fi

    printf "User %s removed from LDAP successfully\n" "$fullname"
}

# Function to remove system user
remove_system_user() {
    local username="$1"

    sudo deluser --remove-home "$username"
    if [[ $? -ne 0 ]]; then
        printf "Error: Failed to remove system user\n" >&2
        return 1
    fi

    printf "System user %s removed successfully\n" "$username"
}

# Main function to remove user
remove_user() {
    # Ask for user details
    local username
    read -p "Enter the username: " username

    local fullname
    read -p "Enter the full name: " fullname

    # Remove user from LDAP
    if ! remove_user_from_ldap "$username" "$fullname"; then
        return 1
    fi

    # Remove system user
    if ! remove_system_user "$username"; then
        return 1
    fi
}

remove_user
