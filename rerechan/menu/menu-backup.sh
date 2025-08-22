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

checking_sc
clear


# Warna untuk output (sesuaikan dengan kebutuhan)

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

# Value yang dibutuhkan
tanggal=$(date +"%m-%d-%Y")
tanggal2=$(date +"%m%d%Y")
waktu=$(date +"%T" | tr -d ':')
InputPass=$(cat /root/passbackup)

# Value Warna
green='\e[0;32m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }

# Authentication
nama=$(cat /root/nama)

# Function to print a stylish header
print_header() {
	echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e "    ${WB}----- [  Backup and Restore Options Menu ] -----${NC}            "
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
}


# Function to restore data from Telegram backup
restore_from_telegram() {
    clear
    print_header
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

    echo "Restoring from Telegram..."

    # Grep Hasil File_ID Terbaru
    FILE_ID=$(grep '^File ID:' /root/file_id.txt | awk '{print $3}' | tail -n 1)

    # Dapatkan tautan unduhan menggunakan curl
    FILE_URL=$(curl -s "https://api.telegram.org/bot$botToken/getFile?file_id=$FILE_ID" | jq -r .result.file_path)

    # Value File_ID menjadi File_Name
    FILE_NAME=$(grep '^###' /root/file_id.txt | cut -d' ' -f2- | tail -n 1)

    # Unduh file menggunakan tautan
    curl -o /root/${FILE_NAME}.zip "https://api.telegram.org/file/bot$botToken/$FILE_URL"
    # Periksa apakah unduhan berhasil
	if [ $? -eq 0 ]; then
  echo "Download successful. Proceeding with unzip..."
  # Proses restorasi atau operasi lain yang perlu dilakukan setelah mengunduh
  unzip -P ${InputPass} /root/${FILE_NAME}.zip -d /root/backup
  # Periksa apakah unzip berhasil
  if [ $? -eq 0 ]; then
    echo "Unzip successful. Restore process complete."
  else
    echo "Error: Unzip failed."
  fi
else
  echo "Error: Download failed."
fi
# Proses ekstrak
cd /root/backup/backup
cp -r *.conf /var/lib/marzban/
cp -r db.sqlite3 /var/lib/marzban/db.sqlite3
cp -r html /var/www/
cp -r marzban /opt/
cp -r xray_config.json /var/lib/marzban/xray_config.json
cp -r telegram_config.conf /root/telegram_config.conf
cp -r file_id.txt /root/file_id.txt
cd
sleep 3
cd /opt/marzban
docker compose down && docker compose up -d
rm -r /root/backup/backup
rm /root/${FILE_NAME}.zip
echo "Tahap restorasi telah selesai"
cd
marzban logs
}


