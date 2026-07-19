# Enable Powerlevel10k instant prompt. Should stay close to the top of /home/alicek106/nix/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR=nvim

# Increase Max history size
HISTSIZE=90000
SAVEHIST=90000
HISTFILE=~/.zsh_history

# For ctrl + s (stopping)
stty stop undef

# AWS Configuration
export AWS_SDK_LOAD_CONFIG=true

# Terminal Color
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

# 히스토리 중복 방지
setopt histignoredups 

# zshrc에서 pattern maching 할 때, 에러 안나도록
setopt +o nomatch

### alias
alias pc="pbcopy"
alias pp="pbpaste"

alias ks="kubectl"
alias kg="kubectl get"
alias kd="kubectl describe"
alias kn="kubens"
alias ka="kubectl apply -f"
alias kx="kubectx"
alias kvs="kubectl view-secret"
alias kkill="kubectl delete po --force --grace-period 0"
alias kport="kubectl port-forward"
alias kgno="kubectl get nodes -L beta.kubernetes.io/instance-type,aws/instance-group,aws/instance-id,karpenter.sh/nodepool,devsisters.cloud/application --sort-by=.metadata.creationTimestamp"

alias tws="terraform workspace select"
alias twl="terraform workspace list"
alias tf="terraform"

alias gst="git status"

source $ZIM_INIT init -q
source $ZIM_HOME/init.zsh

# To customize prompt, run `p10k configure` or edit /home/alicek106/nix/.p10k.zsh.
[[ ! -f /root/nix/.p10k.zsh ]] || source /root/nix/.p10k.zsh

bindkey -e
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word

source $FZF/share/fzf/completion.zsh
source $FZF/share/fzf/key-bindings.zsh

# (alicek106) 하드코딩함
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
