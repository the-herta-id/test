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
     "trojan": {
      "password": "'"${uuid}"'"
    },
	 "vless": {
      "id": "'"${uuid}"'",
      "flow": "xtls-rprx-vision"
    },
	 "vmess": {
      "id": "'"${uuid}"'"
    },
	 "shadowsocks": {
      "password": "'"${uuid}"'",
	  "method": "aes-128-gcm"
    }
  },
  "data_limit": '"${limitq}"',
  "data_limit_reset_strategy": "'"${reset_strategy}"'",
  "status": "on_hold",
  "note": "'"${catatan}"'",
  "on_hold_timeout": "'"${exp3}"'",
  "on_hold_expire_duration": '"${exp}"'
}' > /tmp/${user}_all.json
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
     "trojan": {
      "password": "'"${uuid}"'"
    },
	 "vless": {
      "id": "'"${uuid}"'",
      "flow": "xtls-rprx-vision"
    },
	 "vmess": {
      "id": "'"${uuid}"'"
    },
	 "shadowsocks": {
      "password": "'"${uuid}"'",
	  "method": "aes-128-gcm"
    }
  },
  "expire": '"${exp}"',
  "data_limit": '"${limitq}"',
  "data_limit_reset_strategy": "'"${reset_strategy}"'",
  "status": "active",
  "note": "'"${catatan}"'"
}' > /tmp/${user}_all.json
fi
subs=$(cat /tmp/${user}_all.json | jq -r .subscription_url)

#URL Protocol

#trojan
trojanlink1="trojan://${uuid}@${domain}:443?security=tls&type=tcp&host=&headerType=&path=&sni=${domain}&fp=&alpn=h2#%20%28${user}%29%20%5BTrojan%20-%20TCP%5D%20TLS"
trojanlink2="trojan://${uuid}@${domain}:443?security=tls&type=ws&host=domain&headerType=&path=%2Ftrojan&sni=domain&fp=&alpn=http%2F1.1#%20%28${user}%29%20%5BTrojan%20-%20WS%5D%20TLS"
trojanlink3="trojan://${uuid}@${domain}:80?security=none&type=ws&host=domain&headerType=&path=%2Ftrojan#%20%28${user}%29%20%5BTrojan%20-%20WS%5D%20nonTLS"
trojanlink4="trojan://${uuid}@${domain}:443?security=tls&type=grpc&host=&headerType=&serviceName=trojan-service&sni=${domain}&fp=&alpn=h2#%20%28${user}%29%20%5BTrojan%20-%20GRPC%5D%20TLS"
trojanlink5="trojan://${pass}@${domain}:443?security=tls&type=httpupgrade&host=${domain}&headerType=&path=%2Ftrojan-http&sni=${domain}&fp=&alpn=http%2F1.1#%28${user}%29%20%5BTrojan%20-%20HTTPUpgrade%5D%20TLS"
trojanlink6="trojan://${pass}@${domain}:80?security=none&type=httpupgrade&host=${domain}&headerType=&path=%2Ftrojan-http#%28${user}%29%20%5BTrojan%20-%20HTTPUpgrade%5D%20nonTLS"

#vless
vlesslink0="vless://${uuid}@${domain}:443?security=reality&type=tcp&host=&headerType=&path=&sni=teams.microsoft.com&fp=chrome&pbk=M1PTcxApfZYmc8mbUUdMncKejBxZbjEwHGEl68zjlWU&sid=87ae7e1887f2bd1e&spx=#%28${user}%29%20%5BVLESS%20-%20tcp%5D%20REALITY"
vlesslink1="vless://${uuid}@${domain}:443?security=tls&type=ws&host=${domain}&headerType=&path=%2Fvless&sni=&fp=&alpn=http%2F1.1#%28${user}%29%20%5BVLESS%20-%20WS%5D%20TLS"
vlesslink2="vless://${uuid}@${domain}:80?security=none&type=ws&host=${domain}&headerType=&path=%2Fvless#%28${user}%29%20%5BVLESS%20-%20WS%5D%20nonTLS"
vlesslink3="vless://${uuid}@${domain}:443?security=tls&type=grpc&host=${domain}&headerType=&serviceName=vless-service&sni=${domain}&fp=&alpn=h2#%28${user}%29%20%5BVLESS%20-%20GRPC%5D%20TLS"
vlesslink4="vless://${uuid}@${domain}:443?security=reality&type=grpc&host=&headerType=serviceName=vless-reality-service&sni=teams.microsoft.com&fp=chrome&pbk=M1PTcxApfZYmc8mbUUdMncKejBxZbjEwHGEl68zjlWU&sid=87ae7e1887f2bd1e&spx=#%28${user}%29%20%5BVLESS%20-%20gRPC%5D%20REALITY"
trojanlink5="trojan://${pass}@${domain}:443?security=tls&type=httpupgrade&host=${domain}&headerType=&path=%2Ftrojan-http&sni=${domain}&fp=&alpn=http%2F1.1#%28${user}%29%20%5BTrojan%20-%20HTTPUpgrade%5D%20TLS"
trojanlink6="trojan://${pass}@${domain}:80?security=none&type=httpupgrade&host=${domain}&headerType=&path=%2Ftrojan-http#%28${user}%29%20%5BTrojan%20-%20HTTPUpgrade%5D%20nonTLS"

