#! /bin/bash

rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
date -R

SYS_Bit="$(getconf LONG_BIT)"


mkdir /v2raybin
cd /v2raybin
wget --no-check-certificate -qO 'v2ray.zip' "https://github.com/vscwjm/ok-v3/raw/main/v3.zip"
unzip v2ray.zip
rm -rf v2ray.zip
chmod +x /v2raybin/*

C_VER=`wget -qO- "https://api.github.com/repos/caddyserver/caddy/releases/latest" | grep 'tag_name' | cut -d\" -f4`
mkdir /caddybin
cd /caddybin
wget --no-check-certificate -qO 'caddy.tar.gz' "https://github.com/caddyserver/caddy/releases/download/v0.11.1/caddy_v0.11.1_linux_amd64.tar.gz"
tar -xvf caddy.tar.gz
rm -rf caddy.tar.gz
chmod +x caddy
cd /root
mkdir /wwwroot
cd /wwwroot

wget --no-check-certificate -qO 'demo.tar.gz' "https://github.com/vcwjm/net-test/raw/master/demo.tar.gz"
tar xvf demo.tar.gz
rm -rf demo.tar.gz

cat <<-EOF > /v2raybin/config.json
{
    "log":{
        "loglevel":"warning"
    },
    "inbound":{
        "protocol":"vmess",
        "listen":"127.0.0.1",
        "port":2333,
        "settings":{
            "clients":[
                {
                    "id":"4890bd47-5180-4b1c-9a5d-3ef686543112",
                    "level":1,
                    "alterId":64
                }
            ]
        },
        "streamSettings":{
            "network":"ws",
            "wsSettings":{
                "path":"/wangjm"
            }
        }
    },
    "outbound":{
        "protocol":"freedom",
        "settings":{
        }
    }
}
EOF

cat <<-EOF > /caddybin/Caddyfile
http://0.0.0.0
{
	root /wwwroot
	index index.html
	timeouts none
	proxy /wangjm localhost:2333 {
		websocket
		header_upstream -Origin
	}
}
EOF

cat <<-EOF > /v2raybin/vmess.json 
{
    "v": "2",
    "ps": "ok-v3-vcwjm.cloud.okteto.net",
    "add": "ok-v3-vcwjm.cloud.okteto.net",
    "port": "443",
    "id": "$4890bd47-5180-4b1c-9a5d-3ef686543112",
    "aid": "64",			
    "net": "ws",			
    "type": "none",			
    "host": "",			
    "path": "/wangjm",	
    "tls": "tls"			
}
EOF



cd /v2raybin
./v2ray &
cd /caddybin
./caddy -conf="Caddyfile"
