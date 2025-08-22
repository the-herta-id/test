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
domain=$(cat /root/domain)
token=$(cat /root/token.json | jq -r .access_token)
tanggal=$(date +"%m-%d-%Y")
waktu=$(date +"%T")

# Fungsi untuk mengecek dan menghapus akun yang telah kedaluwarsa
check_expired() {
  local api_url="https://${domain}/api/users?status=expired"

  # Ambil data pengguna yang sudah kadaluwarsa
  expired_users=$(curl -s -X 'GET' \
    "${api_url}" \
    -H 'accept: application/json' \
    -H "Authorization: Bearer ${token}")

  # Iterasi melalui setiap pengguna yang sudah kadaluwarsa
  echo "${expired_users}" | jq -c '.users[] | select(.status == "expired")' | while read -r user_info; do
    # Ambil informasi protokol dari setiap pengguna
    protocol=$(echo "${user_info}" | jq -r '.proxies | keys_unsorted[0]' | tr -d '\n' | tr -d ' ')

    # Ambil username dari setiap pengguna
    username=$(echo "${user_info}" | jq -r '.username' | tr -d '\n' | tr -d ' ')

    # Hapus akun dari server
    curl -X 'DELETE' \
      "https://${domain}/api/user/${username}" \
      -H 'accept: application/json' \
      -H "Authorization: Bearer ${token}" &> /dev/null

    # Hapus file konfigurasi
    rm -r "/var/www/html/oc-${username}.conf" &> /dev/null

    echo "Pada tanggal ${tanggal} pukul ${waktu}, Untuk user ${username} dengan protokol ${protocol} telah mencapai Expired" >> "/root/log-exp-${protocol}.txt"
  done
}

# Jalankan fungsi
check_expired
