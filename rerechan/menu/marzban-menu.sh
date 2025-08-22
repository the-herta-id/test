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

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'

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


# Function to display header
display_header() {
    clear
    echo -e "${BLUE}————————————————————————————————————————————————————————${NC}"
    echo -e "${BLUE}             ----- [ Marzban Menu ] -----${NC}"
    echo -e "${BLUE}————————————————————————————————————————————————————————${NC}"
}

# Function to display menu
display_menu() {
    display_header
    echo -e " ${GREEN}[1]${NC}•Marzban Start"
    echo -e " ${GREEN}[2]${NC}•Marzban Stop"
    echo -e " ${GREEN}[3]${NC}•Marzban Restart"
    echo -e " ${GREEN}[4]${NC}•Marzban Status"
    echo -e " ${GREEN}[5]${NC}•Marzban Logs"
    echo -e " ${GREEN}[6]${NC}•Marzban Update"
    echo -e " ${GREEN}[7]${NC}•Marzban Create Admin"
    echo -e " ${GREEN}[8]${NC}•Marzban Admin list"
    echo -e " ${GREEN}[9]${NC}•Marzban User list"
    echo -e ""
    echo -e " ${RED}[0]${NC}•Back To Menu"
    echo -e "${BLUE}————————————————————————————————————————————————————————${NC}"
    echo -e ""
}

# Function to execute Marzban commands
execute_marzban() {
    local command=$1
    local description=$2
    
    echo -e "${YELLOW}Executing: $description${NC}"
    echo -e "${BLUE}————————————————————————————————————————————————————————${NC}"
    
    # Execute the command
    if eval "$command"; then
        echo -e "${GREEN}✓ $description completed successfully${NC}"
    else
        echo -e "${RED}✗ $description failed${NC}"
    fi
    
    echo -e "${BLUE}————————————————————————————————————————————————————————${NC}"
    read -p "Press Enter to continue..."
}

# Function to handle Marzban logs with follow option
handle_logs() {
    display_header
    echo -e "${YELLOW}Marzban Logs Options:${NC}"
    echo -e " ${GREEN}[1]${NC}•View recent logs (last 50 lines)"
    echo -e " ${GREEN}[2]${NC}•Follow logs in real-time"
    echo -e " ${GREEN}[3]${NC}•View logs with timestamps"
    echo -e " ${RED}[0]${NC}•Back to main menu"
    echo -e "${BLUE}————————————————————————————————————————————————————————${NC}"
    echo -e ""
    
    read -p "Enter your choice: " log_choice
    
    case $log_choice in
        1)
            execute_marzban "docker-compose logs --tail=50" "Viewing recent Marzban logs"
            ;;
        2)
            echo -e "${YELLOW}Following Marzban logs (Ctrl+C to stop)...${NC}"
            docker-compose logs -f
            read -p "Press Enter to continue..."
            ;;
        3)
            execute_marzban "docker-compose logs --timestamps" "Viewing Marzban logs with timestamps"
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            sleep 1
            handle_logs
            ;;
    esac
}

# Function to handle user list with options
handle_user_list() {
    display_header
    echo -e "${YELLOW}User List Options:${NC}"
    echo -e " ${GREEN}[1]${NC}•Show all users"
    echo -e " ${GREEN}[2]${NC}•Show active users"
    echo -e " ${GREEN}[3]${NC}•Show users with usage statistics"
    echo -e " ${RED}[0]${NC}•Back to main menu"
    echo -e "${BLUE}————————————————————————————————————————————————————————${NC}"
    echo -e ""
    
    read -p "Enter your choice: " user_choice
    
    case $user_choice in
        1)
            execute_marzban "marzban cli user list" "Listing all users"
            ;;
        2)
            execute_marzban "marzban cli user list --status active" "Listing active users"
            ;;
        3)
            execute_marzban "marzban cli user list --stats" "Listing users with statistics"
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            sleep 1
            handle_user_list
            ;;
    esac
}

# Function to check if Docker and Marzban are installed
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker is not installed!${NC}"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}Docker Compose is not installed!${NC}"
        exit 1
    fi
}

# Main menu function
main_menu() {
    while true; do
        display_menu
        read -p "Enter your choice: " choice
        
        case $choice in
            1)
                execute_marzban "docker-compose up -d" "Starting Marzban"
                ;;
            2)
                execute_marzban "docker-compose down" "Stopping Marzban"
                ;;
            3)
                execute_marzban "docker-compose restart" "Restarting Marzban"
                ;;
            4)
                execute_marzban "docker-compose ps" "Checking Marzban status"
                ;;
            5)
                handle_logs
                ;;
            6)
                execute_marzban "docker-compose pull && docker-compose up -d" "Updating Marzban"
                ;;
            7)
                read -p "Enter admin username: " admin_user
                read -p "Enter admin password: " admin_pass
                execute_marzban "marzban cli admin create --username $admin_user --password $admin_pass" "Creating admin user"
                ;;
            8)
                execute_marzban "marzban cli admin list" "Listing admin users"
                ;;
            9)
                handle_user_list
                ;;
            0)
                echo -e "${GREEN}Returning to previous menu...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice! Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Main execution
check_dependencies
main_menu