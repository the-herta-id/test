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
# Pastikan argumen username dan durasi perpanjangan telah diberikan
if [ $# -lt 2 ]; then
    echo "Usage: $0 [username] [durasi_perpanjangan_hari]"
    exit 1
fi

# Variabel yang diperlukan
domain=$(cat /root/domain)
token=$(cat /root/token.json | jq -r .access_token)

# Mengambil username dan durasi perpanjangan dari argumen
username=$1
exp=$2

# API_URL harus ditempatkan setelah definisi variabel domain
API_URL="https://${domain}/api/user/${username}"

# Fetch user data from the API
response=$(curl -s -X 'GET' \
  "${API_URL}" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer ${token}")

# Periksa apakah username ada dalam respons (sesuaikan dengan struktur respons API Anda)
if [[ ! "${response}" =~ "\"${username}\"" ]]; then
    echo "Gagal renew user ${username}. Periksa kembali argumen Anda atau pastikan username sudah terdaftar pada database."
    exit 1
fi

# Ambil nilai expire dari respons JSON (sesuaikan dengan struktur respons API Anda)
current_expiration_epoch=$(jq -r ".expire" <<< "${response}")

# Hitung waktu expire yang baru
new_expiration_epoch=$((current_expiration_epoch + (exp * 86400)))

# API call untuk memperbarui waktu expire user
curl -s -X 'PUT' \
  "${API_URL}" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer ${token}" \
  -H 'Content-Type: application/json' \
  -d '{
    "proxies": {},
    "inbounds": {},
    "expire": '"${new_expiration_epoch}"'
  }' > /dev/null

# Periksa apakah permintaan berhasil
if [ $? -eq 0 ]; then
    clear
    echo "Masa aktif untuk ${username} telah berhasil diperpanjang selama ${exp} hari."
    echo "-=================================================================-"
    echo "Masa Aktif yang baru untuk user ${username}"

    # Format waktu baru ke dalam bentuk yang lebih bersahabat
    new_expiration_date=$(date -d "@${new_expiration_epoch}" +"%Y-%m-%d %H:%M:%S")
    echo "Expired pada: ${new_expiration_date}"
else
    echo "Gagal renew user ${username}. Periksa kembali argumen Anda atau pastikan username sudah terdaftar pada database."
    exit 1
fi
