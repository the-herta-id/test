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

# Mengambil nilai domain dan token dari file
domain=$(cat /root/domain)
token=$(cat /root/token.json | jq -r .access_token)

# Meminta input pengguna
while true; do
    read -rp "Username: " -e user

    # Validasi panjang karakter
    if [[ ${#user} -lt 4 || ${#user} -gt 32 ]]; then
        echo "Username harus memiliki panjang minimal 4 karakter dan maksimal 32 karakter."
        continue
    fi

    # Validasi karakter tanpa spesial karakter
    if [[ ! "$user" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Username hanya dapat mengandung huruf, angka, dan underscore (_) tanpa karakter spesial."
        continue
    fi

    TOTAL_USERS=$(curl -s -X 'GET' \
        "https://${domain}/api/users?username=${user}" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${token}" \
        | jq -r '.total')

    if [[ ${TOTAL_USERS} == '1' ]]; then
        echo ""
        echo "Klien dengan username ${user} sudah terdaftar pada database, mohon gunakan username lain."
        exit 1
    fi

    # Jika semua validasi terpenuhi, keluar dari loop
    break
done


read -rp "Catatan user: " -e catatan
echo "Masa aktif"
echo "[biarkan kosong atau tekan saja enter jika tidak butuh masa aktif / AlwaysON]"
read -p "Expired (Hari): " masaaktif
echo "[biarkan kosong atau tekan saja enter jika ingin sett Unlimited Quota]"
read -rp "Quota (GB): " -e gb

if [ -n "$gb" ]; then
    limitq=$((gb * 1024**3))
    quota_text="${gb} GB"

# Menampilkan opsi reset data
echo "Pilih jenis siklus reset data:"
echo "1. Tanpa ada reset"
echo "2. Harian"
echo "3. Mingguan"
echo "4. Bulanan"
echo "5. Tahunan"

# Menerima input pilihan pengguna
read -p "Masukkan nomor pilihan Anda: " choice

# Memilih strategi reset berdasarkan pilihan pengguna
case $choice in
    1)
        reset_strategy="no_reset"
        ;;
    2)
        reset_strategy="day"
        ;;
    3)
        reset_strategy="week"
        ;;
    4)
        reset_strategy="month"
        ;;
    5)
        reset_strategy="year"
        ;;
    *)
        echo "Pilihan tidak valid."
        exit 1
        ;;
esac

else
    limitq=0
    quota_text="Unlimited"
    reset_strategy="no_reset"
fi

# Menggunakan variable pass untuk generate password
pass=$(openssl rand -base64 16)

if [ -n "$masaaktif" ]; then
    exp=$((masaaktif * 24 * 60 * 60))
    exp2=$(date -d "${masaaktif} days" +"%Y-%m-%d")
    exp3=$(date -d "+14 days" +"%Y-%m-%dT%H:%M:%S")
    text="${masaaktif} Hari"
    text2="Masa OnHold: 14 Hari [${exp3}]"

# Mengirimkan permintaan ke API
curl -X 'POST' \
  "https://${domain}/api/user" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer ${token}" \
  -H 'Content-Type: application/json' \
  -d '{
  "username": "'"${user}"'",
  "proxies": {
    "shadowsocks": {
      "password": "'"${pass}"'",
	  "method": "aes-128-gcm"
    }
  },
  "inbounds": {
    "shadowsocks": [
      "SHADOWSOCKS_OUTLINE"
    ]
  },
  "data_limit": '"${limitq}"',
  "data_limit_reset_strategy": "'"${reset_strategy}"'",
  "status": "on_hold",
  "note": "'"${catatan}"'",
  "on_hold_timeout": "'"${exp3}"'",
  "on_hold_expire_duration": '"${exp}"'
}' > /tmp/${user}_ss.json
else
    exp=0
    exp2="AlwaysON"
    exp3="AlwaysON"
    text="AlwaysON"
    text2="Tidak berlaku OnHOLD"

