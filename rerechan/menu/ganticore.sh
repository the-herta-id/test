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

# Function to print a stylish header
print_header() {
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
	echo -e "           ${WB}----- [ Change Xray Core ] -----${NC}            "
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo ""
}

# Lokasi file .env
env_file="/opt/marzban/.env"

# Lokasi Xray executable
xray_executable="/var/lib/marzban/core/xray"

# Meminta pengguna memasukkan versi Xray yang diinginkan
clear
print_header
read -p "Masukkan versi Xray Core Official yang diinginkan (contoh format: 1.8.21): " version

# URL dari sumber Xray
xray_url="https://github.com/XTLS/Xray-core/releases/download/"
arch="Xray-linux-64.zip"
download_url="${xray_url}v${version}/${arch}"

# Lokasi tempat menyimpan Xray
xray_dir="/var/lib/marzban/core"

# Membuat direktori jika belum ada
mkdir -p $xray_dir

# Menampilkan pesan progres
echo -e "\nMemulai pembaruan Xray Core Official...\n"

# Mengunduh Xray dari URL yang diberikan
echo "Mengunduh Xray..."

# Menggunakan opsi --spider untuk menguji ketersediaan URL tanpa mengunduhnya
if wget --spider $download_url 2>&1 | grep -q '404 Not Found'; then
    echo "Error: Versi Xray tidak ditemukan atau URL tidak valid."
    exit 1
fi

# Melanjutkan mengunduh jika URL valid
wget $download_url -O $xray_dir/$arch

# Memeriksa apakah unduhan berhasil
if [ $? -ne 0 ]; then
    echo "Error: Gagal mengunduh Xray dari URL yang diberikan."
    exit 1
fi

# Mengekstrak arsip Xray
echo "Mengekstrak Xray..."
unzip -o $xray_dir/$arch -d $xray_dir

# Memberikan izin eksekusi jika diperlukan
chmod +x $xray_dir/xray

# Menampilkan pesan sukses
echo -e "\nPembaruan Xray Core Official berhasil!\n"

# Cek apakah variabel XRAY_EXECUTABLE_PATH sudah ada di file .env tanpa tanda pagar
if grep -q "^XRAY_EXECUTABLE_PATH=" "$env_file" && ! grep -q "^# XRAY_EXECUTABLE_PATH=" "$env_file"; then
    echo "Variabel XRAY_EXECUTABLE_PATH sudah ada di $env_file tanpa tanda pagar. Tidak perlu diubah."
else
    # Jika tidak ada atau sudah ada dengan tanda pagar, tambahkan variabel ke file .env
    echo "XRAY_EXECUTABLE_PATH=\"$xray_executable\"" >> "$env_file"
    echo "Variabel XRAY_EXECUTABLE_PATH telah ditambahkan ke $env_file."
fi

# Menampilkan pesan progres
echo -e "\nMemulai ulang layanan Marzban...\n"

# Restart layanan Marzban menggunakan Docker Compose
cd /opt/marzban
docker compose down
docker compose up -d
marzban logs

# Membersihkan file Xray yang diunduh
rm $xray_dir/$arch

# Menampilkan pesan sukses
echo -e "\nPergantian core Xray selesai.\n"
