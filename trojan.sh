#!/bin/bash

# Install dependencies
apt update && apt upgrade -y
apt install -y curl wget unzip systemd

# Install Trojan-Go (latest)
wget https://github.com/p4gefau1t/trojan-go/releases/latest/download/trojan-go-linux-amd64.zip
unzip trojan-go-linux-amd64.zip
mv trojan-go /usr/local/bin/
chmod +x /usr/local/bin/trojan-go
rm trojan-go-linux-amd64.zip

# Setup Trojan-Go config file
cat > /etc/trojan-go/config.json <<EOF
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 443,
  "remote_addr": "127.0.0.1",
  "remote_port": 80,
  "password": ["ganti-password-kamu"],
  "disable_http_check": true,
  "udp_timeout": 60,
  "ssl": {
    "enabled": false
  },
  "websocket": {
    "enabled": true,
    "path": "/ws",
    "host": "api.ovo.id"
  },
  "router": {
    "enabled": true,
    "block": [],
    "proxy": [],
    "direct": ["api.ovo.id", "my.udemy.com", "dev.appsflyer.com"]
  }
}
EOF

# Create systemd service for Trojan-Go
cat > /etc/systemd/system/trojan-go.service <<EOF
[Unit]
Description=Trojan-Go Server
After=network.target

[Service]
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan-go/config.json
Restart=on-failure
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable Trojan-Go service
systemctl daemon-reload
systemctl enable trojan-go
systemctl start trojan-go

# Check if Trojan-Go is running
systemctl status trojan-go
EOF

3. **Beri izin eksekusi** pada script:
```bash
chmod +x trojan-go-setup.sh
