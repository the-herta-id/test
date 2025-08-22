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
sleep 30s # Kurangi sleep time dari 3m ke 30s

# Path to Xray access log file
log_file="/var/lib/marzban/assets/access.log"

# Cek file penting di awal
if [ ! -f "$log_file" ]; then
    echo "Error: $log_file not found"
    exit 1
fi

if [ ! -f "/var/lib/marzban/max_ips.conf" ]; then
    echo "Error: max_ips.conf not found"
    exit 1
fi

if [ ! -f "/var/lib/marzban/violation_settings.conf" ]; then
    echo "Error: violation_settings.conf not found"
    exit 1
fi

# Path to store logs for users exceeding the IP limit
log_folder="/etc/autokill/logs"

# API information
domain=$(cat /root/domain)
token=$(cat /root/token.json | jq -r .access_token)

# Load penalty_time from configuration file (in minutes)
penalty_time_minutes=$(cat "/var/lib/marzban/penalty_time.conf")

# Load violation settings
source "/var/lib/marzban/violation_settings.conf"

# Convert penalty_time to seconds
penalty_time_seconds=$((penalty_time_minutes * 60))

# Configuration bot token + chatid, load values
source "/etc/autokill/telegram_config.conf"

# Path to store penalty timestamp logs
penalty_log_folder="/etc/autokill/penalty_logs"

# Tambahkan pembuatan direktori jika belum ada
mkdir -p "$log_folder"
mkdir -p "$penalty_log_folder"
mkdir -p "/etc/autokill/violations"

# Tambahkan permission yang sesuai
chmod 755 "$log_folder"
chmod 755 "$penalty_log_folder"
chmod 755 "/etc/autokill/violations"

# Function untuk kirim pesan ke Telegram dengan topic
send_telegram_message() {
    local message="$1"
    curl -s "https://api.telegram.org/bot$botToken/sendMessage" \
        -d "chat_id=$groupId" \
        -d "message_thread_id=$threadId" \
        -d "text=$message" \
        -d "parse_mode=HTML" > /dev/null
}

check_violation() {
    local account=$1
    local protocol=$2
    local connected_ips=$3
    local current_time=$(date +%s)
    local violation_file="/etc/autokill/violations/${account}_violations.txt"
    local log_time_file="/etc/autokill/logs/${account}_violation_times.log"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking violations for $account"
    echo "Connected IPs for $account:"
    echo "$connected_ips"
    
    mkdir -p "/etc/autokill/violations"
    mkdir -p "/etc/autokill/logs"
    
    touch "$violation_file"
    touch "$log_time_file"
    
    if [ -s "$violation_file" ]; then
        last_violation=$(tail -n 1 "$violation_file")
        time_diff=$((current_time - last_violation))
        
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] User: $account, Time diff: $((time_diff/60)) menit" >> "$log_time_file"
        
        if [ "$time_diff" -lt "$penalty_time_seconds" ]; then
            echo "Masih dalam penalty time ($penalty_time_minutes menit)"
            return 1
        fi
    fi

    echo "$current_time" >> "$violation_file"
    violation_count=$(wc -l < "$violation_file")
    
    hidden_domain="***$(echo $domain | cut -d'.' -f2-)"

    if [ "$violation_count" -lt "$MAX_VIOLATIONS" ]; then
        MESSAGE="⚠️ PERINGATAN ke-$violation_count dari $MAX_VIOLATIONS
User: $account
Protocol: [$protocol]
Server: $hidden_domain
Server ISP: $vps_isp
Status: Terdeteksi Multi IP
Connected IPs: 
$connected_ips
Window Time: $((VIOLATION_WINDOW/60)) menit"
        
        send_telegram_message "$MESSAGE"
        return 1
        
    elif [ "$violation_count" -eq "$MAX_VIOLATIONS" ]; then
        MESSAGE="🚫 AKUN DINONAKTIFKAN
User: $account
Protocol: [$protocol]
Server: $hidden_domain
Server ISP: $vps_isp
Status: Melebihi Batas Peringatan ($MAX_VIOLATIONS kali)
Connected IPs:
$connected_ips
Penalty Time: ${penalty_time_minutes} Menit"
        
        send_telegram_message "$MESSAGE"
        rm -f "$violation_file"
        return 0
    fi
}

