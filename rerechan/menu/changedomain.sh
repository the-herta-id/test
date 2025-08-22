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

IP_ADDRESS=$(curl -sS ipv4.icanhazip.com)
NAME_CNAME="*.$NAME_A"
TARGET_CNAME="$NAME_A"
clear

# Define color codes
RB='\033[0;31m'  # Red
GB='\033[0;32m'  # Green
YB='\033[1;33m'  # Yellow
BB='\033[1;34m'  # Blue
CB='\033[1;36m'  # Cyan
NC='\033[0m'     # No Color

# Define DNS record types
TYPE_A="A"
TYPE_CNAME="CNAME"

# Function to print messages with color
print_msg() {
    COLOR=$1
    MSG=$2
    echo -e "${COLOR}${MSG}${NC}"
}

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        print_msg $GB "Success"
    else
        print_msg $RB "Failed: $1"
        exit 1
    fi
}

# Function to print error messages
print_error() {
    MSG=$1
    print_msg $RB "Error: ${MSG}"
}

# Function to validate domain format
validate_domain() {
    local domain=$1
    if [[ $domain =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to prompt for domain input
input_domain() {
    while true; do
        echo -e "${YB}Input Domain${NC}"
        echo " "
        read -rp "Input your domain: " -e dns

        if [ -z "$dns" ]; then
            echo -e "${RB}No domain input!${NC}"
        elif ! validate_domain "$dns"; then
            echo -e "${RB}Invalid domain format! Please input a valid domain.${NC}"
        else
            echo "$dns" > /root/domain
            echo "DNS=$dns" > /var/lib/dnsvps.conf
            echo -e "Domain ${GB}${dns}${NC} saved successfully"
            echo -e "${YB}Don't forget to renew the certificate.${NC}"
            break
        fi
    done
}

# Function to get Cloudflare API credentials
get_cloudflare_credentials() {
    if [ ! -f /root/.cloudflare_credentials ]; then
        echo -e "${YB}Enter Cloudflare API credentials:${NC}"
        read -rp "Email: " API_EMAIL
        read -rp "Global API Key: " API_KEY
        
        # Save credentials for future use
        echo "API_EMAIL=$API_EMAIL" > /root/.cloudflare_credentials
        echo "API_KEY=$API_KEY" >> /root/.cloudflare_credentials
        chmod 600 /root/.cloudflare_credentials
    else
        source /root/.cloudflare_credentials
    fi
}

# Function to get Zone ID from Cloudflare
get_zone_id() {
    echo -e "${YB}Getting Zone ID...${NC}"
    ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
        -H "X-Auth-Email: $API_EMAIL" \
        -H "X-Auth-Key: $API_KEY" \
        -H "Content-Type: application/json" | jq -r '.result[0].id')

    if [ "$ZONE_ID" == "null" ]; then
        echo -e "${RB}Failed to get Zone ID${NC}"
        exit 1
    fi

    # Sensored Zone ID (Only showing first and last 3 characters)
    ZONE_ID_SENSORED="${GB}${ZONE_ID:0:3}*****${ZONE_ID: -3}"
    echo -e "${YB}Zone ID: $ZONE_ID_SENSORED${NC}"
}

# Function to handle API responses
handle_response() {
    local response=$1
    local action=$2

    success=$(echo $response | jq -r '.success')
    if [ "$success" == "true" ]; then
        echo -e "$action ${YB}was successful.${NC}"
    else
        echo -e "$action ${RB}failed.${NC}"
        errors=$(echo $response | jq -r '.errors[] | .message')
        echo -e "${RB}Errors: $errors${NC}"
    fi
}

# Function to delete existing DNS record
delete_record() {
    local record_name=$1
    local record_type=$2

    echo -e "${YB}Checking for existing $record_type record: ${CB}$record_name${NC} ${YB}.....${NC}"
    RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=$record_type&name=$record_name" \
        -H "X-Auth-Email: $API_EMAIL" \
        -H "X-Auth-Key: $API_KEY" \
        -H "Content-Type: application/json" | jq -r '.result[0].id')

    if [ "$RECORD_ID" != "null" ]; then
        echo -e "${YB}Deleting existing $record_type record: ${CB}$record_name${NC} ${YB}.....${NC}"
        response=$(curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
            -H "X-Auth-Email: $API_EMAIL" \
            -H "X-Auth-Key: $API_KEY" \
            -H "Content-Type: application/json")
        handle_response "$response" "${YB}Deleting $record_type record:${NC} ${CB}$record_name${NC}"
    else
        echo -e "${GB}No existing $record_type record found for $record_name.${NC}"
    fi
}

# Function to add A record
create_A_record() {
    local record_name=$(cat /var/lib/marzban/a_record 2>/dev/null)
    if [ -n "$record_name" ]; then
        delete_record "$record_name" "$TYPE_A"
    fi

    echo -e "${YB}Adding A record $GB$NAME_A$NC $YB.....${NC}"
    response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "X-Auth-Email: $API_EMAIL" \
        -H "X-Auth-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        --data '{
        "type": "'$TYPE_A'",
        "name": "'$NAME_A'",
        "content": "'$IP_ADDRESS'",
        "ttl": 0,
        "proxied": false
    }')
    echo "$NAME_A" > /root/domain
    echo "$NAME_A" > /var/lib/marzban/a_record
    echo "DNS=$NAME_A" > /var/lib/dnsvps.conf
    handle_response "$response" "${YB}Adding A record $GB$NAME_A$NC"
}

# Function to add CNAME record
create_CNAME_record() {
    local record_name=$(cat /var/lib/marzban/cname_record 2>/dev/null)
    if [ -n "$record_name" ]; then
        delete_record "$record_name" "$TYPE_CNAME"
    fi

    echo -e "${YB}Adding CNAME record for wildcard $GB$NAME_CNAME$NC $YB.....${NC}"
    response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "X-Auth-Email: $API_EMAIL" \
        -H "X-Auth-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        --data '{
        "type": "'$TYPE_CNAME'",
        "name": "'$NAME_CNAME'",
        "content": "'$TARGET_CNAME'",
        "ttl": 0,
        "proxied": false
    }')
    echo "$NAME_CNAME" > /var/lib/marzban/cname_record
    handle_response "$response" "${YB}Adding CNAME record for wildcard $GB$NAME_CNAME$NC"
}

