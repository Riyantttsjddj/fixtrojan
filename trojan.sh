#!/bin/bash

# === Konfigurasi Umum ===
TROJAN_BIN="/usr/local/bin/trojan-go"
CONFIG_PATH="/etc/trojan-go/config.json"
CERT_PATH="/etc/ssl/private/trojan-go-cert.pem"
KEY_PATH="/etc/ssl/private/trojan-go-key.pem"
WS_PATH="/axisws"
PASSWORD="freenetaxis2025"
MULTI_HOST='[
  "api.ovo.id",
  "my.udemy.com",
  "dev.appsflyer.com"
]'

# === Cek Binary ===
if [ ! -f "$TROJAN_BIN" ]; then
    echo "❌ Trojan-Go tidak ditemukan di $TROJAN_BIN"
    exit 1
fi

# === Generate Sertifikat Dummy Jika Tidak Ada ===
if [ ! -f "$CERT_PATH" ] || [ ! -f "$KEY_PATH" ]; then
    echo "🔧 Membuat sertifikat SSL dummy..."
    mkdir -p /etc/ssl/private
    openssl req -newkey rsa:2048 -nodes -keyout "$KEY_PATH" \
        -x509 -days 365 -out "$CERT_PATH" -subj "/CN=localhost"
fi

# === Buat ulang config.json ===
echo "🛠️ Membuat konfigurasi Trojan-Go baru..."
cat <<EOF > "$CONFIG_PATH"
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 443,
  "remote_addr": "127.0.0.1",
  "remote_port": 80,
  "password": [
    "$PASSWORD"
  ],
  "ssl": {
    "cert": "$CERT_PATH",
    "key": "$KEY_PATH",
    "sni": "api.ovo.id"
  },
  "websocket": {
    "enabled": true,
    "path": "$WS_PATH",
    "host": $MULTI_HOST
  },
  "router": {
    "enabled": true,
    "block": [],
    "allow": [],
    "geoip": false,
    "geosite": false
  }
}
EOF

# === Reload & Restart Trojan-Go ===
echo "🔄 Restarting Trojan-Go service..."
systemctl daemon-reload
systemctl restart trojan-go

# === Tampilkan Status ===
sleep 2
systemctl status trojan-go --no-pager -l