# Function to limit connections based on IP for a specific account type
limit_connections() {
    local protocol="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking $protocol connections..."

    # Load max_allowed_ips and penalty_time from configuration file
    source "/var/lib/marzban/max_ips.conf"

    # Counter for numbering users
    counter=1

    # Get all usernames for the specified protocol from API
    usernames=$(curl -sX GET "https://${domain}/api/users" -H "accept: application/json" -H "Authorization: Bearer ${token}" | jq -r --arg protocol "$protocol" '.users[] | select(.proxies | has($protocol)) | .username')

    # Loop through each username and find connected IPs
    for account in $usernames; do
        echo "$counter. User: $account"

        # Get user IPs from log file
        connected_ips=$(grep -E "$account" "$log_file" | awk '{print $3}' | awk -F: '{print $1}' | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v "127.0.0.1" | sort -n -u)

        if [ -z "$connected_ips" ]; then
            echo "No connected IPs for this user."
        else
            echo "Connected IPs:"
            # Loop through each connected IP and add numbering
            ip_counter=1
            while read -r ip; do
                echo "  $ip_counter. $ip"
                ((ip_counter++))
            done <<< "$connected_ips"

            # Check if the number of unique connected IPs exceeds the limit
            unique_ip_count=$(echo "$connected_ips" | wc -l)
            if [ "$unique_ip_count" -gt "$max_allowed_ips" ]; then
                # Check violations first
                check_violation "$account" "$protocol" "$connected_ips"
                if [ $? -eq 0 ]; then
                    # Jika return 0, berarti sudah mencapai batas peringatan
                    echo "Limiting connections for user $account. Connected IPs: $connected_ips"
                    # Disable user using API
                    curl -X 'PUT' \
                        "https://${domain}/api/user/${account}" \
                        -H 'accept: application/json' \
                        -H "Authorization: Bearer ${token}" \
                        -H 'Content-Type: application/json' \
                        -d '{"status": "disabled"}'  &> /dev/null

                        # Save penalty timestamp dan protocol
                        penalty_timestamp=$(date +"%s")
                        echo "$penalty_timestamp" > "$penalty_log_folder/${account}_penalty_timestamp.txt"
                        echo "$protocol" > "$penalty_log_folder/${account}_protocol.txt"
                    # Save log
                    echo "User $account exceeded violation limit. Connected IPs: $connected_ips. Disabled until penalty time is over." >> "$log_folder/user_limit_exceeded.log"
                fi
            fi
        fi

        # Increment the counter
        ((counter++))
    done
}

# Function to enable disabled users based on penalty time
enable_disabled_users() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking for users to re-enable..."
    
    # Cek file penalty untuk mendapatkan username yang di-disable oleh autokill
    for penalty_file in "$penalty_log_folder"/*_penalty_timestamp.txt; do
        [ -f "$penalty_file" ] || continue  # Skip jika tidak ada file
        
        # Ambil username dari nama file penalty
        username=$(basename "$penalty_file" _penalty_timestamp.txt)
        
        # Cek apakah penalty time sudah habis
        current_timestamp=$(date +%s)
        penalty_timestamp=$(cat "$penalty_file")
        penalty_duration=$((current_timestamp - penalty_timestamp))

        if [ "$penalty_duration" -ge "$penalty_time_seconds" ]; then
            # Enable user berdasarkan username dari file penalty
            response=$(curl -X 'PUT' \
                "https://${domain}/api/user/${username}" \
                -H 'accept: application/json' \
                -H "Authorization: Bearer ${token}" \
                -H 'Content-Type: application/json' \
                -d '{"status": "active"}' 2>&1)
            
            if [ $? -eq 0 ]; then
                protocol=$(cat "$penalty_log_folder/${username}_protocol.txt")
                # Remove penalty timestamp file
                rm "$penalty_file"
                rm "$penalty_log_folder/${username}_protocol.txt"
                
                # Reset violation file jika ada
                rm -f "/etc/autokill/violations/${username}_${protocol}_violations.txt"

                # Sensor subdomain
                hidden_domain="***$(echo $domain | cut -d'.' -f2-)"
                
                # Kirim pesan alert ke bot Telegram dengan informasi tambahan
                MESSAGE="✅ AKUN DIAKTIFKAN KEMBALI
User: $username
Protocol: [$protocol]
Server: $hidden_domain
Server ISP: $vps_isp
Status: Penalty Time Selesai
Durasi Penalty: ${penalty_time_minutes} Menit
Note: Peringatan telah direset (0/$MAX_VIOLATIONS)"

                send_telegram_message "$MESSAGE"

                echo "User $username penalty time is over. Re-enabled." >> "$log_folder/user_reenabled.log"
            else
                echo "Error enabling user $username: $response" >> "$log_folder/user_reenabled_gagal.log"
            fi
        fi
    done
}
# Function untuk membersihkan log
clear_logs() {
    LOG_ACCESS="/var/lib/marzban/assets/access.log"
    LOG_ERROR="/var/lib/marzban/assets/error.log"
    MAX_SIZE=5242880 # 5MB dalam bytes

    for log_file in "$LOG_ACCESS" "$LOG_ERROR"; do
        if [ -f "$log_file" ]; then
            # Dapatkan ukuran file dalam bytes
            size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file")
            
            # Format ukuran yang lebih manusiawi
            if [ "$size" -ge 1048576 ]; then
                # Jika lebih dari 1MB
                size_h=$(echo "scale=2; $size/1048576" | bc)
                echo "Checking $log_file"
                echo "Current size: ${size_h}MB"
            else
                # Jika kurang dari 1MB, tampilkan dalam KB
                size_h=$(echo "scale=2; $size/1024" | bc)
                echo "Checking $log_file"
                echo "Current size: ${size_h}KB"
            fi
            
            if [ "$size" -gt "$MAX_SIZE" ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] $log_file dibersihkan karena melebihi 5MB"
                truncate -s 0 "$log_file"
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log file dibersihkan karena melebihi 5MB" > "$log_file"
            else
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] $log_file masih dibawah 5MB"
            fi
            echo ""
        fi
    done
}

# Main menu
echo "Analyzing connected IPs for all protocols..."

# Clear logs if needed
clear_logs

# Limit connections for all protocols
limit_connections "trojan"
limit_connections "vmess"
limit_connections "vless"
limit_connections "shadowsocks"

# Enable disabled users based on penalty time
enable_disabled_users

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script execution complete."
