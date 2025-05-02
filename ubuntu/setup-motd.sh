#!/bin/bash
set -e

echo "📋 建立自訂 MOTD 訊息：/etc/update-motd.d/99-custom-info"

MOTD_FILE="/etc/update-motd.d/99-custom-info"

# 備份舊檔（若有）
if [ -f "$MOTD_FILE" ]; then
    cp -p "$MOTD_FILE" "${MOTD_FILE}.bak_$(date +%Y%m%d%H%M%S)"
    echo "📦 備份原有 MOTD 為 ${MOTD_FILE}.bak_$(date +%Y%m%d%H%M%S)"
fi

# 寫入 MOTD 腳本
cat <<'EOF' | sudo tee "$MOTD_FILE" > /dev/null
#!/bin/bash

echo ""
echo "==== 系統資訊 ===="
echo "🖥️  主機名稱 : $(hostname)"
echo "🌐  本機 IP   : $(hostname -I | awk '{print $1}')"

# 若 curl 存在，顯示外部 IP
if command -v curl >/dev/null 2>&1; then
    echo "🌍  公網 IP   : $(curl -s ifconfig.me)"
fi

echo "👤  登入使用者數 : $(who | wc -l)"
echo "💾  磁碟使用狀況 :"
df -hT / | awk 'NR==1 || /^\/.*/ {print "   " $0}'
echo ""
EOF

# 設定執行權限
sudo chmod +x "$MOTD_FILE"
echo "✅ 已建立並啟用 /etc/update-motd.d/99-custom-info"

