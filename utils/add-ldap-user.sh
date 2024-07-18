#!/bin/bash

LDAP_ADMIN_PASS="B5H8J4625kzvnG6U6fXx"

# Function to add user to LDAP
add_user_to_ldap() {
    local username="$1"
    local fullname="$2"
    local email="$3"
    local password="$4"
    local givenname
    local surname

    # Extract given name and surname from full name
    IFS=' ' read -r givenname surname <<< "$fullname"

    # Generate the hashed password using OpenSSL
    local hashed_password
    if ! hashed_password=$(echo -n "$password" | openssl passwd -6 -stdin); then
        printf "Error: Failed to hash password\n" >&2
        return 1
    fi

    # Assuming ldapadd command and LDAP configuration are properly set
    ldapadd -x -D "cn=admin,dc=admin-sys,dc=be" -w "$LDAP_ADMIN_PASS" <<EOF
dn: cn=${fullname},ou=mail account,dc=admin-sys,dc=be
objectClass: inetOrgPerson
objectClass: top
cn: ${fullname}
givenName: ${givenname}
sn: ${surname}
uid: ${username}
mail: ${email}
userPassword: ${hashed_password}
EOF

    if [[ $? -ne 0 ]]; then
        printf "Error: Failed to add user to LDAP\n" >&2
        return 1
    fi

    printf "User %s added to LDAP successfully\n" "$fullname"
}

# Function to create system user
create_system_user() {
    local username="$1"
    local fullname="$2"
    local password="$3"

    sudo adduser --gecos "$fullname" --disabled-password "$username"
    echo "$username:$password" | sudo chpasswd

    if [[ $? -ne 0 ]]; then
        printf "Error: Failed to create system user\n" >&2
        return 1
    fi

    printf "System user %s created successfully\n" "$username"
}

# Function to create SSH key and set proper permissions
create_ssh_key_and_set_permissions() {
    local username="$1"
    local ssh_dir="/home/$username/.ssh"
    local ssh_key="$ssh_dir/id_rsa"
    local authorized_keys="$ssh_dir/authorized_keys"

    sudo -u "$username" mkdir -p "$ssh_dir"
    sudo -u "$username" chmod 700 "$ssh_dir"
    sudo -u "$username" ssh-keygen -t rsa -b 2048 -f "$ssh_key" -N ""
    sudo -u "$username" touch "$authorized_keys"
    sudo -u "$username" chmod 600 "$authorized_keys"
    sudo -u "$username" cat "${ssh_key}.pub" >> "$authorized_keys"
    sudo -u "$username" chmod 600 "$ssh_key"
    sudo -u "$username" chmod 644 "${ssh_key}.pub"

    if [[ $? -ne 0 ]]; then
        printf "Error: Failed to create and set permissions for SSH key\n" >&2
        return 1
    fi

    printf "SSH key for %s created and permissions set successfully\n" "$username"
}

# Function to send SSH key by email
send_ssh_key_by_email() {
    local username="$1"
    local email="$2"
    local ssh_key="/home/$username/.ssh/id_rsa"

    # Send SSH key by email
    local subject="Your SSH Key"
    local body="Hello $username,\n\nPlease find attached your SSH private key.\n\nBest regards,\nAdmin"
    echo -e "$body" | mail -s "$subject" -A "$ssh_key" "$email"

    if [[ $? -ne 0 ]]; then
        printf "Error: Failed to send SSH key by email\n" >&2
        return 1
    fi

    printf "SSH key sent to %s successfully\n" "$email"
}

# Main function to add user
add_user() {
    # Ask for user details
    local username
    read -p "Enter the username: " username

    local fullname
    read -p "Enter the full name: " fullname

    local email
    read -p "Enter the email: " email

    local password
    read -s -p "Enter the password: " password
    echo

    local password_confirm
    read -s -p "Confirm the password: " password_confirm
    echo

    if [[ "$password" != "$password_confirm" ]]; then
        printf "Error: Passwords do not match\n" >&2
        return 1
    fi

    # Add user to LDAP
    if ! add_user_to_ldap "$username" "$fullname" "$email" "$password"; then
        return 1
    fi

    # Create system user
    if ! create_system_user "$username" "$fullname" "$password"; then
        return 1
    fi

    # Create SSH key and set permissions
    if ! create_ssh_key_and_set_permissions "$username"; then
        return 1
    fi

    # Send SSH key by email
    if ! send_ssh_key_by_email "$username" "$email"; then
        return 1
    fi
}

add_user