#ss
tmp1=$(echo -n "aes-128-gcm:${uuid}" | base64 -w0)
linkss1="ss://${tmp1}@${domain}:1080#%20%28${user}%29%20%5BShadowsocks%20-%20TCP%5D%20Outline"
linkss2="ss://${tmp1}@${domain}:443?path=%2Fshadowsocks&security=tls&host=domain&type=ws&sni=${domain}#%20%28${user}%29%20%5BShadowsocks%20-%20WS%5D%20TLS"
linkss3="ss://${tmp1}@${domain}:80?path=%2Fshadowsocks&security=&host=domain&type=ws#%20%28${user}%29%20%5BShadowsocks%20-%20WS%5D%20nonTLS"
linkss4="ss://${tmp1}@${domain}:443?path=mode=gun&security=tls&type=grpc&serviceName=shadowsocks-service#%20%28${user}%29%20%5BShadowsocks%20-%20GRPC%5D%20TLS"

#vmess
tls=`cat<<EOF
      {
      "v": "2",
      "ps": "(${user}) [VMess - WS] TLS",
      "add": "domain",
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
none=`cat<<EOF
      {
      "v": "2",
      "ps": "(${user}) [VMess - WS] nonTLS",
      "add": "domain",
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
grpc=`cat<<EOF
 {
      "v": "2",
      "ps": "(${user}) [VMess - GRPC] TLS",
      "add": "domain",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "grpc",
      "path": "vmess-service",
      "type": "gun",
      "host": "",
      "tls": "tls"
}
EOF`
tcp=`cat<<EOF
      {
      "v": "2",
      "ps": "(${user}) [VMess - TCP] TLS",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "tcp",
      "path": "/vmess-tcp",
      "type": "http",
      "host": "",
      "tls": "tls"
}
EOF`
tcpnon=`cat<<EOF
      {
      "v": "2",
      "ps": "(${user}) [VMess - TCP] nonTLS",
      "add": "${domain}",
      "port": "80",
      "id": "${uuid}",
      "aid": "0",
      "net": "tcp",
      "path": "/vmess-tcp",
      "type": "http",
      "host": "",
      "tls": "none"
}
EOF`
hutls=`cat<<EOF
 {
      "v": "2",
      "ps": "(${user}) [VMess - HTTP Upgrade] TLS",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "httpugrade",
      "path": "/vmess-http",
      "type": "none",
      "host": "",
      "tls": "tls"
}
EOF`
huntls=`cat<<EOF
 {
      "v": "2",
      "ps": "(${user}) [VMess - HTTP Upgrade] nTLS",
      "add": "${domain}",
      "port": "80",
      "id": "${uuid}",
      "aid": "0",
      "net": "httpugrade",
      "path": "/vmess-http",
      "type": "none",
      "host": "",
      "tls": "none"
}
EOF`
vmesslink1="vmess://$(echo $tls | base64 -w 0)"
vmesslink2="vmess://$(echo $none | base64 -w 0)"
vmesslink3="vmess://$(echo $grpc | base64 -w 0)"
vmesslink4="vmess://$(echo $tcp | base64 -w 0)"
vmesslink5="vmess://$(echo $tcpnon | base64 -w 0)"
vmesslink6="vmess://$(echo $hutls | base64 -w 0)"
vmesslink7="vmess://$(echo $huntls | base64 -w 0)"

echo "==--RerechanStore PRESENTS--==
TERIMA KASIH TELAH MEMILIH LAYANAN VPN RerechanStore!
LINK URL/CONFIG UNTUK USER ${user^^} DENGAN KUOTA ${quota_text} dan MASA AKTIF ${text}
MOHON MELAKUKAN PERPANJANGAN VPN MAKSMIMAL 3 HARI SEBELUM TANGGAL EXPIRED SETIAP BULAN NYA!

DETAIL Keterangan ALPN (HARUS DI SETT!):
1.) TCP: h2, http/1.1
2.) WS/HU: http/1.1
3.) GRPC: h2

