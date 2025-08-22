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

# Clear various log files
echo "Clearing log files..."

# Clear .log files in /var/log/
data=(`find /var/log/ -name \*.log`);
for log in "${data[@]}"
do
echo "$log clear"
echo > $log
done

# Clear .err files in /var/log/
data=(`find /var/log/ -name \*.err`);
for log in "${data[@]}"
do
echo "$log clear"
echo > $log
done

# Clear mail.* files in /var/log/
data=(`find /var/log/ -name mail.*`);
for log in "${data[@]}"
do
echo "$log clear"
echo > $log
done

# Clear .log files in /var/lib/
data=(`find /var/lib/ -name \*.log`);
for log in "${data[@]}"
do
echo "$log clear"
echo > $log
done

# Clear .err files in /var/lib/
data=(`find /var/lib/ -name \*.err`);
for log in "${data[@]}"
do
echo "$log clear"
echo > $log
done

# Clear mail.* files in /var/lib/
data=(`find /var/lib/ -name mail.*`);
for log in "${data[@]}"
do
echo "$log clear"
echo > $log
done

# Clear specific system log files
echo > /var/log/syslog
echo "/var/log/syslog clear"

echo > /var/log/btmp
echo "/var/log/btmp clear"

echo > /var/log/messages
echo "/var/log/messages clear"

echo > /var/log/debug
echo "/var/log/debug clear"

# Clear additional common log files
echo > /var/log/auth.log
echo "/var/log/auth.log clear"

echo > /var/log/kern.log
echo "/var/log/kern.log clear"

echo > /var/log/faillog
echo "/var/log/faillog clear"

echo > /var/log/lastlog
echo "/var/log/lastlog clear"

echo > /var/log/wtmp
echo "/var/log/wtmp clear"

# Clear temporary files
echo > /tmp/logs
echo "/tmp/logs clear"

echo "Log clearing completed!"