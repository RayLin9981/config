# ⚡ Instant prompt 初始化 (Powerlevel10k 提供)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 📁 設定 oh-my-zsh 路徑
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

# 🎨 主題設定 (Powerlevel10k)
ZSH_THEME="powerlevel10k/powerlevel10k"

# ⚙️ 啟用插件
plugins=(
  git
  you-should-use
  zsh-autosuggestions
  zsh-completions
  docker
  docker-compose
  kubectl
)

# 📦 載入 oh-my-zsh 主程式
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "⚠️ 無法載入 oh-my-zsh，請確認安裝路徑：$ZSH"
fi

# 💎 載入 powerlevel10k 設定（若存在）
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

export YSU_MESSAGE_POSITION="after"
