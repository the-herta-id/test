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

# Variables
domain=$(cat /root/domain)
token=$(jq -r .access_token < /root/token.json)
reset_strategy="no_reset"
kataacak=$(openssl rand -hex 4)

# Function to prompt user for input
prompt_user() {
  echo "$1"
  read -r $2
}

# Function to create VPN user based on protocol
create_vpn_user() {
  protocol=$1
  case $protocol in
    "trojan")
      username="${protocol}trial-${kataacak}"
      pass=$(openssl rand -base64 16)
      curl -X 'POST' \
        "https://${domain}/api/user" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${token}" \
        -H 'Content-Type: application/json' \
        -d '{
          "username": "'"${username}"'",
          "proxies": {
            "trojan": {
              "password": "'"${pass}"'"
            }
          },
          "inbounds": {
            "trojan": [
              "TROJAN_TCP",
              "TROJAN_WS",
              "TROJAN_WS_ANTIADS",
              "TROJAN_WS_ANTIPORN",
              "TROJAN_GRPC"
            ]
          },
          "expire": '"${exp}"',
          "data_limit": null,
          "data_limit_reset_strategy": "'"${reset_strategy}"'",
          "status": "active",
          "note": "'"${username}"'"
        }' > "/tmp/${protocol}trial-${kataacak}_${protocol}.json"
      ;;
    "vmess")
      username="${protocol}trial-${kataacak}"
      uuid=$(cat /proc/sys/kernel/random/uuid)
      curl -X 'POST' \
        "https://${domain}/api/user" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${token}" \
        -H 'Content-Type: application/json' \
        -d '{
          "username": "'"${username}"'",
          "proxies": {
            "vmess": {
              "id": "'"${uuid}"'"
            }
          },
          "inbounds": {
            "vmess": [
              "VMESS_TCP",
              "VMESS_WS",
              "VMESS_WS_ANTIADS",
              "VMESS_WS_ANTIPORN",
              "VMESS_GRPC"
            ]
          },
          "expire": '"${exp}"',
          "data_limit": null,
          "data_limit_reset_strategy": "'"${reset_strategy}"'",
          "status": "active",
          "note": "'"${username}"'"
        }' > "/tmp/${protocol}trial-${kataacak}_${protocol}.json"
      ;;
    "vless")
      username="${protocol}trial-${kataacak}"
      uuid=$(cat /proc/sys/kernel/random/uuid)
      curl -X 'POST' \
        "https://${domain}/api/user" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${token}" \
        -H 'Content-Type: application/json' \
        -d '{
          "username": "'"${username}"'",
          "proxies": {
            "vless": {
              "id": "'"${uuid}"'",
              "flow": "xtls-rprx-vision"
            }
          },
          "inbounds": {
            "vless": [
              "VLESS_REALITY_FALLBACK",
              "VLESS_REALITY_GRPC",
              "VLESS_WS",
              "VLESS_WS_ANTIADS",
              "VLESS_WS_ANTIPORN",
              "VLESS_GRPC"
            ]
          },
          "expire": '"${exp}"',
          "data_limit": null,
          "data_limit_reset_strategy": "'"${reset_strategy}"'",
          "status": "active",
          "note": "'"${username}"'"
        }' > "/tmp/${protocol}trial-${kataacak}_${protocol}.json"
      ;;
    "ss")
      username="${protocol}trial-${kataacak}"
      pass=$(openssl rand -base64 16)
      curl -X 'POST' \
        "https://${domain}/api/user" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${token}" \
        -H 'Content-Type: application/json' \
        -d '{
          "username": "'"${username}"'",
          "proxies": {
            "shadowsocks": {
              "password": "'"${pass}"'",
              "method": "aes-128-gcm"
            }
          },
          "inbounds": {
            "shadowsocks": [
              "SHADOWSOCKS_TCP",
              "SHADOWSOCKS_WS",
              "SHADOWSOCKS_WS_ANTIADS",
              "SHADOWSOCKS_WS_ANTIPORN",
              "SHADOWSOCKS_GRPC",
              "SHADOWSOCKS_OUTLINE"
            ]
          },
          "expire": '"${exp}"',
          "data_limit": null,
          "data_limit_reset_strategy": "'"${reset_strategy}"'",
          "status": "active",
          "note": "'"${username}"'"
        }' > "/tmp/${protocol}trial-${kataacak}_${protocol}.json"
      ;;
    *)
      echo "Unknown protocol"
      exit 1
      ;;
  esac
}

