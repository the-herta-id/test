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


# Base config directory
CONFIG_DIR="/etc/cekip/config"
mkdir -p "$CONFIG_DIR"

# Function untuk menyimpan semua konfigurasi
save_settings() {
    # Pastikan direktori ada
    mkdir -p "$CONFIG_DIR"
    
    # Simpan semua pengaturan dalam satu file
    cat > "$CONFIG_DIR/settings.conf" << EOF
# Violation Settings
MAX_VIOLATIONS=$max_pelanggaran
VIOLATION_WINDOW=$window_pelanggaran_detik
PENALTY_TIME=$penalty_time_minutes
MAX_IPS=$max_ips

# Path Settings
VIOLATIONS_DIR="/etc/cekip/violations"
PENALTY_DIR="/etc/cekip/penalty"
LOG_DIR="/etc/cekip/logs"
EOF

    # Simpan konfigurasi Telegram jika belum ada
    if [[ ! -f "$CONFIG_DIR/telegram.conf" ]]; then
        cat > "$CONFIG_DIR/telegram.conf" << EOF
botToken=$botToken
groupId=$groupId
threadId=$threadId
EOF
    fi
}

# Function to set the limit IP configuration
set_limit_ip() {
    # Buat direktori config jika belum ada
    mkdir -p "$CONFIG_DIR"
    
    # Cek apakah konfigurasi Telegram sudah ada
    if [[ ! -f "$CONFIG_DIR/telegram.conf" ]]; then
        echo -e "\n${YB}Konfigurasi Telegram${NC}"
        echo -e "${WB}Silakan masukkan detail berikut:${NC}"
        read -rp "Masukkan Bot Token Telegram: " botToken
        read -rp "Masukkan Group ID (contoh: -100xxxx): " groupId
        read -rp "Masukkan Topic/Thread ID: " threadId
        
        # Validasi input
        if [[ -z "$botToken" || -z "$groupId" || -z "$threadId" ]]; then
            echo -e "${RB}Error: Semua field harus diisi${NC}"
            return 1
        fi
    else
        source "$CONFIG_DIR/telegram.conf"
    fi
    
    # Set maximum allowed IPs
    set_max_allowed_ips
    
    # Set violation settings
    set_violation_settings
    
    # Set penalty time
    set_penalty_time
    
    # Save all settings
    save_settings
    
    # Create required directories
    mkdir -p /etc/cekip/{violations,penalty,logs}
    chmod 755 /etc/cekip/{violations,penalty,logs}
    
    # Set systemd service
    set_systemd_service
}

# Function untuk mengatur systemd service
set_systemd_service() {
    if [ ! -f "/etc/systemd/system/cekip.service" ]; then
        cat > /etc/systemd/system/cekip.service << 'EOF'
[Unit]
Description=IP Monitor Service for Marzban
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/cekip
Restart=always
RestartSec=3
StandardOutput=append:/etc/cekip/logs/monitor.log
StandardError=append:/etc/cekip/logs/error.log

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        echo "Service cekip berhasil dibuat"
    fi

    if systemctl is-enabled cekip >/dev/null 2>&1; then
        echo "Service cekip sudah enabled"
    else
        systemctl enable cekip
        echo "Service cekip berhasil dienable"
    fi

    if systemctl is-active cekip >/dev/null 2>&1; then
        echo "Service cekip sudah berjalan"
    else
        systemctl start cekip
        echo "Service cekip berhasil distart"
    fi
}

# Function untuk mengatur pengaturan pelanggaran
set_violation_settings() {
    echo -e "\n=== Pengaturan Pelanggaran Multi IP ==="
    echo -n "Masukkan jumlah maksimal pelanggaran sebelum disable (default: 3): "
    read -r max_pelanggaran
    
    echo -n "Masukkan waktu window pelanggaran dalam menit (default: 10): "
    read -r window_pelanggaran

    # Validate input
    if [[ ! "$max_pelanggaran" =~ ^[0-9]+$ ]]; then
        max_pelanggaran=3
    fi
    
    if [[ ! "$window_pelanggaran" =~ ^[0-9]+$ ]]; then
        window_pelanggaran=10
    fi

    # Convert minutes to seconds for violation window
    window_pelanggaran_detik=$((window_pelanggaran * 60))

    echo "Pengaturan pelanggaran berhasil disimpan:"
    echo "- Maksimal pelanggaran: $max_pelanggaran kali"
    echo "- Dalam waktu: $window_pelanggaran menit"
}

