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

# Variabel API
API_URL="https://${domain}/api/users"
TOKEN=$(cat /root/token.json | jq -r .access_token)

# Function to convert bytes to human-readable format
format_data() {
  awk '{split("B KB MB GB TB PB", v); s = 1; while ($1 >= 1024) {$1 /= 1024; s++} printf "%.2f %s", $1, v[s]}'
}

# Function to convert expiration timestamp to human-readable format
convert_expiration() {
  timestamp="${1}"
  if [ "${timestamp}" == "null" ]; then
    echo "Always ON"
  else
    date -d "@${timestamp}" '+%Y-%m-%d %H:%M:%S'
  fi
}

# Function to display detailed account information based on protocol
display_protocol_details() {
  user="$1"
  protocol="$2"
  used_traffic_human="$3"
  data_limit_human="$4"
  reset_strategy="$5"
  pass_or_id="$6"
  subs="$7"
  expires_at_human="$8"

# Convert protocol to uppercase
protocol_uppercase=$(echo "${protocol}" | awk '{print toupper($0)}')

  echo -e "=======-XRAY/${protocol_uppercase}======="
  echo -e ""
  echo -e "Remarks: ${user}"
  echo -e "Domain: ${domain}"
  echo -e "Quota: ${used_traffic_human}/${data_limit_human}"
  echo -e "Reset Quota Strategy: ${reset_strategy}"
  echo -e "================================="
  echo -e "🔑 Port TLS: 443, 8443, 8880"
  echo -e "🔑 Port nonTLS: 80, 2082, 2083, 3128, 8080"
  echo -e "================================="
  if [[ "$protocol" == "trojan" || "$protocol" == "shadowsocks" ]]; then
    echo -e "Password: ${pass_or_id}"
  elif [[ "$protocol" == "vless" || "$protocol" == "vmess" ]]; then
    echo -e "ID: ${pass_or_id}"
  fi
  echo -e "================================="
  echo -e "Link Subscription : https://${domain}${subs}"
  echo -e "================================="
  echo -e "Expired at : ${expires_at_human}"
}

# Fetch user data from the API
response=$(curl -s -X 'GET' \
  "${API_URL}" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer ${TOKEN}")

# Check if the API request was successful
if [ $? -ne 0 ]; then
  echo "Error fetching data from the API"
  exit 1
fi

# Check if the response is valid JSON
if ! jq '.' <<< "${response}" > /dev/null 2>&1; then
  echo "Invalid JSON response from the API"
  exit 1
fi


echo "————————————————————————————————————————————————————————————————————————————————"
echo "No. ║  Username  ║ Proto ║ Status  ║   Usage   ║   Limit   ║ Expires          "
echo "————————————————————————————————————————————————————————————————————————————————"

# Check if there are no users
if [ "$(jq -c '.users | length' <<< "${response}")" -eq 0 ]; then
  echo "Belum ada user yang dibuat disini"
  echo ""
else
  # Loop through the users and print the information
  count=1
  while IFS= read -r row; do
    username=$(jq -r '.username' <<< "${row}")
    status=$(jq -r '.status' <<< "${row}")
    used_traffic=$(jq -r '.used_traffic' <<< "${row}")
    lifetime_used_traffic=$(jq -r '.lifetime_used_traffic' <<< "${row}")
    data_limit=$(jq -r '.data_limit' <<< "${row}")
    reset_strategy=$(jq -r '.data_limit_reset_strategy' <<< "${row}")
    expires_at=$(jq -r '.expire' <<< "${row}")
    protocol=$(jq -r '.proxies | keys_unsorted[0]' <<< "${row}" | sed 's/shadowsocks/ss/')

    # Convert bytes to human-readable format
    used_traffic_human=$(echo "${used_traffic}" | format_data)
    lifetime_used_traffic_human=$(echo "${lifetime_used_traffic}" | format_data)

    # Check if data limit is 0.00 KB and replace with Unlimited
    if [ "${data_limit}" == "null" ]; then
      data_limit_human="Unlimited"
    else
      data_limit_human=$(echo "${data_limit}" | format_data)
    fi

    # Replace null values and specific reset strategies
    case "${reset_strategy}" in
      "no_reset") reset_strategy="none";;
      "day") reset_strategy="daily";;
      "week") reset_strategy="weekly";;
      "month") reset_strategy="monthly";;
      "year") reset_strategy="yearly";;
    esac

    expires_at_human=$(convert_expiration "${expires_at}")

    # Use a single printf statement for the separator line and data
    printf "%-3s ║ %-10s ║ %-5s ║ %-7s ║ %-7s ║ %-9s ║ %-16s\n" "${count}" "${username}" "${protocol}" "${status}" "${used_traffic_human}" "${data_limit_human}" "${expires_at_human}"
    count=$((count + 1))
  done <<< "$(jq -c '.users[]' <<< "${response}")"
