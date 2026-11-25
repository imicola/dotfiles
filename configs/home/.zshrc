export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"
zstyle ':omz:update' mode disabled
SPACESHIP_TIME_SHOW=true
SPACESHIP_USER_SHOW=always
SPACESHIP_USER_COLOR=212
plugins=(git sudo copypath copyfile autojump)
source "$ZSH/oh-my-zsh.sh"
[[ -s "$HOME/.autojump/etc/profile.d/autojump.sh" ]] && source "$HOME/.autojump/etc/profile.d/autojump.sh"
export EDITOR=nvim VISUAL=nvim SUDO_EDITOR=nvim
alias cls='clear'
alias vi='nvim'
alias vim='nvim'
alias ls='eza --icons --group-directories-first'
alias c='tee >(wl-copy)'
alias p='wl-paste'
alias cb='codebuddy'
source <(fzf --zsh)
[[ -r "$HOME/.config/honor/proxy.sh" ]] && source "$HOME/.config/honor/proxy.sh"
(( $+functions[proxy_on] )) && proxy_on
[ -r "$HOME/.config/honor/dev.sh" ] && . "$HOME/.config/honor/dev.sh"

[[ -o interactive && -t 1 && -z "$HONOR_NO_FETCH" ]] && fastfetch
[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Added by Antigravity CLI installer
export PATH="/home/imicola/.local/bin:$PATH"
