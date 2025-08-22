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

# Mengatur warna teks

# Fungsi untuk mencetak header
print_header() {
  echo -e "${BB}————————————————————————————————————————————————————————${NC}"
  echo -e "            ${WB}----- [ User IP Analyzer ] -----${NC}            "
  echo -e "${BB}————————————————————————————————————————————————————————${NC}"
}

# Fungsi untuk mencetak garis
print_line() {
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
}

# Fungsi untuk mendapatkan jumlah log entri untuk pengguna
get_user_log_count() {
    local username="$1"
    local log_file="/var/lib/marzban/assets/access.log"

    # Mendapatkan jumlah log entri untuk pengguna yang ditentukan
    log_count=$(grep -a -c -E "$username" "$log_file")

    echo "$log_count"
}

# Fungsi untuk mendapatkan data log untuk pengguna
get_user_log_data() {
    local username="$1"
    local log_file="/var/lib/marzban/assets/access.log"

    # Mendapatkan jumlah log entri untuk pengguna
    log_count=$(get_user_log_count "$username")

    if [ "$log_count" -eq 0 ]; then
        datalog="No log data available for this user."
    else
        datalog="User appears in log \033[0;33m$log_count times.\033[0m"
    fi

    echo -e "$datalog"
}

# Fungsi untuk mengkonversi Online At API ke WIB dengan offset
convert_api_online_at_to_wib() {
    local api_time="$1"
    local offset_hours=7
    local wib_time

    # Tambahkan offset waktu langsung ke waktu API jika api_time tidak null
    if [ "$api_time" != "null" ]; then
        wib_time=$(date --date="${api_time} ${offset_hours} hours" +"%Y-%m-%d %H:%M:%S")
    else
        wib_time="null"
    fi

    echo "$wib_time"
}

# Mendapatkan domain dan token dari file
domain=$(cat /root/domain)
token=$(cat /root/token.json | jq -r .access_token)

# Fungsi untuk mendapatkan IP pengguna dari API dan mencocokkan dengan file log
get_user_ips() {
    local protocol="$1"
    local log_file="/var/lib/marzban/assets/access.log"

    # Counter untuk penomoran pengguna
    counter=1

    # Counter total IP yang terhubung
    total_ips=0

    # Mendapatkan semua username dan online_at dari API
    user_data=$(curl -sX GET "https://${domain}/api/users" -H "accept: application/json" -H "Authorization: Bearer ${token}")

    # Mengekstrak username dan online_at berdasarkan protokol
    usernames=$(echo "$user_data" | jq -r --arg protocol "$protocol" '.users[] | select(.proxies | has($protocol)) | .username')
    online_at_values=$(echo "$user_data" | jq -r --arg protocol "$protocol" '.users[] | select(.proxies | has($protocol)) | .online_at')

    # Menggabungkan username dan nilai online_at
    mapfile -t usernames_array < <(echo "$usernames")
    mapfile -t online_at_array < <(echo "$online_at_values")

    # Loop melalui setiap username dan menemukan IP yang terhubung
    for ((i = 0; i < ${#usernames_array[@]}; i++)); do
        account="${usernames_array[i]}"
        online_at="${online_at_array[i]}"

        # Mengkonversi Online At dari API ke WIB
        online_at_wib=$(convert_api_online_at_to_wib "$online_at")

        echo "$counter. User: $account (Protocol: $protocol)"

        if [ "$online_at_wib" == "null" ]; then
            echo "   No data available for this user."
        else
            echo -e "   Data login terakhir (WIB): \e[94m$online_at_wib\e[0m"

            # Mendapatkan IP pengguna dari file log
            connected_ips=$(grep -a -E "$account" "$log_file" | awk '{print $3}' | awk -F: '{print $1}' | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | sort -n -u)

            if [ -z "$connected_ips" ]; then
                echo "   No connected IPs for this user."
            else
                echo "   Connected IPs:"
                # Loop melalui setiap IP yang terhubung dan menambahkan penomoran
                ip_counter=1
                while read -r ip; do
                    echo "      $ip_counter. $ip"

                    # Memeriksa jika IP bukan alamat lokal (misalnya, 127.0.0.1)
                    if [[ $ip != "127.0.0.1" ]]; then
                        # Mendapatkan informasi ASN dan ISP menggunakan ipinfo.io
                        asn_isp_info=$(curl -s "http://ipinfo.io/$ip/org" | tr -d '"')

                        echo "         ASN/ISP: $asn_isp_info"
                    else
                        echo "         ASN/ISP: N/A (Local Address)"
                    fi

                    ((ip_counter++))
                done <<< "$connected_ips"

                # Menambah counter total_ips
                ((total_ips += ip_counter - 1))
            fi

            # Mendapatkan data log untuk pengguna
            datalog=$(get_user_log_data "$account")
            echo "   Log data pada user ini: $datalog"
        fi

        # Meningkatkan counter
        ((counter++))

        # Mencetak garis
        print_line
    done

    # Mencetak total IP yang terhubung
    echo "Total Connected IPs for $protocol: $total_ips"
}

# Menu utama
print_header
echo -e " ${MB}[1]${NC}• Check Trojan IPs"
echo -e " ${MB}[2]${NC}• Check VMess IPs"
echo -e " ${MB}[3]${NC}• Check VLess IPs"
echo -e " ${MB}[4]${NC}• Check ShadowSocks IPs"
echo -e ""
echo -e " ${MB}[0]${NC}• Back To Menu"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"  
read -rp "Enter your choice: " choice
case $choice in
    1)
        protocol="trojan"
        get_user_ips "$protocol"
        ;;
    2)
        protocol="vmess"
        get_user_ips "$protocol"
        ;;
    3)
        protocol="vless"
        get_user_ips "$protocol"
        ;;
    4)
        protocol="shadowsocks"
        get_user_ips "$protocol"
        ;;
    0)
        echo "Exiting..."
        menu 0
        ;;
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

read -n 1 -s -r -p "Press any key to back on menu"
ceklogin