# Function to set the maximum allowed IPs
set_max_allowed_ips() {
    echo -n "Masukkan jumlah maksimal IP yang diizinkan untuk setiap pengguna (default: 1): "
    read -r max_ips
    # Validasi input
    if [[ ! "$max_ips" =~ ^[0-9]+$ ]]; then
        max_ips=1
    fi
    echo "Max IP per user diatur ke: $max_ips"
}

# Fungsi untuk mengatur waktu penalti
set_penalty_time() {
    echo -n "Masukkan waktu penalti dalam menit (default: 1): "
    read -r penalty_time_minutes

    # Validasi input
    if [[ ! "$penalty_time_minutes" =~ ^[0-9]+$ ]]; then
        penalty_time_minutes=1
    fi

    echo "Waktu penalti diatur ke: $penalty_time_minutes menit"
}

# Function to disable limit IP
disable_limit_ip() {
    systemctl stop cekip
    systemctl disable cekip
    rm -rf /etc/cekip/logs
    rm -rf /etc/cekip/violations
    rm -rf /etc/cekip/penalty
    rm -f /etc/cekip/config/settings.conf
    echo "Limit IP disabled successfully."
}

# Function untuk membaca konfigurasi saat ini
show_current_config() {
    echo -e "\n${BB}————————————————————————————————————————${NC}"
    echo -e "${WB}         KONFIGURASI LIMIT IP           ${NC}"
    echo -e "${BB}————————————————————————————————————————${NC}"

    if [ -f "$CONFIG_DIR/settings.conf" ]; then
        source "$CONFIG_DIR/settings.conf"
        echo -e "${YB}Max IP per User${NC}: $MAX_IPS"
        echo -e "${YB}Max Pelanggaran${NC}: $MAX_VIOLATIONS kali"
        echo -e "${YB}Window Pelanggaran${NC}: $((VIOLATION_WINDOW/60)) menit"
        echo -e "${YB}Waktu Penalty${NC}: $PENALTY_TIME menit"
    else
        echo -e "${YB}Konfigurasi${NC}: Belum diatur"
    fi

    if systemctl is-active cekip >/dev/null 2>&1; then
        echo -e "${YB}Status Service${NC}: ${GB}Running${NC}"
    else
        echo -e "${YB}Status Service${NC}: ${RB}Stopped${NC}"
    fi
    
    echo -e "${BB}————————————————————————————————————————${NC}"
}

# Update main menu
echo -e " ${MB}[1]${NC}•${DEFBOLD}Set Limit IP"
echo -e " ${MB}[2]${NC}•${DEFBOLD}Disable Limit IP"
echo -e " ${MB}[3]${NC}•${DEFBOLD}Lihat Konfigurasi"
echo -e ""
echo -e " ${MB}[0]${NC}•${DEFBOLD}Back To Menu"
echo -e "${BB}—————————————————————————————————————————————————————————${NC}"
read -rp "Masukkan pilihan anda : " choice

case $choice in
    1)
        set_limit_ip
        ;;
    2)
        echo -e "\n${YB}Peringatan${NC}: Ini akan menghapus semua konfigurasi limit IP"
        read -rp "Apakah anda yakin? (y/n) : " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            disable_limit_ip
        fi
        ;;
    3)
        show_current_config
        ;;
    0)
        echo "Keluar..."
        menu
        ;;
    *)
        echo "Pilihan tidak valid"
        ;;
esac
read -n 1 -s -r -p "Tekan tombol apapun untuk kembali ke menu"
setlimit