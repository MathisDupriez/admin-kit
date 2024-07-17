#!/bin/bash

# Function to display disk usage
disk_usage() {
    printf "Disk Usage:\n"
    df -h
}

disk_usage

