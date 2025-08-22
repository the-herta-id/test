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

# Fungsi untuk menampilkan menu
display_menu() {
    clear
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e "               ${WB}----- [ System Menu ] -----${NC}              "
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e " ${MB}[•1]${NC}•${LIGHT}About Script${NC}"
    echo -e " ${MB}[•2]${NC}•${LIGHT}Add Token untuk konfigurasi API${NC}"
    echo -e " ${MB}[•3]${NC}•${LIGHT}Benchmark kemampuan VPS${NC}"
    echo -e " ${MB}[•4]${NC}•${LIGHT}Check akses log Xray${NC}"
    echo -e " ${MB}[•5]${NC}•${LIGHT}Check akses log Nginx${NC}"
    echo -e " ${MB}[•6]${NC}•${LIGHT}Check error log Xray${NC}"
    echo -e " ${MB}[•7]${NC}•${LIGHT}Check Port Xray${NC}"
    echo -e " ${MB}[•8]${NC}•${LIGHT}Check Used Ram${NC}"
    echo -e " ${MB}[•9]${NC}•${LIGHT}Change Xray-core${NC}"
    echo -e " ${MB}[10]${NC}•${LIGHT}Change Domain${NC}"
    echo -e " ${MB}[11]${NC}•${LIGHT}Cert Acme.sh${NC}"
    echo -e " ${MB}[12]${NC}•${LIGHT}Informasi routing Xray${NC}"
    echo -e " ${MB}[13]${NC}•${LIGHT}Menu Routing Xray${NC}"
    echo -e " ${MB}[14]${NC}•${LIGHT}Uninstall Script${NC}"
    echo -e " ${MB}[15]${NC}•${LIGHT}Ganti Host Marzban/SNI${NC}"
    echo -e ""
    echo -e " ${MB}[•0]${NC}•${LIGHT}Back To Menu${NC}"
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"

    if [ "$Isadmin" = "ON" ]; then
        echo -e "${BB}—————————————————• ${WB}PANEL ROUTING VIP${NC}${BB} • —————————————————${BB}"
        echo -e " ${MB}[3110]${NC}•${LIGHT}Download Menu Routing Xray${NC}"
        echo -e " ${MB}[0409]${NC}•${LIGHT}Routing Xray Menu${NC}"
        dataroute="wget -q https://scvps.insomvpn.my.id/datarouting.sh && chmod +x datarouting.sh && ./datarouting.sh"
        ressee="routing2"
        echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    else
        dataroute="menu"
        ressee="menu"
    fi
}

while true; do
    display_menu
    read -p "Enter your choice: " menu_choice

    case $menu_choice in
        1) rerechan ;;
        2) buat_token ;;
        3) bench ;;
        4) ceklog ;;
        5) ceknginx ;;
        6) cekerror ;;
        7) service-port ;;
        8) ram ;;
        9) ganticore ;;
        10) changedomain ;;
        11) fix-ssl ;;
        12) seeroute ;;
        13) routing ;;
        14) hapus-script ;;
        15) gantihost ;;
        3110) eval $dataroute ;;
        0409) eval $ressee ;;
        0) break ;;
        *)
            echo "Pilihan tidak valid. Silakan coba lagi."
            ;;
    esac

    read -n 1 -s -r -p "Press any key to continue"
done

clear