# Function to display VPN user details based on protocol
display_user_details() {
  protocol=$1
  username="${protocol}trial-${kataacak}"
  subs=$(jq -r .subscription_url "/tmp/${protocol}trial-${kataacak}_${protocol}.json")
  case $protocol in
    "trojan")
      clear
      echo -e "=======-XRAY/TROJAN======="
      echo -e ""
      echo -e "Remarks: ${username}"
      echo -e "Domain: ${domain}"
      echo -e "Quota: Unlimited"
      echo -e "Reset Quota Strategy: ${reset_strategy}"
      echo -e "================================="
      echo -e "🔑 Port TLS: 443, 8443, 8880"
      echo -e "🔑 Port nonTLS: 80, 2082, 2083, 3128, 8080"
      echo -e "================================="
      echo -e "Password: ${pass}"
      echo -e "================================="
      echo -e "Network: tcp/ws/grpc"
      echo -e "================================="
      echo -e "Path: "
      echo -e "a.) WS: /trojan atau /enter-your-custom-path/trojan"
      echo -e "b.) WS Antiads: /trojan-antiads"
      echo -e "c.) WS Anti Ads & porn: /trojan-antiporn"
      echo -e "d.) GRPC: trojan-service"
      echo -e "================================="
      echo -e "ALPN: "
      echo -e "a.) WS: http/1.1"
      echo -e "b.) GRPC: h2"
      echo -e "c.) TCP: h2"
      echo -e "================================="
      echo -e "TLS: "
      echo -e "a.) TCP/WS: true (tls), false (nontls)"
      echo -e "b.) GRPC: true"
      echo -e "AllowInsecure: true"
      echo -e "================================="
      echo -e "Link Subscription: https://${domain}${subs}"
      echo -e "================================="
      echo -e "Masa Aktif: ${human_readable_exp} [${expiry_minutes} Menit]" 
      ;;
    "vmess")
      clear
      echo -e "=======-XRAY/VMESS======="
      echo -e ""
      echo -e "Remarks: ${username}"
      echo -e "Domain: ${domain}"
      echo -e "Quota: Unlimited"
      echo -e "Reset Quota Strategy: ${reset_strategy}"
      echo -e "================================="
      echo -e "🔑 Port TLS: 443, 8443, 8880"
      echo -e "🔑 Port nonTLS: 80, 2082, 2083, 3128, 8080"
      echo -e "================================="
      echo -e "ID: ${uuid}"
      echo -e "AlterID: 0"
      echo -e "Security: auto"
      echo -e "================================="
      echo -e "Network: tcp/ws/grpc"
      echo -e "================================="
      echo -e "Path & ServiceName: "
      echo -e "a.) TCP TLS & NonTLS: /vmess-tcp"
      echo -e "b.) WS TLS & NonTLS: /vmess atau /enter-your-custom-path/vmess"
      echo -e "c.) WS Antiads TLS & NonTLS: /vmess-antiads"
      echo -e "d.) WS Anti Ads & porn: /vmess-antiporn"
      echo -e "e.) GRPC TLS: vmess-service"
      echo -e "================================="
      echo -e "ALPN: "
      echo -e "a.) WS/TCP: http/1.1"
      echo -e "b.) GRPC: h2"
      echo -e "================================="
      echo -e "TLS: "
      echo -e "a.) WS/TCP: true (tls), false (nontls)"
      echo -e "b.) GRPC: true"
      echo -e "AllowInsecure: true"
      echo -e "================================="
      echo -e "Link Subscription: https://${domain}${subs}"
      echo -e "================================="
      echo -e "Masa Aktif: ${human_readable_exp} [${expiry_minutes} Menit]" 
      ;;
    "vless")
      clear
      echo -e "=======-XRAY/VLESS======="
      echo -e ""
      echo -e "Remarks: ${username}"
      echo -e "Domain: ${domain}"
      echo -e "Quota: Unlimited"
      echo -e "Reset Quota Strategy: ${reset_strategy}"
      echo -e "================================="
      echo -e "🔑 Port TLS: 443, 8443, 8880"
      echo -e "🔑 Port nonTLS: 80, 2082, 2083, 3128, 8080"
      echo -e "================================="
      echo -e "ID: ${uuid}"
      echo -e "Flow: xtls-rprx-vision"
      echo -e "Encryption: none"
      echo -e "================================="
      echo -e "Network: tcp/ws/grpc"
      echo -e "================================="
      echo -e "Path & ServiceName: "
      echo -e "a.) REALITY TLS: /vless-real atau /enter-your-custom-path/vless-reality"
      echo -e "b.) REALITY Antiads: /vless-reality-antiads"
      echo -e "c.) REALITY Anti Ads & porn: /vless-reality-antiporn"
      echo -e "d.) GRPC TLS: vless-service"
      echo -e "e.) WS TLS & NonTLS: /vless"
      echo -e "================================="
      echo -e "ALPN: "
      echo -e "a.) WS/TCP: http/1.1"
      echo -e "b.) GRPC: h2"
      echo -e "================================="
      echo -e "TLS: "
      echo -e "a.) WS/TCP: true (tls), false (nontls)"
      echo -e "b.) GRPC: true"
      echo -e "AllowInsecure: true"
      echo -e "================================="
      echo -e "Link Subscription: https://${domain}${subs}"
      echo -e "================================="
      echo -e "Masa Aktif: ${human_readable_exp} [${expiry_minutes} Menit]" 
      ;;
    "ss")
      clear
      echo -e "=======-XRAY/SHADOWSOCKS======="
      echo -e ""
      echo -e "Remarks: ${username}"
      echo -e "Domain: ${domain}"
      echo -e "Quota: Unlimited"
      echo -e "Reset Quota Strategy: ${reset_strategy}"
      echo -e "================================="
      echo -e "🔑 Port TLS: 443, 8443, 8880"
      echo -e "🔑 Port nonTLS: 80, 2082, 2083, 3128, 8080"
      echo -e "================================="
      echo -e "Password: ${pass}"
      echo -e "Method: aes-128-gcm"
      echo -e "Network: tcp/ws/grpc"
      echo -e "================================="
      echo -e "Path: "
      echo -e "a.) TCP/WS: /ss atau /enter-your-custom-path/ss"
      echo -e "b.) WS Antiads: /ss-antiads"
      echo -e "c.) WS Anti Ads & porn: /ss-antiporn"
      echo -e "d.) GRPC: ss-service"
      echo -e "================================="
      echo -e "ALPN: "
      echo -e "a.) WS/TCP: http/1.1"
      echo -e "b.) GRPC: h2"
      echo -e "================================="
      echo -e "TLS: "
      echo -e "a.) WS/TCP: true (tls), false (nontls)"
      echo -e "b.) GRPC: true"
      echo -e "AllowInsecure: true"
      echo -e "================================="
      echo -e "Link Subscription: https://${domain}${subs}"
      echo -e "================================="
      echo -e "Masa Aktif: ${human_readable_exp} [${expiry_minutes} Menit]" 
      ;;
    *)
      echo "Unknown protocol"
      exit 1
      ;;
  esac
}