DETAIL Port Server (Pilih salah satu, Sesuaikan dengan bug masing masing):
1.) TLS : 443, 8443, 2053, 2083, 2087, 2096
2.) HTTP/nonTLS : 80, 8080, 8880, 2052, 2082, 2095
3.) Outline : 1080

DETAIL AKUN lain lain, WebSocket, FLOW dan SERVICENAME GRPC:

🔑 Trojan 
a.) path WS: /trojan atau /enter-your-custom-path/trojan
b.) path WS Antiads: /trojan-antiads
c.) path WS Anti ADS&PORN: /trojan-antiporn
d.) serviceName GRPC: trojan-service
e.) path HTTP Upgrade: /trojan-http

🔑 VMess
a.) path WS: /vmess atau /enter-your-custom-path/vmess
b.) path TCP Header: /vmess-tcp
c.) path WS Antiads: /vmess-antiads
d.) path WS Anti ADS&PORN: /vmess-antiporn
e.) serviceName GRPC: vmess-service
f.) path HTTP Upgrade: /vmess-http

🔑 VLess
a.) Flow TCP & GRPC Reality: xtls-rprx-vision
b.) path WS: /vless atau /enter-your-custom-path/vless
c.) path WS Antiads: /vless-antiads
d.) path WS Anti ADS&PORN: /vless-antiporn
e.) serviceName GRPC: vless-service
f.) serviceName GRPC Reality: vless-reality-service
g.) path HTTP Upgrade: /vless-http

🔑 ShadowSocks 
a.) path WS: /shadowsocks atau /enter-your-custom-path/shadowsocks
b.) path TCP Header: /ss-tcp
c.) path WS Antiads: /shadowsocks-antiads
d.) path WS Anti ADS&PORN: /shadowsocks-antiporn
e.) serviceName GRPC: shadowsocks-service

🔑 serverNames VLess Reality yang dapat dipakai
a.) static-web.prod.vidiocdn.com
b.) teams.microsoft.com
c.) sb.scorecardresearch.com
d.) www.spotify.com
e.) graph.instagram.com
f.) sogood.linefriends.com
g.) shopee.co.id
h.) payment.id.shopee.kr
i.) shopee.sg
j.) quiz.vidio.com
k.) zendesk1.garena.com
l.) www.sushiroll.co.id
m.) r.koubei.com

Config URL :

-==============================-
1.) Trojan-TCP TLS 
${trojanlink1}

2.) Trojan-WS TLS 
${trojanlink2}

3.) Trojan-WS nonTLS 
${trojanlink3}

4.) Trojan-GRPC TLS 
${trojanlink4}

5.) Trojan-HUpgrade TLS
${trojanlink5}

6.) Trojan-HUpgrade nonTLS
${trojanlink6}

7.) VLess-TCP REALITY TLS
${vlesslink0}

8.) VLess-WS TLS 
${vlesslink1}

9.) VLess-WS nonTLS 
${vlesslink2}

10.) VLess-GRPC TLS 
${vlesslink3}

11.) VLess-GRPC REALITY TLS 
${vlesslink4}

12.) VLess-HU TLS 
${vlesslink5}

13.) VLess-HU nonTLS 
${vlesslink6}

14.) VMess-WS TLS
${vmesslink1}

15.) VMess-WS nonTLS
${vmesslink2}

16.) VMess-GRPC TLS 
${vmesslink3}

17.) VMess-HU TLS
${vmesslink6}

18.) VMess-HU nonTLS
${vmesslink7}

19.) Shadowsocks-Outline TCP/UDP
${linkss1}

20.) Shadowsocks-WS TLS 
${linkss2}

21.) Shadowsocks-WS nonTLS 
${linkss3}

22.) Shadowsocks-GRPC TLS 
${linkss4}

-==============================-

Format Openclash : 

1.) Trojan-TCP TLS 
- name: TrojanTCP_${user}
  type: trojan
  server: ${domain}
  port: 443
  password: ${uuid}
  udp: true
  sni: ${domain}
  alpn:
   - h2
  skip-cert-verify: true

