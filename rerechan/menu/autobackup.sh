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
IP=$(wget -qO- ipinfo.io/ip)
date=$(date +"%Y-%m-%d")
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"
cek=$(grep -c -E "^# BEGIN_Backup" /etc/crontab)
if [[ "$cek" = "1" ]]; then
    sts="${Info}"
else
    sts="${Error}"
fi

function start30() {
    sed -i "/^# BEGIN_Backup/,/^# END_Backup/d" /etc/crontab

    cat << EOF >> /etc/crontab
# BEGIN_Backup
*/30 * * * * root backup
# END_Backup
EOF
    service cron restart
    sleep 1
    echo " Please Wait"
    clear
    echo " Autobackup Has Been Started"
    echo " Data Will Be Backed Up Every : 30 Minutes"
    
}

function start1() {
    sed -i "/^# BEGIN_Backup/,/^# END_Backup/d" /etc/crontab

    cat << EOF >> /etc/crontab
# BEGIN_Backup
0 */1 * * * root backup
# END_Backup
EOF
    service cron restart
    sleep 1
    echo " Please Wait"
    clear
    echo " Autobackup Has Been Started"
    echo " Data Will Be Backed Up Every : 1 Hour"
    
}

function start3() {
    sed -i "/^# BEGIN_Backup/,/^# END_Backup/d" /etc/crontab

    cat << EOF >> /etc/crontab
# BEGIN_Backup
0 */3 * * * root backup
# END_Backup
EOF
    service cron restart
    sleep 1
    echo " Please Wait"
    clear
    echo " Autobackup Has Been Started"
    echo " Data Will Be Backed Up Every : 3 Hours"
    
}

function start6() {
    sed -i "/^# BEGIN_Backup/,/^# END_Backup/d" /etc/crontab

    cat << EOF >> /etc/crontab
# BEGIN_Backup
0 */6 * * * root backup
# END_Backup
EOF
    service cron restart
    sleep 1
    echo " Please Wait"
    clear
    echo " Autobackup Has Been Started"
    echo " Data Will Be Backed Up Every : 6 Hours"
    
}

function start12() {
    sed -i "/^# BEGIN_Backup/,/^# END_Backup/d" /etc/crontab

    cat << EOF >> /etc/crontab
# BEGIN_Backup
0 */12 * * * root backup
# END_Backup
EOF
    service cron restart
    sleep 1
    echo " Please Wait"
    clear
    echo " Autobackup Has Been Started"
    echo " Data Will Be Backed Up Every : 12 Hours"
    
}

function stop() {
    sed -i "/^# BEGIN_Backup/,/^# END_Backup/d" /etc/crontab
    service cron restart
    sleep 1
    echo " Please Wait"
    clear
    echo " Autobackup Has Been Stopped"
    
}

echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "         ${WB}----- [  Autobackup Data ] -----${NC}            "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "$sts     "
echo -e " ${MB}[1]${NC}•${LIGHT}Start Autobackup Every 1 Hour"
echo -e " ${MB}[2]${NC}•${LIGHT}Start Autobackup Every 3 Hours"
echo -e " ${MB}[3]${NC}•${LIGHT}Start Autobackup Every 6 Hours"
echo -e " ${MB}[4]${NC}•${LIGHT}Start Autobackup Every 12 Hours"
echo -e " ${MB}[5]${NC}•${LIGHT}Start Autobackup Every 30 Minutes"
echo -e " ${MB}[6]${NC}•${LIGHT}Stop Autobackup"
echo -e ""
echo -e " ${MB}[0]${NC} ${LIGHT}Back To Menu${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
read -rp "Enter your choice: " -e num
case $num in
    1 | 01) clear; start1 ;;
    2 | 02) clear; start3 ;;
    3 | 03) clear; start6 ;;
    4 | 04) clear; start12 ;;
    5 | 05) clear; start30 ;;
    6 | 06) clear; stop ;;
    0 | 00) clear; menu ;;
    *) clear; menu ;;
esac
	  read -n 1 -s -r -p "Press any key to back on menu"
	  clear
	  menu-backup