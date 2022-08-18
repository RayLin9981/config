# config
git clone https://github.com/RayLin9981/config.git

# zsh, p10k 的設定檔案
把自己的安裝內容記錄一下
```bash

# ubuntu desktop 22.04 最小化安裝
sudo apt update
sudo apt install openssh-server git
# oh-my-zsh 
sudo apt install zsh # zsh 5.8.1
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#
# p10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 安裝 you-should-use
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
# 在 ~/.zshrc 的 plugin 中新增 you-should-use

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# 在 ~/.zshrc 的 plugin 中新增 zsh-autosuggestions

# zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

# mac
git clone https://github.com/RayLin9981/config.git

cp config/mac/.p10k.zsh ~
cp config/mac/.zshrc ~
cp -R config/vim ~/.vim

```
