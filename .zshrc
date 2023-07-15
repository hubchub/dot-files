# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-vim-mode docker docker-compose fzf) 
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#alias ls="exa"

autoload -Uz history-search-end

blockscout() {
    namespace=$(k config current-context)
    postfix=$(echo $namespace | sed 's/.*-//')
    if [[ $1 == "up" ]]; then
	    for chain in $(cat ~/Work/Quai/chains.txt); do
		    kubectl scale --replicas=1 deployment/$chain-quai-blockscout-$postfix -n $namespace
	    done
    elif [[ $1 == "down" ]]; then
	    kubectl delete pvc -n $namespace data-quai-postgresql-quai-$postfix-0 &
	    kubectl delete pod -n $namespace quai-postgresql-quai-$postfix-0
	    for chain in $(cat ~/Work/Quai/chains.txt); do
		    kubectl scale --replicas=0 deployment/$chain-quai-blockscout-$postfix -n $namespace
	    done
    else
	echo "Invalid argument. Please use 'up' or 'down'."
    fi
}

function garden() {
  ansible garden -i $HOME/Work/Quai/dev-ops/ansible/hosts -m ansible.builtin.shell -a "$1" -u connorhubbard --become
}

function galena() {
  ansible galena -i $HOME/Work/Quai/dev-ops/ansible/hosts -m ansible.builtin.shell -a "$1" -u connorhubbard --become
}

function galena21() {
  ansible galena21 -i $HOME/Work/Quai/dev-ops/ansible/hosts -m ansible.builtin.shell -a "$1" -u connorhubbard --become
}

function galenaslices() {
  ansible galenaslices -i $HOME/Work/Quai/dev-ops/ansible/hosts -m ansible.builtin.shell -a "$1" -u connorhubbard --become
}

function orchard() {
  ansible orchard -i $HOME/Work/Quai/dev-ops/ansible/hosts -m ansible.builtin.shell -a "$1" -u connorhubbard --become
}
function orchardminers() {
  ansible orchardminers -i $HOME/Work/Quai/dev-ops/ansible/hosts -m ansible.builtin.shell -a "$1" -u connorhubbard --become
}

function colosseum() {
  ansible colosseum -i $HOME/Work/Quai/dev-ops/ansible/hosts -m ansible.builtin.shell -a "$1" -u connorhubbard --become
}

function csv() {
   cat $1 | awk "/order=$2/ {split(\$6,a,\"=\"); split(\$9,b,\"=\"); split(\$13,c,\"=\"); split(\$14,d,\"=\"); print c[2]\",\"a[2]\",\"b[2]\",\"d[2]}" | sort -t "," -k1,1 -k2,2n | sed "s/ms//g"
}

function spawn() {
    # Ensure an argument is provided
    if [ "$#" -ne 1 ]; then
        echo "Usage: spawn <ansible-group>"
        return 1
    fi

    # Ensure the Ansible inventory file exists
    if [ ! -f "$HOME/Work/Quai/dev-ops/ansible/hosts" ]; then
        echo "Ansible inventory file not found at $HOME/Work/Quai/dev-ops/ansible/hosts"
        return 1
    fi

    # Extract the group name from the arguments
    local group_name="$1"

    awk -v group="$group_name" -v RS= -F'\n' '
        $1 == "["group"]" {
            for (i=2; i<=NF; i++) {
                split($i, a, " ");
                system("echo kitty ssh connorhubbard@" a[1]);
                system("kitty ssh connorhubbard@" a[1] " -o StrictHostKeyChecking=no &");
            }
        }
    ' "$HOME/Work/Quai/dev-ops/ansible/hosts"
}


xset r rate 150 67

source <(kubectl completion zsh)

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/hubchub/Applications/google-cloud-sdk/path.zsh.inc' ]; then . '/home/hubchub/Applications/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/hubchub/Applications/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/hubchub/Applications/google-cloud-sdk/completion.zsh.inc'; fi

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

alias k="kubectl"
alias cat="bat --paging never --style plain"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
alias pbcopy='xclip -selection clipboard'
alias pbpwd='pwd | pbcopy'
alias pbpaste='xclip -selection clipboard -o'
alias prettydate="date +%Y-%m-%d_%H-%M-%S"
alias note="vim ~/Notes/$(prettydate).txt"
alias awk='gawk'
alias gcm='gc -m'
alias gs='git show'
alias dup='pwd | DUP=true kitty & disown'
alias src="DUP=true source '$HOME/.zshrc'"
if [[ -z "$DUP" ]]; then cd ~/Work/Quai; fi
unset DUP

eval $(thefuck --alias)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="$HOME/.cargo/env:$PATH"
export PATH="/opt/elixir/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"

