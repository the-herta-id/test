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

# Mengambil informasi domain dan token
domain=$(cat /root/domain)
token=$(cat /root/token.json | jq -r .access_token)



# Informasi Layanan
export RED='\033[0;31m';
export GREEN='\033[0;32m';
export YELLOW='\033[0;33m';
export BLUE='\033[0;34m';
export PURPLE='\033[0;35m';
export CYAN='\033[0;36m';
export LIGHT='\033[0;37m';
export NC='\033[0m';

export ERROR="[${RED}ERROR${NC}]";
export INFO="[${YELLOW}INFO${NC}]";
export OKEY="[${GREEN}OKEY${NC}]";
export PENDING="[${YELLOW}PENDING${NC}]";
export SEND="[${YELLOW}SEND${NC}]";
export RECEIVE="[${YELLOW}RECEIVE${NC}]";

# Versi Marzban
versimarzban=$(grep 'image: gozargah/marzban:' /opt/marzban/docker-compose.yml | awk -F: '{print $3}')
case "${versimarzban}" in
    "latest") versimarzban="Stable";;
    "dev") versimarzban="Beta";;
esac

# Status Docker
if [[ $(systemctl status docker | grep -w active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == 'active' ]]; then
    DOCKER="${GREEN}Okay${NC}";
else
    DOCKER="${RED}Not Okay${NC}";
fi

# Status Xray
if [[ $(netstat -ntlp | grep -i xray | grep -i :::443 | awk '{print $4}' | cut -d: -f4 | xargs | sed -e 's/ /, /g') == '443' ]]; then
    XRAY="${GREEN}Okay${NC}";
    MARZ_STATUS="SHARING PORT 443 MARZBAN IS SAFE FOR ALL"
else
    XRAY="${RED}Not Okay${NC}";
    MARZ_STATUS="THERE IS AN ERROR"
fi

# Status NGINX
if [[ $(netstat -ntlp | grep -i nginx | grep -i 0.0.0.0:8081 | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g') == '8081' ]]; then
    NGINX="${GREEN}Okay${NC}";
else
    NGINX="${RED}Not Okay${NC}";
fi

# Status UFW
if [[ $(systemctl status ufw | grep -w active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == 'active' ]]; then
    UFW="${GREEN}Okay${NC}";
else
    UFW="${RED}Not Okay${NC}";
fi

# Status MARZ
if [[ $(netstat -ntlp | grep -i :7879 | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g') == '7879' ]]; then
    MARZ="${GREEN}Okay${NC}";
else
    MARZ="${RED}Not Okay${NC}";
fi

# Fungsi untuk mendapatkan informasi sistem dari Marzban API
function get_marzban_info() {
    local marzban_api="https://${domain}/api/system"
    local marzban_info=$(curl -s -X 'GET' "$marzban_api" -H 'accept: application/json' -H "Authorization: Bearer $token")

    if [[ $? -eq 0 ]]; then
        # Parsing Marzban API response       
        mem_total=$(echo "$marzban_info" | jq -r '.mem_total')
        mem_used=$(echo "$marzban_info" | jq -r '.mem_used')
        cpu_cores=$(echo "$marzban_info" | jq -r '.cpu_cores')
        cpu_usage=$(echo "$marzban_info" | jq -r '.cpu_usage')
        total_user=$(echo "$marzban_info" | jq -r '.total_user')
        users_active=$(echo "$marzban_info" | jq -r '.users_active')
        incoming_bandwidth=$(echo "$marzban_info" | jq -r '.incoming_bandwidth')
        outgoing_bandwidth=$(echo "$marzban_info" | jq -r '.outgoing_bandwidth')
        incoming_bandwidth_speed=$(echo "$marzban_info" | jq -r '.incoming_bandwidth_speed')
        outgoing_bandwidth_speed=$(echo "$marzban_info" | jq -r '.outgoing_bandwidth_speed')

        # Konversi nilai ke format yang mudah dibaca
        mem_used_human=$(numfmt --to=iec-i --suffix=B "$mem_used")
        mem_total_human=$(numfmt --to=iec-i --suffix=B "$mem_total")
        incoming_bandwidth_human=$(numfmt --to=iec-i --suffix=B --format="%.2f" <<< "$incoming_bandwidth")
        outgoing_bandwidth_human=$(numfmt --to=iec-i --suffix=B --format="%.2f" <<< "$outgoing_bandwidth")
        incoming_bandwidth_speed_human=$(numfmt --to=iec-i --suffix=Bps --format="%.2f" <<< "$incoming_bandwidth_speed")
        outgoing_bandwidth_speed_human=$(numfmt --to=iec-i --suffix=Bps --format="%.2f" <<< "$outgoing_bandwidth_speed")
    else
        echo -e "${ERROR} Failed to fetch Marzban information."
        exit 1
    fi
}
# Penggunaan fungsi
get_marzban_info

# Fungsi untuk mendapatkan versi Xray Core
function get_xray_core_version() {
    xray_core_info=$(curl -s -X 'GET' \
        "https://${domain}/api/core" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${token}"
    )
    xray_core_version=$(echo "$xray_core_info" | jq -r '.version')

    echo "$xray_core_version"
}
# Dapatkan versi Xray Core
xray_core_version=$(get_xray_core_version)

function get_server_info() {
    # Get ISP info
    ISP=$(curl -s ipinfo.io/org)
    # Get server IP
    SERVER_IP=$(curl -s ipinfo.io/ip)
    # Get uptime
    uptime_sec=$(awk '{print $1}' /proc/uptime)
    uptime_days=$((${uptime_sec%.*}/86400))
    uptime_hours=$((${uptime_sec%.*}%86400/3600))
    uptime_minutes=$((${uptime_sec%.*}%3600/60))
}

get_server_info

# Informasi layanan
echo -e "${BB}—————————————————————————————————————————————————————${NC}"
echo -e "\E[44;1;39m              ⇱ Service Information ⇲                \E[0m"
echo -e "${BB}—————————————————————————————————————————————————————${NC}"
echo -e "${MB}❇️ Docker Container     ${NC}:$DOCKER"
echo -e "${MB}❇️ Xray Core            ${NC}:$XRAY"
echo -e "${MB}❇️ Nginx                ${NC}:$NGINX"
echo -e "${MB}❇️ Firewall             ${NC}:$UFW"
echo -e "${MB}❇️ Marzban Panel        ${NC}:$MARZ"
echo -e "${BB}—————————————————————————————————————————————————————${NC}"
echo -e "$MARZ_STATUS"
echo -e "${BB}—————————————————————————————————————————————————————${NC}"
echo -e "\E[44;1;39m            ⇱ Server Information ⇲                   \E[0m"
echo -e "${BB}—————————————————————————————————————————————————————${NC}"
echo -e "${MB}❇️ ISP Provider         ${NC}: ${LIGHT}$ISP${NC}"
echo -e "${MB}❇️ Server IP            ${NC}: ${LIGHT}$SERVER_IP${NC}"
echo -e "${MB}❇️ Uptime Server        ${NC}: ${LIGHT}$uptime_days Days $uptime_hours Hours $uptime_minutes Minutes${NC}"
echo -e "${BB}—————————————————————————————————————————————————————${NC}"
echo -e "\E[44;1;39m            ⇱ Marzban System Information ⇲           \E[0m"
echo -e "${BB}—————————————————————————————————————————————————————${NC}"
echo -e "${MB}❇️ Marzban Version          ${NC}: ${LIGHT}$versimarzban\e[0m${NC}"
echo -e "${MB}❇️ XrayCore Version         ${NC}: ${LIGHT}${xray_core_version}${NC}"
echo -e "${MB}❇️ Memory Usage             ${NC}: ${LIGHT}${mem_used_human}/${mem_total_human}${NC}"
echo -e "${MB}❇️ CPU Cores                ${NC}: ${LIGHT}${cpu_cores} cores${NC}"
echo -e "${MB}❇️ CPU Usage                ${NC}: ${LIGHT}${cpu_usage}%${NC}"
echo -e "${MB}❇️ Total Users              ${NC}: ${LIGHT}${users_active}/${total_user}${NC}"
echo -e "${MB}❇️ Inbound Bandwidth        ${NC}: ${LIGHT}${incoming_bandwidth_human}${NC}"
echo -e "${MB}❇️ Outbound Bandwidth       ${NC}: ${LIGHT}${outgoing_bandwidth_human}${NC}"
echo -e "${MB}❇️ Inbound Bandwidth Speed  ${NC}: ${LIGHT}${incoming_bandwidth_speed_human}${NC}"
echo -e "${MB}❇️ Outbound Bandwidth Speed ${NC}: ${LIGHT}${outgoing_bandwidth_speed_human}${NC}"
echo -e "${BB}—————————————————————————————————————————————————————${NC}"
echo -e "${INFO} Marzban API status  : ${OKEY} API Service AMAN.${NC}"
echo -e "${BB}—————————————————————————————————————————————————————${NC}"