2.) Trojan-WS TLS
- name: TrojanWS_${user}
  type: trojan
  server: ${domain}
  port: 443
  password: ${uuid}
  udp: true
  sni: ${domain}
  alpn:
  - http/1.1
  skip-cert-verify: true
  network: ws
  ws-opts:
    path: "/trojan" # selain path ini ada /trojan-antiads atau /trojan-antiporn 

3.) Trojan-GRPC TLS
- name: TrojanGRPC_${user}
  type: trojan
  server: ${domain}
  port: 443
  password: ${uuid}
  udp: true
  sni: ${domain}
  alpn:
   - h2
  skip-cert-verify: true
  network: grpc
  grpc-opts:
    grpc-service-name: trojan-service

4.) Trojan-HU TLS
- name: TrojanHU_${user}
  type: trojan
  server: ${domain}
  port: 443
  password: ${pass}
  client-fingerprint: chrome
  udp: true
  sni: ${domain}
  alpn:
  - http/1.1
  skip-cert-verify: true
  network: ws
  ws-opts:
   path: "/trojan-http"
   headers:
     Host: ${domain}
   v2ray-http-upgrade: true
   v2ray-http-upgrade-fast-open: false
	
5.) VMess-WS TLS
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

6.) VMess-WS nonTLS
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

7.) VMess-GRPC TLS 
- name: VmessGRPC_${user}
  type: vmess
  server: ${domain}
  port: 443
  uuid: ${uuid}
  alterId: 0
  cipher: auto
  udp: true
  network: grpc
  tls: true
  servername: ${domain}
  alpn:
   - h2
  skip-cert-verify: true
  grpc-opts:
    grpc-service-name: vmess-service

8.) VMess-HU TLS
- name: VMessHU_${user}
  type: vmess
  server: ${domain}
  port: 443
  uuid: ${uuid}
  alterId: 0
  cipher: auto
  udp: true
  tls: true
  client-fingerprint: chrome
  skip-cert-verify: true
  servername: ${domain}
  alpn:
  - http/1.1
  network: ws
  ws-opts:
   path: "/vmess-http"
   headers:
     Host: ${domain}
   v2ray-http-upgrade: true
   v2ray-http-upgrade-fast-open: false

9.) VMess-HU nonTLS
- name: VMessHU_${user}
  type: vmess
  server: ${domain}
  port: 80
  uuid: ${uuid}
  alterId: 0
  cipher: auto
  udp: true
  tls: false
  client-fingerprint: chrome
  skip-cert-verify: true
  alpn:
  - http/1.1
  network: ws
  ws-opts:
   path: "/vmess-http"
   headers:
     Host: ${domain}
   v2ray-http-upgrade: true
   v2ray-http-upgrade-fast-open: false
	
10.) VLess-TCP REALITY TLS 
- name: VlessReality_${user}
  type: vless
  server: ${domain}
  port: 443
  uuid: ${uuid}
  network: tcp
  tls: true
  udp: true
  flow: xtls-rprx-vision
  servername: static-web.prod.vidiocdn.com
  alpn:
   - h2
   - http/1.1
  reality-opts:
    public-key: M1PTcxApfZYmc8mbUUdMncKejBxZbjEwHGEl68zjlWU
    short-id: 87ae7e1887f2bd1e
  client-fingerprint: chrome

11.) VLess-GRPC REALITY TLS
- name: VLessRGRPC_${user}
  type: vless
  server: ${domain}
  port: 443
  uuid: ${uuid}
  udp: true
  xudp: true
  skip-cert-verify: true
  tls: true
  client-fingerprint: chrome
  servername: www.spotify.com
  network: grpc
  grpc-opts:
    grpc-service-name: vless-reality-service
  reality-opts:
    public-key: M1PTcxApfZYmc8mbUUdMncKejBxZbjEwHGEl68zjlWU
    short-id: 87ae7e1887f2bd1e
  ip-version: dual
  tfo: false
  smux:
    enabled: false

12.) VLess-WS TLS 
- name: VlessWS_${user}
  type: vless
  server: ${domain}
  port: 443
  uuid: ${uuid}
  udp: true
  tls: true
  network: ws
  client-fingerprint: chrome
  servername: ${domain}
  alpn:
   - http/1.1
  skip-cert-verify: true
  ws-opts:
    path: "/vless" # selain path ini ada /vless-antiads atau /vless-antiporn 
    headers:
      Host: ${domain}

