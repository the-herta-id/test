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
# Warna untuk output (sesuaikan dengan kebutuhan)

# Fungsi untuk menampilkan menu
show_Vmess_menu() {
    clear
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e "              ${WB}----- [ Vmess Menu ] -----${NC}            "
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e " ${MB}[1]${NC}•${LIGHT}Add Vmess Ws${NC}"
    echo -e " ${MB}[2]${NC}•${LIGHT}Add Vmess Grpc${NC}"
    echo -e " ${MB}[3]${NC}•${LIGHT}Add Vmess Http Upgrade${NC}"
    echo -e " ${MB}[4]${NC}•${LIGHT}Add Vmess TCP${NC}"
	echo -e " ${MB}[5]${NC}•${LIGHT}Add Vmess Bundle${NC}"
	echo -e " ${MB}[6]${NC}•${LIGHT}Add Trial${NC}"
	echo -e " ${MB}[7]${NC}•${LIGHT}Menu Utilities${NC}"
    echo -e ""
    echo -e " ${MB}[0]${NC}•${LIGHT}Back To Menu${NC}"
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e ""
}

# Fungsi untuk menangani input menu
handle_Vmess_menu() {
    read -p " Select menu :  "  opt
    echo -e ""
    case $opt in
        1) clear ; addvmws ;;
        2) clear ; addvmgrpc ;;
        3) clear ; addvmhu ;;
        4) clear ; addvmtcp ;;
		5) clear ; addvmess ;;
        6) clear ; addtrial ;;
        7) clear ; menu-akun ;;		
        0) clear ; menu ;;
        *) echo -e "${YB}Invalid input${NC}" ; sleep 1 ; show_Vmess_menu ;;
    esac
}

# Tampilkan menu dan tangani input pengguna
while true; do
    show_Vmess_menu
    handle_Vmess_menu
done
