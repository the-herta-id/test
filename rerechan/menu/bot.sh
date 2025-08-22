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

# Check if bot token and user ID are already set for autokill
env_file="/opt/marzban/.env"

menu() {
	echo -e "${BB}————————————————————————————————————————————————————————${NC}"
	echo -e "               ${WB}----- [ BOT PANEL ] -----${NC}               "
	echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e " ${MB}[1]${NC}•${LIGHT}Set Bot Panel Token and User ID"
    echo -e " ${MB}[2]${NC}•${LIGHT}Delete Bot Panel Token and User ID"
    echo ""    
	echo -e " ${MB}[0]${NC}•${LIGHT}Back To Menu"
	echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    read -rp "Choose an option: " option
    case $option in
        1)
            set_config
            ;;
        2)
            delete_config
            ;;
        0)
            exit 0
            ;;
        *)
            echo "Invalid option."
            menu
            ;;
    esac
}

set_config() {
    if [[ ! -f "$env_file" ]]; then
        # Bot token and user ID not set, prompt user to enter them
        echo "Bot token and user ID are not set. Please enter your bot token and user ID."
        
        read -rp "Enter your Telegram bot token: " botToken
        read -rp "Enter your Telegram user ID: " chatId
        
        # Save the configuration
        {
            echo "TELEGRAM_API_TOKEN= $botToken"
            echo "TELEGRAM_ADMIN_ID= $chatId"
        } | sudo tee -a "$env_file"
        
        echo "Configuration saved successfully. You can now run the Bot panel."
    else
        # Check if the entries already exist
        if ! grep -q "TELEGRAM_API_TOKEN" "$env_file"; then
            read -rp "Enter your Telegram bot token: " botToken
            echo "TELEGRAM_API_TOKEN=$botToken" | sudo tee -a "$env_file"
        fi
        if ! grep -q "TELEGRAM_ADMIN_ID" "$env_file"; then
            read -rp "Enter your Telegram user ID: " chatId
            echo "TELEGRAM_ADMIN_ID=$chatId" | sudo tee -a "$env_file"
        fi
        echo "Configuration is already set. You can now run the Bot panel."
        sleep 3
    fi
}

delete_config() {
    if [[ -f "$env_file" ]]; then
        sudo sed -i '/TELEGRAM_API_TOKEN/d' "$env_file"
        sudo sed -i '/TELEGRAM_ADMIN_ID/d' "$env_file"
        echo "Bot token and user ID have been deleted."
		sleep 3
    else
        echo "Configuration file does not exist."
		
    fi
}

menu
