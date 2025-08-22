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
        echo -e "              ${YELLOW}PERIZINAN DITOLAK${NC}"
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

# Panggil fungsi pengecekan izin
checking_sc
clear

# Function to print a stylish header
print_header() {
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e "         ${WB}----- [ Routing Information ] -----${NC}               "
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
}

# Code for service
export RED='\033[0;31m';
export GREEN='\033[0;32m';
export YELLOW='\033[0;33m';
export BLUE='\033[0;34m';
export PURPLE='\033[0;35m';
export CYAN='\033[0;36m';
export LIGHT='\033[0;37m';
export NC='\033[0m';

# Export Banner Status Information
export ERROR="[${RED}ERROR${NC}]";
export INFO="[${YELLOW}INFO${NC}]";
export OKEY="[${GREEN}OKEY${NC}]";
export PENDING="[${YELLOW}PENDING${NC}]";
export SEND="[${YELLOW}SEND${NC}]";
export RECEIVE="[${YELLOW}RECEIVE${NC}]";

# Get ISP and country information
ISP=$(curl -s https://ipinfo.io/org | cut -d' ' -f2-)
COUNTRY=$(curl -s https://ipapi.co/json | jq -r .country_name)

# Function to get geoip information using the specified method
get_geoip_info() {
    local address="$1"
    local geoip_info=""

    # Use different methods based on the outbound tag
    if [[ "$2" == *warp* ]]; then
        geoip_info=$(curl -ks4m8 -x socks5://127.0.0.1:40000 -A Mozilla https://ipapi.co/json 2>/dev/null || echo '{"country_name": "N/A"}')
    else
        geoip_info=$(curl -s -m 5 "https://ipapi.co/$address/json/" 2>/dev/null || echo '{"country_name": "N/A"}')
    fi

    # Validasi response JSON
    if ! echo "$geoip_info" | jq -e . >/dev/null 2>&1; then
        echo '{"country_name": "N/A"}'
    else
        echo "$geoip_info"
    fi
}

# Mengambil nilai domain dan token dari file
domain=$(cat /root/domain)
token=$(cat /root/token.json | jq -r .access_token)

clear
# API endpoint and Authorization token
API_URL="https://${domain}/api/core/config"
HEADERS=(-H "accept: application/json" -H "Authorization: Bearer ${token}")

response=$(curl -s -X GET "$API_URL" "${HEADERS[@]}")
routing_rules=$(echo "$response" | jq -r '.routing.rules')
outbounds=$(echo "$response" | jq -r '.outbounds')

if [ ! -z "$routing_rules" ] && [ ! -z "$outbounds" ]; then
    declare -A outbound_ips
    declare -A outbound_protocols

    # Extract and store outbound IPs and Protocols
    for outbound in $(echo "$outbounds" | jq -c '.[]'); do
        tag=$(echo "$outbound" | jq -r '.tag')
        address=$(echo "$outbound" | jq -r '.settings.servers[0].address // .settings.vnext[0].address')
        address=${address:-"N/A"}

        protocol=$(echo "$outbound" | jq -r '.protocol')
        protocol=${protocol:-"N/A"}

        [ ! -z "$address" ] && outbound_ips["$tag"]=$address
        outbound_protocols["$tag"]=$protocol
    done

    # Print table header
    print_header
    echo -e "${LIGHT}ISP:${NC} ${YELLOW}${ISP}, ${COUNTRY} ${NC}"
    echo ""
    printf "%-5s %-25s %-15s %-15s %-25s\n" "No." "OutboundTag" "Protocol" "Country" "Domains"
    echo "----------------------------------------------------------------------------"

    # Variable to keep track of seen domains
    seen_domains=()

    count=1

    for rule in $(echo "$routing_rules" | jq -c '.[]'); do
        outbound_tag=$(echo "$rule" | jq -r '.outboundTag // ""')
        protocol=${outbound_protocols["$outbound_tag"]}
        protocol=${protocol:-"N/A"}

        address=${outbound_ips["$outbound_tag"]}
        domains=$(echo "$rule" | jq -r '.domain[]? // empty' 2>/dev/null | tr '\n' ' ')

        # Fetch IP info only if address is not N/A and not empty
        if [ -n "$address" ] && [ "$address" != "N/A" ]; then
            geoip_info=$(get_geoip_info "$address" "$outbound_tag")
            ip_info=$(echo "$geoip_info" | jq -r '.country_name // "N/A"')
        else
            ip_info="N/A"
        fi

        # Remove 'geosite:' from domains and filter duplicates
        cleaned_domains=()
        IFS=' ' read -ra domain_array <<< "$domains"
        for domain in "${domain_array[@]}"; do
            cleaned_domain=$(echo "$domain" | sed -E 's/\..*//; s/geosite://g; s/full:.*//; s/regexp:.*//; /^[[:space:]]*$/d')
            if [[ ! " ${seen_domains[@]} " =~ " $cleaned_domain " ]]; then
                seen_domains+=("$cleaned_domain")
                cleaned_domains+=("$cleaned_domain")
            fi
        done

        # Set colors
        color_reset="\e[0m"
        color_red="\e[91m"
        color_yellow="\e[93m"
        color_blue="\e[94m"

        # Color the Country column
        color_code=$color_reset  # Reset color
        if [ "$ip_info" != "N/A" ]; then
            color_code="\e[32m"  # Green color for non-N/A countries
        else
            color_code=$color_red  # Red color for N/A countries
        fi

        # Ambil kata dari domain sesuai aturan
        final_domains=()
        for domain in "${cleaned_domains[@]}"; do
            num_dots=$(grep -o '\.' <<< "$domain" | wc -l)
            if [ "$num_dots" -eq 1 ]; then
                final_domains+=("$(echo "$domain" | cut -d':' -f2)")
            elif [ "$num_dots" -eq 2 ]; then
                final_domains+=("$(echo "$domain" | cut -d'.' -f2- | cut -d':' -f2)")
            else
                final_domains+=("$domain")
            fi
        done

        # Hapus duplikasi dari cleaned_domains
        final_domains=($(echo "${cleaned_domains[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

        # Print formatted output
        for domain in "${final_domains[@]}"; do
            printf "%-5s %-25s %-15s $color_code%-15s\e[0m %-25s\n" "$count" "$outbound_tag" "$protocol" "$ip_info" "$count. $domain"
            count=$((count+1))
        done
    done
else
    echo "Failed to fetch routing rules and outbounds from API."
fi
echo "----------------------------------------------------------------------------"

# Wait for the user to press Enter to proceed to the menu
echo "Press Enter to proceed to the menu..."
read -r