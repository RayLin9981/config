#!/bin/bash
set -e

MOTD_FILE="/etc/update-motd.d/99-custom-info"

echo "📋 建立自訂 MOTD 訊息：$MOTD_FILE"

# 備份舊 MOTD（若存在）
if [ -f "$MOTD_FILE" ]; then
    BACKUP_NAME="${MOTD_FILE}.bak_$(date +%Y%m%d%H%M%S)"
    cp -p "$MOTD_FILE" "$BACKUP_NAME"
    echo "📦 備份原有 MOTD 為 $BACKUP_NAME"
fi

# 移除 /etc/update-motd.d 中其他檔案的執行權限（排除自訂 MOTD）
echo "🚫 移除其他 MOTD 腳本的執行權限..."
find /etc/update-motd.d/ -type f ! -name '99-custom-info' -exec chmod -x {} \;

# 建立新的 MOTD 腳本
cat <<'EOF' | sudo tee "$MOTD_FILE" > /dev/null
#!/bin/bash

echo ""
echo "==== 系統資訊 ===="
echo "🖥️  主機名稱 : $(hostname)"
echo "🌐  本機 IP   : $(hostname -I | awk '{print $1}')"


# 登入使用者數
echo "👤  登入使用者數 : $(who | wc -l)"

# 磁碟使用狀況
echo "💾  磁碟使用狀況 :"
df -hT / | awk 'NR==1 || /^\/.*/ {print "   " $0}'

# 記憶體使用狀況
mem_total=$(free -m | awk '/^Mem:/ {print $2}')
mem_used=$(free -m | awk '/^Mem:/ {print $3}')
mem_perc=$((mem_used * 100 / mem_total))
echo "🧠  記憶體使用量 : ${mem_used}MB / ${mem_total}MB (${mem_perc}%)"

# CPU 使用率（過去 1 分鐘 load average + 使用者佔比）
loadavg=$(uptime | awk -F'load average: ' '{print $2}' | cut -d',' -f1)
cpu_user=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
echo "🧮  CPU 使用率   : ${cpu_user}% 使用者負載（1 分鐘平均負載：$loadavg）"

echo ""
EOF

# 設定執行權限
sudo chmod +x "$MOTD_FILE"
echo "✅ 已建立並啟用 $MOTD_FILE"

