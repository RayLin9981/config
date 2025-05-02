#!/bin/bash
# Ubuntu Desktop 22.04 最小化安裝環境設置腳本

set -e

# --- 安裝基本工具 ---
sudo apt update
sudo apt install -y openssh-server git zsh curl wget

# --- 安裝 oh-my-zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🌀 安裝 oh-my-zsh..."
  export RUNZSH=no
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✔️  oh-my-zsh 已安裝，略過。"
fi

# --- 設定 ZSH_CUSTOM ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# --- 安裝 powerlevel10k 主題 ---
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "🎨 安裝 powerlevel10k 主題..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# --- 安裝 you-should-use 插件 ---
if [ ! -d "$ZSH_CUSTOM/plugins/you-should-use" ]; then
  git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"
fi

# --- 安裝 zsh-autosuggestions 插件 ---
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# --- 安裝 zsh-completions 插件 ---
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
  git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

echo "✅ Zsh 插件與主題已安裝。"

# --- p10k 字型提示 ---
echo "⚠️  請手動安裝 MesloLGS NF 字型： https://github.com/romkatv/powerlevel10k#manual-font-installation"

# --- 複製個人設定檔 ---
echo "📁 複製設定檔..."

if [ ! -d "$HOME/config" ]; then
  git clone https://github.com/RayLin9981/config.git "$HOME/config"
fi

cp "$HOME/config/.p10k.zsh" "$HOME"
cp "$HOME/config/.zshrc" "$HOME"
cp -R "$HOME/config/vim" "$HOME/.vim"

echo "✅ 設定檔已複製到家目錄"

# --- 設定 zsh 為預設 shell（選擇性）---
read -rp "🔁 是否將 zsh 設為預設 shell？(y/N): " SET_ZSH
if [[ "${SET_ZSH,,}" == "y" ]]; then
  chsh -s "$(which zsh)"
  echo "✔️  已將 zsh 設為預設 shell，請重新登入"
fi

echo "🎉 完成安裝與設定！"

