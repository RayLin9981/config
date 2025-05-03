#!/bin/bash
set -e

echo "=== ⚙️ 建立 MOTD /etc/issue 與 Systemd 自動更新設定 ==="

# === MOTD: /etc/update-motd.d/99-custom-info ===
MOTD_SCRIPT="/etc/update-motd.d/99-custom-info"
if [ -f "$MOTD_SCRIPT" ]; then
    cp -p "$MOTD_SCRIPT" "${MOTD_SCRIPT}.bak_$(date +%Y%m%d%H%M%S)"
    echo "📦 備份原 MOTD 為 ${MOTD_SCRIPT}.bak_$(date +%Y%m%d%H%M%S)"
fi

cat <<'EOF' | sudo tee "$MOTD_SCRIPT" > /dev/null
#!/bin/bash
echo ""
echo "==== 系統資訊 ===="
echo "🖥️  主機名稱 : $(hostname)"
echo "🌐  本機 IP   : $(hostname -I | awk '{print $1}')"
if command -v curl >/dev/null 2>&1; then
    echo "🌍  公網 IP   : $(curl -s ifconfig.me)"
fi
echo "👤  登入使用者數 : $(who | wc -l)"
echo "💾  磁碟使用狀況 :"
df -hT / | awk 'NR==1 || /^\/.*/ {print "   " $0}'
echo ""
EOF

sudo chmod +x "$MOTD_SCRIPT"
echo "✅ MOTD 腳本建立完成：$MOTD_SCRIPT"

# === ISSUE (/etc/issue) ===
ISSUE_FILE="/etc/issue"
if [ -f "$ISSUE_FILE" ]; then
    cp -p "$ISSUE_FILE" "${ISSUE_FILE}.bak_$(date +%Y%m%d%H%M%S)"
    echo "📦 備份 /etc/issue → ${ISSUE_FILE}.bak_$(date +%Y%m%d%H%M%S)"
fi

# 取得 UID 1000 的使用者名稱
USER_UID_1000=$(getent passwd | awk -F: '$3 == 1000 {print $1}')

if [ -z "$USER_UID_1000" ]; then
    USER_UID_1000="未設定"
fi

# 自訂更新 issue 的 script
UPDATE_ISSUE_SCRIPT="/usr/local/bin/update-issue"
cat <<'EOF' | sudo tee "$UPDATE_ISSUE_SCRIPT" > /dev/null
#!/bin/bash
HOST=$(hostname)
IP=$(hostname -I | awk '{print $1}')
USER_UID_1000=$(getent passwd | awk -F: '$3 == 1000 {print $1}')

if [ -z "$USER_UID_1000" ]; then
    USER_UID_1000="未設定"
fi

echo "Welcome to $HOST" > /etc/issue
echo "Local IP: $IP" >> /etc/issue
echo "First user (UID 1000): $USER_UID_1000" >> /etc/issue
EOF

sudo chmod +x "$UPDATE_ISSUE_SCRIPT"
echo "✅ 已建立 /usr/local/bin/update-issue，可手動或定時呼叫"

# 立即執行一次
sudo /usr/local/bin/update-issue

# === 問使用者是否加入 systemd timer ===
read -rp "📆 是否要建立 systemd 定期更新 /etc/issue？(y/N): " USE_TIMER
USE_TIMER=${USE_TIMER,,} # 小寫

if [[ "$USE_TIMER" == "y" ]]; then
    # 建立 systemd unit 與 timer
    cat <<EOF | sudo tee /etc/systemd/system/update-issue.service > /dev/null
[Unit]
Description=Update /etc/issue with current IP/hostname

[Service]
Type=oneshot
ExecStart=/usr/local/bin/update-issue
EOF

    cat <<EOF | sudo tee /etc/systemd/system/update-issue.timer > /dev/null
[Unit]
Description=Run update-issue every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=update-issue.service

[Install]
WantedBy=timers.target
EOF

    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl enable --now update-issue.timer
    echo "✅ 已啟用 systemd timer，每 5 分鐘自動更新 /etc/issue"
else
    echo "⏭️  已略過 systemd 自動更新功能"
fi

echo "🎉 所有設定已完成，下次登入或進 tty 將看到更新資訊"