# Prompt user for input
prompt_user "Masukkan jenis protokol (trojan/vmess/vless/ss): " protocol

# Prompt user for custom expiration time in minutes
prompt_user "Masukkan waktu kedaluwarsa dalam menit: " expiry_minutes

# Set expiration time based on user input
exp=$(date -d "+${expiry_minutes} minutes" +%s)
human_readable_exp=$(date -d "@$exp" "+%Y-%m-%d %H:%M:%S")

# Create VPN user
create_vpn_user "$protocol"

# Display user details
display_user_details "$protocol"

# Create a script to delete the user after the specified time
delete_script="/usr/bin/hapus_trial_${username}.sh"
cat <<EOT > "$delete_script"
#!/bin/bash

token=\$(jq -r .access_token < /root/token.json)
curl -X 'DELETE' \
  "https://${domain}/api/user/${username}" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer \${token}"

# Remove the delete script itself
rm -f "$delete_script"

# Remove the JSON file
rm -f "/tmp/${protocol}trial-${kataacak}_${protocol}.json"
EOT

# Make the script executable
chmod +x "$delete_script"

# Schedule the delete script to run after the specified time
echo "bash $delete_script" | at now + ${expiry_minutes} minutes
# Tambahkan prompt sebelum keluar
read -n 1 -s -r -p "Press any key to exit..."