if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export PATH=$HOME/bin:/usr/local/bin:${PATH}:/usr/local/sbin
export ZSH="/Users/${USER}/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
git
osx
you-should-use
zsh-autosuggestions
zsh-completions
)
source $ZSH/oh-my-zsh.sh
export LANG=en_US.UTF-8
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export YSU_MESSAGE_POSITION="after"