# Function to stop the service using port 80
stop_service_using_port_80() {
    echo -e "${YB}Checking for services using port 80...${NC}"
    SERVICE_INFO=$(lsof -i :80 | grep LISTEN)
    if [ -n "$SERVICE_INFO" ]; then
        SERVICE_PID=$(echo $SERVICE_INFO | awk '{print $2}')
        echo -e "${YB}Stopping service with PID: ${RB}$SERVICE_PID${NC}"
        kill -9 $SERVICE_PID
        check_success "Stopping service using port 80"
    else
        echo -e "${GB}No service using port 80 found.${NC}"
    fi
}

# Function to restart the service (assume the service is named xray)
restart_service() {
    echo -e "${YB}Restarting xray service...${NC}"
    marzban restart
    buat_token
    check_success "Restarting xray service"
}

# Function to create token (placeholder)
buat_token() {
    echo -e "${YB}Generating token...${NC}"
    # Add token generation logic here if needed
}

# Function to update Nginx configuration
update_nginx_config() {
    stop_service_using_port_80
    domain=$(cat /root/domain)

    cd /opt/marzban
    docker compose down
    /root/.acme.sh/acme.sh --server letsencrypt --register-account -m $API_EMAIL --issue -d $domain --standalone -k ec-256 --force --debug
    /root/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /var/lib/marzban/xray.crt --keypath /var/lib/marzban/xray.key --ecc
    docker compose up -d
    cd

    # Check cert
    cat /var/lib/marzban/xray.crt
    cat /var/lib/marzban/xray.key

    restart_service
}

# Function to display the main setup menu
setup_domain() {
    while true; do
        clear

        # Display title
        print_msg $BB "————————————————————————————————————————————————————————"
        print_msg $YB "                      SETUP DOMAIN"
        print_msg $BB "————————————————————————————————————————————————————————"

        # Display options for using random or custom domain
        print_msg $YB "Choose Option:"
        print_msg $YB "1. Use random domain"
        print_msg $YB "2. Use custom domain"

        # Prompt user to choose an option
        read -rp "Enter your choice: " choice

        # Process user's choice
        case $choice in
            1)
                # Use random domain
                get_cloudflare_credentials
                NAME_A=$(curl -s https://random-word-api.herokuapp.com/word?number=2 | jq -r '.[0]').$(curl -s https://random-word-api.herokuapp.com/word?number=2 | jq -r '.[1]').cfdns.net
                DOMAIN=$(echo $NAME_A | cut -d'.' -f2-)
                get_zone_id
                create_A_record
                create_CNAME_record
                update_nginx_config
                break
                ;;
            2)
                # Use custom domain
                input_domain
                DOMAIN=$(cat /root/domain)
                get_cloudflare_credentials
                NAME_A=$DOMAIN
                get_zone_id
                update_nginx_config
                break
                ;;
            *)
                # Invalid option
                print_error "Invalid choice!"
                sleep 2
                ;;
        esac
    done

    # Short delay before clearing screen
    sleep 2
}


# Run the main setup menu
setup_domain

input_menu() {
    # Fill with function or command to display your menu
    echo -e "${YB}Success Change Domain.${NC}"
    sleep 5
    echo -e "${YB}Returning to menu...${NC}"
    sleep 2
    clear
    menu
}

# Call menu function to return to menu
input_menu