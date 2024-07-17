#!/bin/bash

# Function to list system users
list_users() {
    printf "Listing users:\n"
    cut -d: -f1 /etc/passwd
}

list_users
