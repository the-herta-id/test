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

# Menggunakan variable uuid untuk generate password
uuid=$(cat /proc/sys/kernel/random/uuid)

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
    "vmess": {
      "id": "'"${uuid}"'"
    }
  },
  "inbounds": {
    "vmess": [
      "VMESS_WS",
      "VMESS_WS_ANTIADS",
      "VMESS_WS_ANTIPORN"
    ]
  },
  "data_limit": '"${limitq}"',
  "data_limit_reset_strategy": "'"${reset_strategy}"'",
  "status": "on_hold",
  "note": "'"${catatan}"'",
  "on_hold_timeout": "'"${exp3}"'",
  "on_hold_expire_duration": '"${exp}"'
}' > /tmp/${user}_vmess.json
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
    "vmess": {
      "id": "'"${uuid}"'"
    }
  },
  "inbounds": {
    "vmess": [
      "VMESS_WS",
      "VMESS_WS_ANTIADS",
      "VMESS_WS_ANTIPORN"
    ]
  },
  "expire": '"${exp}"',
  "data_limit": '"${limitq}"',
  "data_limit_reset_strategy": "'"${reset_strategy}"'",
  "status": "active",
  "note": "'"${catatan}"'"
}' > /tmp/${user}_vmess.json
fi
subs=$(cat /tmp/${user}_vmess.json | jq -r .subscription_url)

# Link VMess
ws1=`cat<<EOF
      {
      "v": "2",
      "ps": "(${user}) [VMess - WS] TLS",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "",
      "tls": "tls"
}
EOF`
ws2=`cat<<EOF
      {
      "v": "2",
      "ps": "(${user}) [VMess - WS] nonTLS",
      "add": "${domain}",
      "port": "80",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "",
      "tls": "none"
}
EOF`

vmesslink3="vmess://$(echo $ws1 | base64 -w 0)"
vmesslink4="vmess://$(echo $ws2 | base64 -w 0)"

# Contoh Format Openclash
echo "==--RerechanStore PRESENTS--==
TERIMA KASIH TELAH MEMILIH LAYANAN VPN RerechanStore!
LINK URL/CONFIG UNTUK USER ${user^^} DENGAN KUOTA ${quota_text} dan MASA AKTIF ${text}
MOHON MELAKUKAN PERPANJANGAN VPN MAKSMIMAL 3 HARI SEBELUM TANGGAL EXPIRED SETIAP BULAN NYA!

DETAIL Keterangan ALPN (HARUS DI SETT!):
1.) WS: http/1.1

DETAIL Port Server (Pilih salah satu, Sesuaikan dengan bug masing masing):
1.) TLS : 443, 8443, 2053, 2083, 2087, 2096
2.) HTTP/nonTLS : 80, 8080, 8880, 2052, 2082, 2095

DETAIL AKUN lain lain, WebSocket, FLOW, serverName Reality dan serviceName GRPC:

🔑 VMess
a.) path WS: /vmess atau /enter-your-custom-path/vmess
b.) path WS Antiads: /vmess-antiads
c.) path WS Anti ADS&PORN: /vmess-antiporn

Config URL :

-==============================-

1.) VMess-WS TLS
${vmesslink3}

2.) VMess-WS nonTLS
${vmesslink4}

-==============================-

Format Openclash : 

1.) VMess-WS TLS
- name: VmessWS_${user}
  server: ${domain}
  port: 443
  type: vmess
  uuid:  ${uuid}
  alterId: 0
  cipher: auto
  tls: true
  skip-cert-verify: true
  servername: ${domain}
  alpn:
   - http/1.1
  network: ws
  ws-opts:
    path: /vmess # selain path ini ada path /vmess-antiads atau /vmess-antiporn
    headers:
      Host: ${domain}
  udp: true

2.) VMess-WS nonTLS
- name: VmessWS_${user}
  server: ${domain}
  port: 80
  type: vmess
  uuid:  ${uuid}
  alterId: 0
  cipher: auto
  tls: false
  skip-cert-verify: true
  servername: ${domain}
  alpn:
   - http/1.1
  network: ws
  ws-opts:
    path: /vmess # selain path ini ada path /vmess-antiads atau /vmess-antiporn
    headers:
      Host: ${domain}
  udp: true

SELALU PATUHI PERATURAN SERVER DAN TERIMA KASIH SUDAH MEMILIH RerechanStore 🙏

CONTACT WA : https://wa.me/6283120684925
TELEGRAM CHANNEL : https://t.me/project_rerechan
TELEGRAM GROUP : https://t.me/RerechanStore" > "/var/www/html/oc-${user}.conf"
clear
echo -e "=======-XRAY/VMESS-WS======="
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
echo -e "🔑 Port TLS: 443, 8443, 8880"
echo -e "🔑 Port nonTLS: 80, 2082, 2083, 3128, 8080"
echo -e "================================="
echo -e "id: ${uuid}"
echo -e "alterID: 0"
echo -e "security: auto"
echo -e "================================="
echo -e "network: ws"
echo -e "================================="
echo -e "path"
echo -e "a.) WS TLS & NonTLS: /vmess atau /enter-your-custom-path/vmess"
echo -e "b.) WS Antiads TLS & NonTLS: /vmess-antiads"
echo -e "c.) WS Antiporn TLS & NonTLS: /vmess-antiporn"
echo -e "================================="
echo -e "alpn: http/1.1"
echo -e "tls:"
echo -e "a.) WS/TCP: true (tls), false (nontls)"
echo -e "allowInsecure: true"
echo -e "================================="
echo -e "Link config: https://${domain}/oc-${user}.conf"
echo -e "================================="
echo -e "Link Subscription : https://${domain}${subs}"
echo -e "================================="
echo -e "Masa Aktif: ${text}"
echo -e "${text2}"
rm -r /tmp/${user}_vmess.json
# Tambahkan prompt sebelum keluar
read -n 1 -s -r -p "Press any key to exit..."