# Mengirimkan permintaan ke API
curl -X 'POST' \
  "https://${domain}/api/user" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer ${token}" \
  -H 'Content-Type: application/json' \
  -d '{
  "username": "'"${user}"'",
  "proxies": {
    "shadowsocks": {
      "password": "'"${pass}"'",
	  "method": "aes-128-gcm"
    }
  },
  "inbounds": {
    "shadowsocks": [
      "SHADOWSOCKS_OUTLINE"
    ]
  },
  "expire": '"${exp}"',
  "data_limit": '"${limitq}"',
  "data_limit_reset_strategy": "'"${reset_strategy}"'",
  "status": "active",
  "note": "'"${catatan}"'"
}' > /tmp/${user}_ss.json
fi
subs=$(cat /tmp/${user}_ss.json | jq -r .subscription_url)

tmp1=$(echo -n "aes-128-gcm:${pass}" | base64 -w0)
linkss1="ss://${tmp1}@${domain}:1080#%28${user}%29%20%5BShadowsocks%20-%20TCP%5D%20Outline"

echo "==--PROJECT RERECHAN--==
TERIMA KASIH TELAH MEMILIH LAYANAN VPN LINGVPN!
LINK URL/CONFIG UNTUK USER ${user^^} DENGAN KUOTA ${quota_text} dan MASA AKTIF ${text}
MOHON MELAKUKAN PERPANJANGAN VPN MAKSMIMAL 3 HARI SEBELUM TANGGAL EXPIRED SETIAP BULAN NYA!

DETAIL Keterangan ALPN (HARUS DI SETT!):
1.) Outline: h2, http/1.1

DETAIL Port Server (Pilih salah satu, Sesuaikan dengan bug masing masing):
1.) Outline : 1080

Config URL :

-==============================-

1.) Shadowsocks-Outline TCP/UDP
${linkss1}

-==============================-

Format Openclash : 

1.) Shadowsocks-Outline TCP/UDP
- name: SSOutline_${user}
  type: ss
  server: ${domain}
  port: 1080
  cipher: aes-128-gcm
  password: ${pass}
  udp: true

SELALU PATUHI PERATURAN SERVER DAN TERIMA KASIH SUDAH MEMILIH RerechanStore 🙏

CONTACT WA : https://wa.me/6283120684925
TELEGRAM CHANNEL : https://t.me/project_rerechan
TELEGRAM GROUP : https://t.me/RerechanStore" > "/var/www/html/oc-${user}.conf"
clear
echo -e "=======-XRAY/SHADOWSOCKS-OUTLINE======="
echo -e ""
echo -e "Remarks: ${user}"
echo -e "Domain: ${domain}"
echo -e "Quota: ${quota_text}"
# Replace values and specific reset strategies
  case "${reset_strategy}" in
    "no_reset") reset_strategy="Loss_doll";;
    "day") reset_strategy="Harian";;
    "week") reset_strategy="Mingguan";;
    "month") reset_strategy="Bulanan";;
    "year") reset_strategy="Tahunan";;
esac
echo -e "Reset Quota Strategy: ${reset_strategy}"
echo -e "================================="
echo -e "🔑 Port Outline: 1080"
echo -e "================================="
echo -e "password: ${pass}"
echo -e "================================="
echo -e "network: none"
echo -e "================================="
echo -e "alpn: h2, http/1.1"
echo -e "tls: none"
echo -e "allowInsecure: true"
echo -e "================================="
echo -e "Link config: https://${domain}/oc-${user}.conf"
echo -e "================================="
echo -e "Link Subscription : https://${domain}${subs}"
echo -e "================================="
echo -e "Masa Aktif: ${text}"
echo -e "${text2}"
rm -r /tmp/${user}_ss.json
# Tambahkan prompt sebelum keluar
read -n 1 -s -r -p "Press any key to exit..."