fi


  # Display menu
  echo -e "${BB}————————————————————————————————————————————————————————${NC}"
  echo -e "            ${WB}----- [ Utilities Menu ] -----${NC}            "
  echo -e "${BB}————————————————————————————————————————————————————————${NC}"
  echo -e " ${MB}[1]${NC}•${LIGHT}Delete User"
  echo -e " ${MB}[2]${NC}•${LIGHT}Renew / Perpanjang Masa Aktif User"
  echo -e " ${MB}[3]${NC}•${LIGHT}Reset Usage Data User"
  echo -e " ${MB}[4]${NC}•${LIGHT}Display Detailed Account Information"
  echo -e " ${MB}[5]${NC}•${LIGHT}Cek Login User"
  echo -e " ${MB}[6]${NC}•${LIGHT}Setting Limit Ip"
  echo -e ""
  echo -e " ${MB}[0]${NC}•${LIGHT}Back To Menu"
  echo -e "${BB}————————————————————————————————————————————————————————${NC}"  
  read -p "Silahkan masukkan pilihan: " menu_choice

  case $menu_choice in
    1)
      # Delete User
      read -p "Pilih pengguna yang akan dihapus (Masukkan nomor yang sesuai): " user_number

      # Validate user input
      if [[ ! $user_number =~ ^[0-9]+$ ]]; then
        echo "Masukan tidak valid. Silakan masukkan nomor pilihan yang benar."
        continue
      fi

      # Check if the selected user number is valid
      if [ "$user_number" -lt 1 ] || [ "$user_number" -gt "$count" ]; then
        echo "Nomor pengguna tidak valid. Silakan masukkan nomor yang sesuai dengan daftar."
        continue
      fi

      # Get the selected user information
      selected_user=$(jq -c --argjson user_number "$user_number" '.users[$user_number - 1]' <<< "${response}")
      username_to_delete=$(jq -r '.username' <<< "${selected_user}")

      # Confirm deletion
      read -p "Anda yakin ingin menghapus pengguna ${username_to_delete}? (y/n): " confirmation
      if [ "$confirmation" == "y" ] || [ "$confirmation" == "Y" ]; then
        # Perform user deletion
        curl -s -X 'DELETE' \
        "https://${domain}/api/user/${username_to_delete}" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${TOKEN}" \
        > /dev/null

        echo "User ${username_to_delete} telah berhasil dihapus."
        rm -r /var/www/html/oc-${username_to_delete}.conf
      else
        echo "Operasi hapus user telah dibatalkan."
      fi

      ;;
  2)
# Renew / Perpanjang Masa Aktif User
read -p "Pilih pengguna yang akan diperpanjang masa aktifnya (Masukkan nomor yang sesuai): " user_number

# Validate user input
if [[ ! $user_number =~ ^[0-9]+$ ]]; then
    echo "Masukan tidak valid. Silakan masukkan nomor pilihan yang benar."
    exit 1
fi

# Check if the selected user number is valid
if [ "$user_number" -lt 1 ] || [ "$user_number" -gt "$count" ]; then
    echo "Nomor pengguna tidak valid. Silakan masukkan nomor yang sesuai dengan daftar."
    exit 1
fi

# Get the selected user information
selected_user=$(jq -c --argjson user_number "$user_number" '.users[$user_number - 1]' <<< "${response}")

# Ask for the renewal duration in days
read -p "Masukkan durasi perpanjangan masa aktif dalam hari: " renewal_days
echo ""
# Validate renewal days input
if [[ ! $renewal_days =~ ^[0-9]+$ ]] || [ "$renewal_days" -lt 1 ]; then
    echo "Durasi perpanjangan tidak valid. Silakan masukkan angka yang benar."
    exit 1
fi

# Calculate the new expiration timestamp by adding the renewal duration to the existing expiration
current_expiration_epoch=$(jq -r '.expire' <<< "${selected_user}")
new_expiration_epoch=$((current_expiration_epoch + (renewal_days * 86400)))

# Convert new expiration epoch to human-readable format
expires_at_human=$(date -d @"${new_expiration_epoch}" +"%Y-%m-%d %H:%M:%S")

