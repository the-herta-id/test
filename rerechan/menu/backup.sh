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
tanggal=$(date +"%m-%d-%Y")
tanggal2=$(date +"%m%d%Y")
waktu=$(date +"%T" | tr -d ':')

# Check if bot token and user ID are already set
if [[ ! -f "/root/telegram_config.conf" ]]; then
    # Bot token and user ID not set, prompt user to enter them
    echo "Bot token and user ID are not set. Please enter your bot token and user ID."
    
    read -rp "Enter your Telegram bot token: " botToken
    read -rp "Enter your Telegram user ID: " chatId
    
    # Save the configuration
    echo "botToken=$botToken" > "/root/telegram_config.conf"
    echo "chatId=$chatId" >> "/root/telegram_config.conf"
    
    echo "Configuration saved successfully. You can now run the backup script."
    exit 0
fi

# Configuration file exists, load values
source "/root/telegram_config.conf"

# Authentication
nama=$(cat /root/nama)
domain=$(cat /root/domain)

red='\e[1;31m'
green='\e[0;32m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
echo -e "Memulai Backup"
InputPass=$(cat /root/passbackup)
sleep 1
echo -e "[ ${green}INFO${NC} ] Processing... "
mkdir -p /root/backup
sleep 1

	cp -r /opt/marzban /root/backup/
	cp /var/lib/marzban/xray_config.json /root/backup/
	cp /var/lib/marzban/max_ips.conf /root/backup/
	cp /var/lib/marzban/db.sqlite3 /root/backup/
	cp -r /var/www/html/ /root/backup/
    cp /root/telegram_config.conf /root/backup
    cp /root/file_id.txt /root/backup
cd /root
zip -rP ${InputPass} ${nama}_${waktu}_${tanggal2}.zip backup

##############++++++++++++++++++++++++#############

curdir="/root/${nama}_${waktu}_${tanggal2}.zip"
echo "Sending $curdir to Telegram..."

asn_info=$(timeout 5 curl -s "http://ip-api.com/json/$ipsaya" | jq -r '.isp // "Unknown ISP"')
message="
Domain: $domain 
Server Info: $asn_info"
echo "Mengirim file ke Telegram..."
response=$(curl -v --http1.1 -F chat_id=$chatId -F document=@$curdir -F caption="$message" https://api.telegram.org/bot$botToken/sendDocument 2>&1)
curl_status=$?

# Ekstrak file_id dari respons JSON
file_id=$(echo "$response" | jq -r '.result.document.file_id')

# Menyimpan file_id ke file
echo "### ${nama}_${waktu}_${tanggal}" >> /root/file_id.txt
echo "File ID: $file_id" >> /root/file_id.txt
echo "Server telah berhasil backup data pada tanggal $tanggal pukul $waktu." >> "/root/log-backup.txt"
sleep 1
rm -rf /root/backup &> /dev/null
rm -f $curdir &> /dev/null
profile
