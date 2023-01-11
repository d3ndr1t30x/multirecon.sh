#!/bin/bash

# Function to validate IP address
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# Prompt the user for the target host
echo -n "Enter the target host (IP or domain): "
read host

# Input validation for target host
if valid_ip $host; then
    echo "Valid IP address"
elif host=$(getent hosts $host | awk '{ print $1 }'); then
    echo "Valid domain name"
else
    echo "Invalid target host"
    exit 1
fi

# Prompt the user for Nmap parameters
echo -n "Enter any Nmap parameters (leave blank for none): "
read nmap_params

# Run Nmap on the target host
if [ -z "$nmap_params" ]; then
    nmap $host
else
    nmap $nmap_params $host
fi

# Prompt the user for Gobuster parameters
echo -n "Enter Gobuster parameters (leave blank for none): "
read gobuster_params

# Prompt the user for Gobuster wordlist
echo -n "Enter the Gobuster wordlist (leave blank for default): "
read wordlist

# Run Gobuster on the target host
if [ -z "$gobuster_params" ]; then
    if [ -z "$wordlist" ]; then
        gobuster -u $host
    else
        gobuster -u $host -w $wordlist
    fi
else
    if [ -z "$wordlist" ]; then
        gobuster -u $host $gobuster_params
    else
        gobuster -u $host $gobuster_params -w $wordlist
    fi
fi

# Run WhatWeb on the target host
whatweb $host
