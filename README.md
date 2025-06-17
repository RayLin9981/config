# config
```
git clone https://github.com/RayLin9981/config.git
```

# 請參考 setup.sh 使用

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

# p10k 的部分可能會需要新增字型, 這部分就手動安裝並且修改
# 使用 MesloLGS NF Regular.ttf
# https://github.com/romkatv/powerlevel10k/blob/master/font.md


# mac
git clone https://github.com/RayLin9981/config.git

cp config/mac/.p10k.zsh ~
cp config/mac/.zshrc ~
cp -R config/vim ~/.vim

```
# 注意事項  
當 oh-my-zsh 用 normal user 安裝失敗時，先看看 ZSH 相關的變數，不要直接用 sudo 去跑  

# 測試 (2024.8)
- macbook
- ubuntu 24.04