# API call to renew user
username_to_renew=$(jq -r '.username' <<< "${selected_user}")
curl -s -X 'PUT' \
  "https://${domain}/api/user/${username_to_renew}" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer ${TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{
    "expire": '"${new_expiration_epoch}"'
  }' > /dev/null

# Output the result
echo "Masa aktif untuk ${username_to_renew} telah diperpanjang selama ${renewal_days} hari."
echo -e "${BB}——————————————————————————————————————————————————————${NC}"  
echo "Masa aktif yang baru untuk user ${username_to_renew} berakhir pada: ${expires_at_human}."
    read -n 1 -s -r -p "Press any key to back on menu"
	menu-akun
	;;
    3)
      # Reset Usage Data User
      read -p "Pilih pengguna yang akan di-reset data penggunaannya (Masukkan nomor yang sesuai): " user_number
      # Validate user input
      if [[ ! $user_number =~ ^[0-9]+$ ]]; then
        echo "Masukan tidak valid. Silakan masukkan nomor pilihan yang benar."
        continue
      fi

      # Check if the selected user number is valid
      if [ "$user_number" -lt 1 ] || [ "$user_number" -gt "$count" ]; then
        echo "Nomor pengguna tidak valid. Silakan masukkan nomor yang sesuai dengan daftar."
        continue
      fi

      # Get the selected user information
      selected_user=$(jq -c --argjson user_number "$user_number" '.users[$user_number - 1]' <<< "${response}")

      # API call to reset usage data
      username_to_reset=$(jq -r '.username' <<< "${selected_user}")
      curl -s -X 'POST' \
        "https://${domain}/api/user/${username_to_reset}/reset" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${TOKEN}" \
        -d ' ' > /dev/null
      echo "Data penggunaan untuk ${username_to_reset} telah di-reset."
      read -n 1 -s -r -p "Press any key to back on menu"
	  menu-akun
	  ;;
    4)
      # Display Detailed Account Information
      read -p "Pilih pengguna untuk menampilkan informasi detail (Masukkan nomor yang sesuai): " user_number
      # Validate user input
      if [[ ! $user_number =~ ^[0-9]+$ ]]; then
        echo "Masukan tidak valid. Silakan masukkan nomor pilihan yang benar."
        continue
      fi

      # Check if the selected user number is valid
      if [ "$user_number" -lt 1 ] || [ "$user_number" -gt "$count" ]; then
        echo "Nomor pengguna tidak valid. Silakan masukkan nomor yang sesuai dengan daftar."
        continue
      fi

      selected_user=$(jq -c --argjson user_number "$user_number" '.users[$user_number - 1]' <<< "${response}")

      # Extract relevant information for detailed display
      user=$(jq -r '.username' <<< "${selected_user}")
      protocol=$(jq -r '.proxies | keys_unsorted[0]' <<< "${selected_user}" | sed 's/shadowsocks/ss/')
      used_traffic=$(jq -r '.used_traffic' <<< "${selected_user}")
      data_limit=$(jq -r '.data_limit' <<< "${selected_user}")
      reset_strategy=$(jq -r '.data_limit_reset_strategy' <<< "${selected_user}")
      if [[ "$protocol" == "trojan" || "$protocol" == "shadowsocks" ]]; then
          pass_or_id=$(jq -r '.proxies."'$protocol'".password' <<< "${selected_user}")
      elif [[ "$protocol" == "vless" || "$protocol" == "vmess" ]]; then
          pass_or_id=$(jq -r '.proxies."'$protocol'".id' <<< "${selected_user}")
      fi
      subs=$(jq -r '.subscription_url' <<< "${selected_user}")
      expires_at_epoch=$(jq -r '.expire' <<< "${selected_user}")

      # Convert epoch timestamp to human-readable date
      expires_at_human=$(date -d "@$expires_at_epoch" +"%Y-%m-%d %H:%M:%S")

      # Convert bytes to human-readable format
      used_traffic_human=$(echo "${used_traffic}" | format_data)

      # Check if data limit is 0.00 KB and replace with Unlimited
      if [ "${data_limit}" == "null" ]; then
          data_limit_human="Unlimited"
      else
          data_limit_human=$(echo "${data_limit}" | format_data)
      fi

      # Replace null values and specific reset strategies
      case "${reset_strategy}" in
          "no_reset") reset_strategy="loss_doll";;
          "day") reset_strategy="harian";;
          "week") reset_strategy="mingguan";;
          "month") reset_strategy="bulanan";;
          "year") reset_strategy="tahunan";;
      esac

      # Call the function to display detailed information based on protocol
      display_protocol_details "$user" "$protocol" "$used_traffic_human" "$data_limit_human" "$reset_strategy" "$pass_or_id" "$subs" "$expires_at_human"
      ;;
    5) clear ; ceklogin ;;
    6) clear ; setlimit ;;
    0) clear ; menu ;;
    *)
      echo "Pilihan tidak valid. Silakan coba lagi."
      ;;
  esac
	  read -n 1 -s -r -p "Press any key to back on menu"
	  menu-akun