# Function to backup data and send to Telegram
backup_and_send_telegram() {
    clear
    print_header
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

    green='\e[0;32m'
    NC='\e[0m'
    green() { echo -e "\\033[32;1m${*}\\033[0m"; }

    echo -e "Memulai Backup"
    InputPass=$(cat /root/passbackup)
    sleep 1
    echo -e "[ ${green}INFO${NC} ] Processing... "
    mkdir -p /root/backup
    sleep 1

	cp -r /opt/marzban /root/backup/
	cp /var/lib/marzban/xray_config.json /root/backup/
	cp /var/lib/marzban/db.sqlite3 /root/backup/
	cp -r /var/www/html/ /root/backup/
    cp /root/telegram_config.conf /root/backup
    cp /root/file_id.txt /root/backup
    cd /root
    zip -rP ${InputPass} ${nama}_${waktu}_${tanggal2}.zip backup

    ##############++++++++++++++++++++++++#############

    curdir="/root/${nama}_${waktu}_${tanggal2}.zip"
    echo "Sending $curdir to Telegram..."

    #Mengirim dokumen dan mendapatkan respons JSON
    response=$(curl -F chat_id=$chatId -F document=@$curdir https://api.telegram.org/bot$botToken/sendDocument)

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
}

# Function to set backup timer
set_backup_timer() {
    clear
	print_header
    echo -e " ${MB}[1]${NC}•${LIGHT}Set Daily Backup Timer"
    echo -e " ${MB}[2]${NC}•${LIGHT}Set Weekly Backup Timer"
    echo -e " ${MB}[3]${NC}•${LIGHT}Set Monthly Backup Timer"
    echo -e ""
    echo -e " ${MB}[0]${NC} ${LIGHT}Back To Menu${NC}"
	echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    read -rp "Enter your choice: " choice

    case $choice in
        1)
            echo "Enter daily backup time in 24-hour format (HH:MM):"
            read -rp "Example: 02:00 for 2 AM - " daily_backup_time
            # Parse the input time
            hour=$(echo "$daily_backup_time" | cut -d: -f1)
            minute=$(echo "$daily_backup_time" | cut -d: -f2)
            echo "Setting up daily backup at $daily_backup_time..."
            (crontab -l 2>/dev/null; echo "$minute $hour * * * /usr/bin/backup daily") | crontab -
            ;;
        2)
            echo "Enter weekly backup day (0-6, Sunday to Saturday):"
            read -rp "Example: 1 for Monday - " weekly_backup_day
            echo "Enter weekly backup time in 24-hour format (HH:MM):"
            read -rp "Example: 02:00 for 2 AM - " weekly_backup_time
            # Parse the input time
            hour=$(echo "$weekly_backup_time" | cut -d: -f1)
            minute=$(echo "$weekly_backup_time" | cut -d: -f2)
            echo "Setting up weekly backup on day $weekly_backup_day at $weekly_backup_time..."
            (crontab -l 2>/dev/null; echo "$minute $hour * * $weekly_backup_day /usr/bin/backup weekly") | crontab -
            ;;
        3)
            echo "Enter monthly backup day of the month (1-31):"
            read -rp "Example: 1 for the 1st day - " monthly_backup_day
            echo "Enter monthly backup time in 24-hour format (HH:MM):"
            read -rp "Example: 02:00 for 2 AM - " monthly_backup_time
            # Parse the input time
            hour=$(echo "$monthly_backup_time" | cut -d: -f1)
            minute=$(echo "$monthly_backup_time" | cut -d: -f2)
            echo "Setting up monthly backup on day $monthly_backup_day at $monthly_backup_time..."
            (crontab -l 2>/dev/null; echo "$minute $hour $monthly_backup_day * * /usr/bin/backup monthly") | crontab -
            ;;
        0)
            return
            ;;
        *)
            echo "Invalid choice. Exiting..."
            exit 1
            ;;
    esac

    echo "Backup timer set up successfully."
}
# Function to remove backup timer
remove_backup_timer() {
    print_header
    clear
    echo -e " ${MB}[1]${NC} ${LIGHT}Remove Daily Backup Timer"
    echo -e " ${MB}[2]${NC} ${LIGHT}Remove Weekly Backup Timer"
    echo -e " ${MB}[3]${NC} ${LIGHT}Remove Monthly Backup Timer"
    echo -e ""
    echo -e " ${MB}[0]${NC} ${LIGHT}Back To Menu${NC}"
	echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    read -rp "Enter your choice: " choice

    case $choice in
        1)
            echo "Removing daily backup timer..."
            (crontab -l 2>/dev/null | grep -v "/usr/bin/backup daily") | crontab -
            ;;
        2)
            echo "Removing weekly backup timer..."
            (crontab -l 2>/dev/null | grep -v "/usr/bin/backup weekly") | crontab -
            ;;
        3)
            echo "Removing monthly backup timer..."
            (crontab -l 2>/dev/null | grep -v "/usr/bin/backup monthly") | crontab -
            ;;
        4)
            return
            ;;
        *)
            echo "Invalid choice. Exiting..."
            exit 1
            ;;
    esac

    echo "Backup timer removed successfully."
}

clear

# Main menu
while :; do
    print_header
    echo -e " ${MB}[1]${NC}•${LIGHT}Backup and Send to Telegram"
    echo -e " ${MB}[2]${NC}•${LIGHT}Set Backup Timer Perday"
	echo -e " ${MB}[3]${NC}•${LIGHT}Set Backup Timer Hourly"
    echo -e " ${MB}[4]${NC}•${LIGHT}Remove Backup Timer"
    echo -e " ${MB}[5]${NC}•${LIGHT}Restore from Telegram"
    echo -e ""
    echo -e " ${MB}[0]${NC}•${LIGHT}Back To Menu${NC}"
	echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    read -rp "Enter your choice: " choice

    case $choice in
        1) clear ; backup_and_send_telegram ;;
        2) clear ; set_backup_timer ;;
        3) clear ; autobackup ;;
        4) clear ; remove_backup_timer ;;
        5) clear ; restore_from_telegram ;;		
        0) clear ; menu ;;
        *)
		clear
            echo "Invalid choice. Try again."
            ;;
    esac
done
}

