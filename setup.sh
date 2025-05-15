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

OS="$(uname)"
echo "偵測到作業系統：$OS"

# 設定路徑依據作業系統
if [[ "$OS" == "Darwin" ]]; then
    # macOS
    TARGET_HOME="$HOME"
elif [[ "$OS" == "Linux" ]]; then
    # Ubuntu 預設
    TARGET_HOME="$HOME"
else
    echo "不支援的作業系統：$OS"
    exit 1
fi

# 建立 Vim 顏色資料夾
mkdir -p "$TARGET_HOME/.vim/colors"

# 複製設定檔
cp "$HOME/config/.p10k.zsh" "$TARGET_HOME" && echo "✅ 已複製 .p10k.zsh"
cp "$HOME/config/.zshrc" "$TARGET_HOME" && echo "✅ 已複製 .zshrc"
cp -R "$HOME/config/vim/colors" "$TARGET_HOME/.vim/" && echo "✅ 已複製 Vim 顏色主題"
cp "$HOME/config/vim/.vimrc" "$TARGET_HOME/.vimrc" && echo "✅ 已複製 .vimrc"
ln -s ~/.zshrc ~/.zshenv 

echo "✅ 設定檔已複製到家目錄"

# --- 設定 zsh 為預設 shell（選擇性）---
read -rp "🔁 是否將 zsh 設為預設 shell？(y/N): " SET_ZSH
if [[ "${SET_ZSH,,}" == "y" ]]; then
  chsh -s "$(which zsh)"
  echo "✔️  已將 zsh 設為預設 shell，請重新登入"
fi

# 修改 zsh-autosuggestions 插件設定
ZSH_AUTOSUGGEST_FILE="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

if [[ -f "$ZSH_AUTOSUGGEST_FILE" ]]; then
    echo "🔧 修改 zsh-autosuggestions.zsh 策略為：history completion"
    sed -i.bak 's/ZSH_AUTOSUGGEST_STRATEGY=(history)/ZSH_AUTOSUGGEST_STRATEGY=(history completion)/' "$ZSH_AUTOSUGGEST_FILE" \
        && echo "✅ 修改成功（備份為 .bak）"
else
    echo "⚠️ 找不到 zsh-autosuggestions.zsh：$ZSH_AUTOSUGGEST_FILE"
fi

echo "🎉 完成安裝與設定！"

