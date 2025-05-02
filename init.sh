#!/bin/bash
set -e

echo "=== Ubuntu 初始設定腳本（含備份、防 IP 衝突） ==="

# 預設參數抓取
DEFAULT_HOSTNAME=$(hostname)
DEFAULT_IFACE=$(ip -o link show | awk -F': ' '/^[0-9]+: (e.*|ens.*)/ {print $2; exit}')
DEFAULT_IP=$(ip -4 addr show "$DEFAULT_IFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+')
DEFAULT_GATEWAY=$(ip route | awk '/default/ {print $3}')
DEFAULT_DNS="8.8.8.8 1.1.1.1"

# 互動式輸入（可按 Enter 使用預設）
read -rp "請輸入主機名稱 (預設: $DEFAULT_HOSTNAME): " NEW_HOSTNAME
read -rp "請輸入網路介面名稱 (預設: $DEFAULT_IFACE): " IFACE
NEW_HOSTNAME=${NEW_HOSTNAME:-$DEFAULT_HOSTNAME}
IFACE=${IFACE:-$DEFAULT_IFACE}

# === IP 衝突檢查 ===
MAX_TRIES=5
TRY=1
while [ $TRY -le $MAX_TRIES ]; do
    read -rp "請輸入 IP 位址 (CIDR格式，預設: $DEFAULT_IP): " IP_ADDR
    IP_ADDR=${IP_ADDR:-$DEFAULT_IP}
    IP_ONLY=${IP_ADDR%%/*}

    echo "🔍 檢查 $IP_ONLY 是否已存在於網路中..."
    if ping -c 1 -W 1 "$IP_ONLY" >/dev/null 2>&1; then
        echo "⚠️  IP $IP_ONLY 已被使用，請重新輸入。"
        TRY=$((TRY + 1))
    else
        echo "✅ IP $IP_ONLY 尚未使用，繼續設定..."
        break
    fi
done

if [ $TRY -gt $MAX_TRIES ]; then
    echo "❌ 超過 $MAX_TRIES 次重試次數，請確認網路後再執行。"
    exit 1
fi

read -rp "請輸入 Gateway (預設: $DEFAULT_GATEWAY): " GATEWAY
read -rp "請輸入 DNS (空格分隔，預設: $DEFAULT_DNS): " DNS_SERVERS
GATEWAY=${GATEWAY:-$DEFAULT_GATEWAY}
DNS_SERVERS=${DNS_SERVERS:-$DEFAULT_DNS}

# 備份工具
backup_file() {
    FILE="$1"
    if [ -f "$FILE" ]; then
        cp -p "$FILE" "${FILE}.bak_$(date +%Y%m%d%H%M%S)"
        echo "📦 已備份 $FILE → ${FILE}.bak_$(date +%Y%m%d%H%M%S)"
    fi
}

echo ""
echo "[1/6] 停用 cloud-init 網路設定..."
sudo mkdir -p /etc/cloud/cloud.cfg.d
backup_file /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
echo "network: {config: disabled}" | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg > /dev/null

if [ -f /etc/netplan/50-cloud-init.yaml ]; then
    backup_file /etc/netplan/50-cloud-init.yaml
    sudo rm -f /etc/netplan/50-cloud-init.yaml
fi

echo "[2/6] 設定 hostname 為 $NEW_HOSTNAME..."
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

echo "[3/6] 更新 /etc/hosts 中的 127.0.1.1 條目..."
backup_file /etc/hosts
if grep -q '^127.0.1.1' /etc/hosts; then
    sudo sed -i "s/^127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/" /etc/hosts
else
    echo -e "127.0.1.1\t$NEW_HOSTNAME" | sudo tee -a /etc/hosts > /dev/null
fi

NETPLAN_FILE="/etc/netplan/50-custom-config.yaml"
echo "[4/6] 建立 netplan 設定到 $NETPLAN_FILE..."
backup_file "$NETPLAN_FILE"

cat <<EOF | sudo tee "$NETPLAN_FILE" > /dev/null
network:
    version: 2
    ethernets:
        $IFACE:
            addresses:
                - $IP_ADDR
            nameservers:
                addresses: [${DNS_SERVERS// /, }]
            routes:
                - to: default
                  via: $GATEWAY
EOF

echo "[5/6] 套用 netplan 設定..."
sudo netplan apply

echo "[6/6] ✅ 完成！設定資訊如下："
echo "🖥️ 主機名稱：$NEW_HOSTNAME"
echo "🔌 網卡：$IFACE"
echo "🌐 IP：$IP_ADDR"
echo "🚪 Gateway：$GATEWAY"
echo "🧭 DNS：$DNS_SERVERS"
echo "📄 所有異動檔案已自動備份為 *.bak_時間戳"
