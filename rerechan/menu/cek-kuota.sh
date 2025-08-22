#!/bin/bash
# Warna
NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WH='\033[1;37m'
WB='\e[37;1m'

# Install lolcat jika belum ada
command_exists() { command -v "$1" >/dev/null 2>&1; }
if ! command_exists lolcat; then
    apt install lolcat -y >/dev/null 2>&1
fi

biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
RED="\033[0;31m"
YL="\033[33m"
sfile="https://raw.githubusercontent.com/FN-Rerechan02/daatabase/main"
ipsaya=$(curl -s icanhazip.com)
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")
data_ip="https://$sfile/izin"

checking_sc() {
    useexp=$(curl -sS "$data_ip" | grep "$ipsaya" | awk '{print $3}')
    if [[ "$date_list" < "$useexp" ]]; then
        echo -ne ""
    else
        echo -e "${RED}╔════════════════════════════════════════════════════╗${NC}"
        echo -e "${WH}                 ⇱ INFORMASI LISENSI ⇲          ${NC}"  
        echo -e "${RED}╚════════════════════════════════════════════════════╝${NC}"
        echo -e "              IP ${RED} $ipsaya${NC}"
        echo -e "              ${YL}PERIZINAN DITOLAK${NC}"
        echo -e "  ${YL} SCRIPT TIDAK BISA DI GUNAKAN DI VPS ANDA${NC}"
        echo -e " ${YL} SILAHKAN LAKUKAN REGISTRASI TERLEBIH DAHULU${NC}"
        echo -e "${RED}══════════════════════════════════════════════════════${NC}"
        echo -e "    Harga Untuk 1 Bulan 1 IP Address : 15K"
        echo -e "              ${WH}KONTAK REGISTRASI${NC}"
        echo -e "${WH}|Telegram: @project_rerechan | WhatsApp: 083120684925|${NC}"
        echo -e "${RED}══════════════════════════════════════════════════════${NC}"
        exit 0
    fi
}

checking_sc

clear
# Code for service
export RED='\033[0;31m';
export GREEN='\033[0;32m';
export YELLOW='\033[0;33m';
export BLUE='\033[0;34m';
export PURPLE='\033[0;35m';
export CYAN='\033[0;36m';
export LIGHT='\033[0;37m';
export NC='\033[0m';

# Path to the list of Trojan accounts
trojan_account_file="/var/lib/marzban/akun-trojan.conf"

# Path to the list of VMess accounts
vmess_account_file="/var/lib/marzban/akun-vmess.conf"

# Path to the list of VLess accounts
vless_account_file="/var/lib/marzban/akun-vless.conf"

# API information
domain=$(cat /root/domain)
token=$(cat /root/token.json | jq -r .access_token)

# Function to check quota for a specific account type
check_quota() {
    local account_file="$1"
    local protocol="$2"

    echo -e "\n${YELLOW}${protocol}${NC}\n================"

    while IFS= read -r account; do
        # Extracting username from the account line (assuming it's in the 3rd position)
        username=$(echo "$account" | awk '{print $3}')

        # Checking quota using the API
        response=$(curl -s -X 'GET' \
          "https://${domain}/api/user/${username}/usage" \
          -H 'accept: application/json' \
          -H "Authorization: Bearer ${token}")

        # Extracting information from the response
        used_traffic=$(echo "$response" | jq -r '.usages[0].used_traffic')
        used_traffic_gb=$(awk "BEGIN {printf \"%.2f\", ${used_traffic} / (1024^3)}")

        # Displaying user information using printf with color
        printf "${GREEN}%-4s ${NC}%-15s || ${GREEN}%-10s${NC}GB\n" "$((++counter))." "$username" "$used_traffic_gb"
    done < "$account_file"

    echo -e "\n"
}

# Check Trojan account quotas
check_quota "$trojan_account_file" "Trojan"

# Add a separator between protocols
echo "================"

# Check VMess account quotas
check_quota "$vmess_account_file" "VMess"

# Add a separator between protocols
echo "================"

# Check VLess account quotas
check_quota "$vless_account_file" "VLess"
