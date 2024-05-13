# grep
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"

# ls
alias l="ls -l"
alias ll="ls -l"
alias la="ls -la"

# confirm options
alias rm="rm -i"
alias cp="cp -i"

# cd
alias ..="cd .."
alias ...="cd ../.."

# docker
alias d="docker"
alias dc="docker compose"
alias dce="docker compose exec"
alias dcd="docker compose down"
alias dcud="docker compose up -d"
alias dcudb="docker compose up -d --build"

# git
alias g="git"
alias glo="git log --oneline"
alias gcm="git checkout main"
alias gs="git status"
alias gc="git checkout"
alias gcb="git checkout -b"
alias gco="git commit"
alias gd="git diff"
alias gdf="git diff --name-only"
alias gdm="git diff main"
alias gdmw="git diff main -w"
alias gdw="git diff -w"
alias gds="git diff --staged"
alias gdsw="git diff --staged -w"
alias gdws="git diff --staged -w"
alias gl="git log"
alias glo="git log --oneline"
alias nb="git rev-parse --abbrev-ref HEAD"

# node
alias n="node"

# nvim
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias code="nvim"

# util
alias cb="system_profiler SPPowerDataType | grep Wattage"

# Application
alias fork="open -a Fork"
alias chrome="open -a Google\ Chrome"
alias ff="open -a Firefox"
alias edge="open -a Microsoft\ Edge"

# util
alias calx='cal -3; curl -s https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv | iconv -f SHIFT-JIS -t UTF-8 | grep -E "`date -v-1m '+%Y/%-m/'`|`date '+%Y/%-m/'`|`date -v+1m '+%Y/%-m/'`"'

alias rmn='mv ./node_modules /tmp/node_modules.`date +%s`'
