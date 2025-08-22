#!/bin/bash

# Informasi Layanan
export RED='\033[0;31m';
export GREEN='\033[0;32m';
export YELLOW='\033[0;33m';
export BLUE='\033[0;34m';
export PURPLE='\033[0;35m';
export CYAN='\033[0;36m';
export LIGHT='\033[0;37m';
export NC='\033[0m';

export ERROR="[${RED}ERROR${NC}]";
export INFO="[${YELLOW}INFO${NC}]";
export OKEY="[${GREEN}OKEY${NC}]";
export PENDING="[${YELLOW}PENDING${NC}]";
export SEND="[${YELLOW}SEND${NC}]";
export RECEIVE="[${YELLOW}RECEIVE${NC}]";

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
domain=$(cat /root/domain)
clientname=$(cat /etc/profil)
Exp2=$(curl -sS "$data_ip" | grep "$ipsaya" | awk '{print $3}')
d1=$(date -d "$Exp2" +%s)
d2=$(date -d "$today" +%s)
certificate=$(( (d1 - d2) / 86400 ))


# Function to print a stylish line
print_line() {
    echo "------------------------"
}

# VAR
if [[ $(netstat -ntlp | grep -i wireproxy | grep -i 127.0.0.1:40000 | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g') == '40000' ]]; then
    WARP="${OKEY} Listening to 127.0.0.1:40000";
    WARP_STATUS="${GREEN}WARP AMAN!${NC}"
else
    WARP="${ERROR}";
    WARP_STATUS="${RED}WARP ADA ERROR BOSSKUH${NC}"
fi
if [[ $(systemctl status ufw | grep -w active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == 'active' ]]; then
    UFW="${GREEN}[ON]${NC}";
else
    UFW="${RED}[ERROR!]${NC}";
fi
if [[ $(systemctl status fail2ban | grep -w active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == 'active' ]]; then
    F2B="${GREEN}[ON]${NC}";
else
    F2B="${RED}[ERROR!]${NC}";
fi

# Warna untuk output (sesuaikan dengan kebutuhan)
export YELLOW='\033[0;33m';
export CLIENT="[${MB}CLIENTNAME${NC}]";
export DURATION="[${MB}DURATION${NC}]";
export EXP="[${MB}EXP${NC}]";

# Fungsi untuk menampilkan menu
show_menu() {
    clear
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e "           ----- [ AUTOSCRIPT TUNNELING ] -----              " | lolcat
    echo -e "      PROJECT RERECHAN TELEGRAM: @project_rerechan      " | lolcat
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e "                   ${WB}----- [ Menu ] -----${NC}               "
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e " ${MB}[•01]${NC}•${LIGHT}Vmess Menu${NC}"
    echo -e " ${MB}[•02]${NC}•${LIGHT}Vless Menu${NC}"
    echo -e " ${MB}[•03]${NC}•${LIGHT}Trojan Menu${NC}"
    echo -e " ${MB}[•04]${NC}•${LIGHT}Shadowsock Menu${NC}"
    echo -e " ${MB}[•05]${NC}•${LIGHT}Marzban Menu${NC}"
    echo -e " ${MB}[•06]${NC}•${LIGHT}Backup Menu${NC}"
    echo -e " ${MB}[•07]${NC}•${LIGHT}System Menu${NC}"
    echo -e " ${MB}[•08]${NC}•${LIGHT}Speedtest${NC}"
    echo -e " ${MB}[•09]${NC}•${LIGHT}Bot Panel${NC}"
    echo -e " ${MB}[•10]${NC}•${LIGHT}Dashboard Menu${NC}"
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e "                ${WB}----- [ FITUR LAIN ] -----${NC}               "
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e " ${MB}Dashboard Marzban GUI${NC}   ${LIGHT}: https://$domain/dashboard${NC}"
    echo -e " ${MB}Port TLS Alternatif${NC}     ${LIGHT}: 8443, 2053, 2083, 2087, 2096${NC}"
    echo -e " ${MB}Port nTLS Alternatif${NC}    ${LIGHT}: 8080, 8880, 2052, 2082, 2095${NC}"
    echo -e " ${MB}Warp Wireproxy${NC}          ${LIGHT}:${NC} $WARP $WARP_STATUS"
    echo -e " ${MB}Timezone${NC}                ${LIGHT}: Asia/Jakarta (+7)${NC}"
    echo -e " ${MB}Fail2Ban${NC}                ${LIGHT}: $F2B${NC}"
    echo -e " ${MB}Firewall${NC}                ${LIGHT}: $UFW${NC}"
    echo -e " ${MB}IPv6${NC}                    ${LIGHT}: [OFF]${NC}"
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e "${CLIENT}${LIGHT}:${NC} ${clientname}"
    echo -e "${DURATION}${LIGHT}:${NC} ${RB}${certificate}${NC} Days"
    echo -e "${EXP}${LIGHT}:${NC} ${Exp2}"
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e "${RB}Jika kalian mengubah domain maka Akun yang yang sudah dibuat akan hilang, Jadi tolong hati-hati.${NC}"
}

# Fungsi untuk menangani input menu
handle_menu() {
    read -p " Select Menu :  " opt
    echo -e ""
    case $opt in
	1) clear ; vms ;;
        2) clear ; vls ;;
	3) clear ; trj ;;
	4) clear ; ssc ;;
        5) clear ; marzban-menu ;;
        6) clear ; menu-backup ;;
        7) clear ; system-menu ;;
        8) clear ; speedtest ; echo " " ; read -n 1 -s -r -p "Press any key to back on menu" ; show_menu ;;
        9) clear ; bot ;;
	10) clear ; profile ; echo " " ; read -n 1 -s -r -p "Press any key to back on menu" ; show_menu ;;
        *) echo -e "${LIGHT}Invalid input${NC}" ; sleep 1 ; show_menu ;;
    esac
}

# Tampilkan menu dan tangani input pengguna
while true; do
    show_menu
    handle_menu
done