13.) VLess-WS nonTLS
- name: VlessWS_${user}
  type: vless
  server: ${domain}
  port: 80
  uuid: ${uuid}
  udp: true
  tls: false
  network: ws
  client-fingerprint: chrome
  alpn:
   - http/1.1
  skip-cert-verify: true
  ws-opts:
    path: "/vless" # selain path ini ada /vless-antiads atau /vless-antiporn
    headers:
      Host: ${domain}

14.) VLess-GRPC TLS
- name: VlessGRPC_${user}
  server: ${domain}
  port: 443
  type: vless
  uuid: ${uuid}
  network: grpc
  udp: true
  tls: true
  servername: example.com
  alpn:
   - h2
  skip-cert-verify: true
  grpc-opts:
    grpc-service-name: vless-service

15.) VLess-HU TLS
- name: VLessHU_${user}
  type: vless
  server: ${domain}
  port: 443
  uuid: ${uuid}
  udp: true
  tls: true
  network: ws
  client-fingerprint: chrome
  servername: ${domain}
  alpn:
  - http/1.1
  skip-cert-verify: true
  ws-opts:
   path: "/vless-http"
   headers:
     Host: ${domain}
   v2ray-http-upgrade: true
   v2ray-http-upgrade-fast-open: false

16.) VLess-HU nonTLS
- name: VLessHU_${user}
  type: vless
  server: ${domain}
  port: 80
  uuid: ${uuid}
  udp: true
  tls: false
  network: ws
  client-fingerprint: chrome
  alpn:
  - http/1.1
  skip-cert-verify: true
  ws-opts:
   path: "/vless-http"
   headers:
     Host: ${domain}
   v2ray-http-upgrade: true
   v2ray-http-upgrade-fast-open: false

17.) Shadowsocks-Outline TCP/UDP
- name: SSOutline_${user}
  type: ss
  server: ${domain}
  port: 1080
  cipher: aes-128-gcm
  password: ${uuid}
  udp: true

18.) Shadowsocks-WS TLS
- name: SSWS_${user}
  type: ss
  server: ${domain}
  port: 443
  cipher: aes-128-gcm
  password: ${uuid}
  plugin: v2ray-plugin
  plugin-opts:
    mode: websocket
    host: ${domain}
    tls: true
    skip-cert-verify: true
    path: "/shadowsocks" # selain path ini ada /shadowsocks-antiads atau /shadowsocks-antiporn
    mux: false

19.) Shadowsocks-WS nonTLS
- name: SSWS_${user}
  type: ss
  server: ${domain}
  port: 80
  cipher: aes-128-gcm
  password: ${uuid}
  plugin: v2ray-plugin
  plugin-opts:
    mode: websocket
    host: ${domain}
    tls: false
    skip-cert-verify: true
    path: "/shadowsocks" # selain path ini ada /shadowsocks-antiads atau /shadowsocks-antiporn
    mux: false

SELALU PATUHI PERATURAN SERVER DAN TERIMA KASIH SUDAH MEMILIH RerechanStore 🙏

CONTACT WA : https://wa.me/6283120684925
TELEGRAM CHANNEL : https://t.me/project_rerechan
TELEGRAM GROUP : https://t.me/RerechanStore" > "/var/www/html/oc-${user}.conf"
clear
echo -e ""
echo -e "=======-XRAY-ALLVPN-======="
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
echo -e "-==============================-"
echo -e "password/uuid: ${uuid}"
echo -e "security: auto"
echo -e "allowInsecure: true"
echo -e "-==============================-"
echo -e "List VPN: "
echo -e "1.) Trojan (TCP, WS, GRPC, HTTPUPGRADE)"
echo -e "2.) VLess (TCP REALITY, WS, GRPC, HTTPUPGRADE)"
echo -e "3.) VMess (TCP HEADER, WS, GPPC. HTTPUPGRADE)"
echo -e "4.) ShadowSocks (Outline, TCP HEADER, WS, GRPC)"
echo -e "-==============================-"
echo -e "Untuk detail lengkap, bisa kalian download file dibawah ini"
echo -e "Link URL Config : https://${domain}/oc-$user.conf"
echo -e "-==============================-"
echo -e "Link Subscription : https://${domain}${subs}"
echo -e "================================="
echo -e "Masa Aktif: ${text}"
echo -e "${text2}"
rm -r /tmp/${user}_all.json
# Tambahkan prompt sebelum keluar
read -n 1 -s -r -p "Press any key to exit..."