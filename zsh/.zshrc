#############################################################################
# ENVIRONMENT CONFIGURATION
#############################################################################

# Path variables
# ---------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
export PROJECTS="$HOME/Projects"
export DOTFILES="$PROJECTS/dotfiles"
export CLOUD="$HOME/OneDrive\ -\ TTU"
# PATH
export PATH=/usr/local/sbin:/usr/local/opt/python/libexec/bin:$DOTFILES/bin:$PATH

# Key bindings
# ---------------------------------------------------------------------------
# these are needed for alt + left/right to work in IntelliJ terminal
bindkey "\e\eOD" backward-word
bindkey "\e\eOC" forward-word

# Utilities
# ---------------------------------------------------------------------------
# less: do not clear screen on exit
export LESS=-XFR
# for z dir navigation
# only source on macOS to avoid error in Linux
case "$OSTYPE" in
    darwin*)
        source /usr/local/etc/profile.d/z.sh
esac
# fuck
eval $(thefuck --alias)
# fzf for navi
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Locale
# ---------------------------------------------------------------------------
# required by gcalcli on macOS
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8
export LANGUAGE=en_GB.UTF-8

#############################################################################
# ZSH
#############################################################################

# theme
ZSH_THEME=powerlevel10k/powerlevel10k
# theme settings
source $DOTFILES/zsh/p10k-lean.zsh
# display red dots while waiting for completion
COMPLETION_WAITING_DOTS="true"
# disable % at EOL
PROMPT_EOL_MARK=''
# Plugins
plugins=(
    web-search
    colored-man-pages
    extract
    # the two below need to be installed separately
    zsh-syntax-highlighting
    zsh-autosuggestions
)
# disable paste highlight
zle_highlight+=(paste:none)
# faster paste
zstyle ':bracketed-paste-magic' active-widgets '.self-*'
# Source default omz config
source $ZSH/oh-my-zsh.sh
# iTerm shell integration
source $DOTFILES/zsh/.iterm2_shell_integration.zsh

#############################################################################
# NAVIGATION & FILE MANAGEMENT
#############################################################################

# Shortcuts
# ---------------------------------------------------------------------------
alias dl="cd $HOME/Downloads"
alias p="cd $PROJECTS"
alias dot="cd $DOTFILES"
alias ref="cd $PROJECTS/reference"
alias top="cd $PROJECTS/top"

# Trash
# ---------------------------------------------------------------------------
alias t="trash"
alias tcd="cd $HOME/.Trash"
alias tls="ls $HOME/.Trash"
alias tla="la $HOME/.Trash"
# empty trash
te() {
    osascript <<-EOF
	tell application "Finder"
		set itemCount to count of items in the trash
		if itemCount > 0 then
			empty the trash
		end if
	end tell
	EOF
}

# diskutil
# ---------------------------------------------------------------------------
alias dil='diskutil list'
alias diu='diskutil unmount'
# eject all
alias die='osascript -e "tell application \"Finder\" to eject (every disk whose ejectable is true)"'

# Misc
# ---------------------------------------------------------------------------
# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
# quick look
alias ql="qlmanage -p &>/dev/null"
# img tools
alias lsi="imgls"
alias icat="imgcat"
# syntax-highlighted cat
alias ccat='pygmentize -g'
# dd with progress
alias ddd="gdd bs=1M status=progress"
# ls/la with dirs first
alias lad="gls -lAh --group-directories-first --color"
alias lsd="gls --group-directories-first --color"
# mc
alias mc=". /usr/local/opt/midnight-commander/libexec/mc/mc-wrapper.sh"
# recursive mkdir
alias mkdir='mkdir -pv'
# touch with dir creation
mkfile() {
    mkdir -p "$(dirname "$1")" && touch "$1";
}
# thefuck
alias f="fuck"
# open Marta in current dir
m() {
    if [[ $@ == "" ]]; then
        command marta .
    else
        command marta "$@"
    fi
}
# find
ff() {
    if [[ $2 == "" ]]; then
        command find . -iname "*$1*"
    else
        command find "$1" -iname "*$2*"
    fi
}
sf() {
    if [[ $2 == "" ]]; then
        command sudo find . -iname "*$1*"
    else
        command sudo find "$1" -iname "*$2*"
    fi
}

#############################################################################
# SYSTEM
#############################################################################

# Homebrew
# ---------------------------------------------------------------------------
alias bif="brew info"
alias bcif="brew cask info"
alias bi="brew install"
alias bci="brew cask install"
alias bl="brew list"
alias bcl="brew cask list"
alias bs="brew search"
alias br="brew rmtree"
alias bcr="brew cask remove"
bdep() {
    if [[ $@ == "" ]]; then
        brew leaves | xargs brew deps --installed --for-each | sed "s/^.*:/$(tput setaf 4)&$(tput sgr0)/"
    else
        command brew rmtree --dry-run "$@"
    fi
}
alias blv="brew leaves"
alias bul="brew update && brew outdated && brew cask outdated"
bu() {
    echo -e "\e[4mUpdating Homebrew:\e[0m"
    brew update --verbose
    echo ""
    echo -e "\e[4mUpdating brew packages:\e[0m"
    brew upgrade
    echo ""
    echo -e "\e[4mUpdating brew casks:\e[0m"
    brew cask upgrade
}
alias bd="brew cleanup; brew doctor"

# Display
# ---------------------------------------------------------------------------
alias srx="/Applications/RDM.app/Contents/MacOS/SetResX"
# zoom out built-in display
lzo() {
    # check if two displays present
    if srx -ld | wc -l | grep -q "2"; then
        srx -w 1440 -h 900 -s 2.0 -d 1
    else
        srx -w 1440 -h 900 -s 2.0
    fi
}
# zoom in built-in display
lzi() {
    if srx -ld | wc -l | grep -q "2"; then
        srx -w 1280 -h 800 -s 2.0 -d 1
    else
        srx -w 1280 -h 800 -s 2.0
    fi
}
# zoom out external monitor
mzo() {
    # check if two displays present
    if srx -ld | wc -l | grep -q "2"; then
        /Applications/RDM.app/Contents/MacOS/SetResX -w 2560 -h 1440 -s 1.0
    else
        echo "External monitor not connected!"
    fi
}
# zoom in external monitor
mzi() {
    if srx -ld | wc -l | grep -q "2"; then
        /Applications/RDM.app/Contents/MacOS/SetResX -w 2048 -h 1152 -s 2.0
    else
        echo "External monitor not connected!"
    fi
}

# System info
# ---------------------------------------------------------------------------
# status
st() {
    # get uptiime
    boottime=$(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//g')
    unixtime=$(date +%s)
    timeAgo=$(($unixtime - $boottime))
    uptime=$(awk -v time=$timeAgo 'BEGIN { seconds = time % 60; minutes = int(time / 60 % 60);
        hours = int(time / 60 / 60 % 24); days = int(time / 60 / 60 / 24);
        printf("%.0f days, %.0f hours, %.0f minutes, %.0f seconds", days, hours, minutes, seconds); exit }')
    # show data
    print "Date        : $(date -R) $(ls -l /etc/localtime | /usr/bin/cut -d '/' -f 8,9)"
    print "Uptime      : $uptime"
    print "OS          : macOS $(sw_vers -productVersion)"
    print "Kernel      : $(uname -s -r)"
    print "Model       : MacBook Pro 13\" Mid-2014"
    print "CPU         : $(top -l 1 | grep -E "^CPU" | sed -n 's/CPU usage: //p')"
    print "Memory      : $(top -l 1 | grep -E "^Phys" | sed -n 's/PhysMem: //p')"
    print "Swap        : $(sysctl vm.swapusage | sed -n 's/vm.swapusage:\ //p')"
    print "Battery     : $(pmset -g ps | sed -n 's/.*[[:blank:]]+*\(.*%\).*/\1/p')," \
        "cycle count $(system_profiler SPPowerDataType | grep "Cycle Count" | awk '{print $3}')"
    print "Hostname    : $(uname -n)"
    print "Internal IP : $(ipconfig getifaddr en0)"
    print "External IP : $(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')"
}
# wifi network list
alias wifi="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -s"
# network usage stats
alias net="sudo iftop -B"
# speedtest.net
alias sp="speedtest"
# display terminal colors
co() {
    for i in {0..255};
        do print -Pn "%${i}F${(l:3::0:)i}%f " ${${(M)$((i%8)):#7}:+$'\n'};
    done
}

# Misc
# ---------------------------------------------------------------------------
# aliases
a() {
    alias | grep "$1"
}
# which
alias w="which"
# reboot with confirmation dialog
alias reboot='osascript -e "tell app \"loginwindow\" to «event aevtrrst»"'

#############################################################################
# CLI TOOLS
#############################################################################

# Toggl & SelfControl
# ---------------------------------------------------------------------------
alias tg="toggl"
alias tgr="tg continue; tg now"
alias tgn="tg now"
# Open in browser
alias tgw="open https://www.toggl.com/app/timer"
# Projects
alias tgtt="tg start -o TalTech && tg now"
alias tgcode="tg start -o Coding && tg now"
alias tgcar="tg start -o Career && tg now"
alias tghus="tg start \"Hustle\" -o Work && tg now"
alias tgphys="tg start -o Physio && tg now"
# TalTech subjects
alias tgos="tg start \"OS\" -o TalTech && tg now"
alias tgpy="tg start \"Python\" -o TalTech && tg now"
alias tgsis="tg start \"Sissejuhatus\" -o TalTech && tg now"
alias tgen="tg start \"English\" -o TalTech && tg now"
alias tgmat="tg start \"DiskMat\" -o TalTech && tg now"
# Coding, focus mode
tgf() {
    tgcode
    bash -c "nohup pomo 3600 > /dev/null 2>&1 & disown"
    killall Discord > /dev/null 2>&1
    killall Reeder > /dev/null 2>&1
    sudo /Applications/SelfControl.app/Contents/MacOS/org.eyebeam.SelfControl $(id -u $(whoami)) --install > /dev/null 2>&1
}

tgboc() {
    tg start -o Bocconi && tg now
}
# list history for today
tgl() {
    tg ls -s $(date "+%m/%d/%y") -f +project
}
# Stop
tgx() {
    toggl now && toggl stop
    if [[ $(pgrep -f "pomo") ]]; then
        pkill -f "pomo"
    fi
}
# aliases below are needed to support accidental alt+t input
# occasionally happens when switching to terminal with alt+space
alias †gn=tgn
alias †gx=tgx
alias †gcode=tgcode
alias †gboc=tgboc
alias †gcar=tgcar
alias †gtt=tgtt

# ban distractive websites in SelfControl
alias ban="defaults write org.eyebeam.SelfControl HostBlacklist -array-add"
# list banned sites
alias banls="defaults read org.eyebeam.SelfControl HostBlacklist"

# Trello CLI
# ---------------------------------------------------------------------------

trel() {
    trello show-cards -b "📥 Daily Kanban" -l '💣 Today'
    trello show-cards -b "📥 Daily Kanban" -l '🌆 Tonight'
    trello show-cards -b "📥 Daily Kanban" -l '🌅 Tomorrow'
    trello show-cards -b "📥 Daily Kanban" -l '📆 This week'
}

tred() {
    trello add-card "$1" -b "📥 Daily Kanban" -l '💣 Today'
}

tren() {
    trello add-card "$1" -b "📥 Daily Kanban" -l '🌆 Tonight'
}
# important label
tred!() {
    trello add-card "$1" -b "📥 Daily Kanban" -l '💣 Today' -g 5c56f3491be0121b5865f2d7
}

tren!() {
    trello add-card "$1" -b "📥 Daily Kanban" -l '🌆 Tonight' -g 5c56f3491be0121b5865f2d7
}
# TalTech label
tredt() {
    trello add-card "$1" -b "📥 Daily Kanban" -l '💣 Today' -g 5b7c3a417b03a914551de144
}

trent() {
    trello add-card "$1" -b "📥 Daily Kanban" -l '🌆 Tonight' -g 5b7c3a417b03a914551de144
}

tref() {
    trello add-card "$1" -b "📥 Daily Kanban" -l '📈 Further ahead'
}

# move to Done on "📥 Daily Kanban" board
trex() {
    trello move-card "$1" 5a785c3a56d2f82288d292e8
}

# Calculator
# ---------------------------------------------------------------------------
calc() {
    # use either + or p to sum
    local calc="${*//p/+}"
    # use x to multiply
    calc="${calc//x/*}"
    bc -l <<<"scale=10;$calc"
}

# Calendar
# ---------------------------------------------------------------------------
alias cala="gcalcli agenda --military --details=length --details=location"
alias calw="gcalcli calw --military --mon"
alias calm="gcalcli calm --military --mon"

# World clock
# ---------------------------------------------------------------------------
wcl() {
    TIME_ZONES=("America/Los_Angeles" "America/New_York" "Europe/Dublin" "Europe/London" "Europe/Rome" "Europe/Vienna" \
    "Europe/Tallinn" "Europe/Moscow" "Asia/Singapore")
    OUTPUT=""

    for loc in ${TIME_ZONES[@]}; do
        CITY=`echo $loc | sed 's/Los_Angeles/San_Francisco/g' | sed 's/Rome/Milan/g' | sed 's/\// /g' | awk '{ print $2 }'`
        CUR_TIME=`TZ=${loc} date | awk '{ print $2 " " $3 " " $5 }'`
        TEMP=`awk -v l="$CITY" -v t="$CUR_TIME" 'BEGIN { print l "\t" t }'`
        OUTPUT="${OUTPUT}\n${TEMP}"
    done

    echo $OUTPUT | column -t | tr '_' ' '
}

# Weather
# ---------------------------------------------------------------------------
# could change ?I to ?T to remove colour completely
alias met="curl -s \"wttr.in/$1?I\""

# String operations
# ---------------------------------------------------------------------------
# convert string to TITLE case
tc() {
    echo "$1" | python3 -c "print('$1'.title())"
}
# convert string to SENTENCE case
sc() {
    echo "$1" | python3 -c "print('$1'.capitalize())"
}

#############################################################################
# DEVELOPMENT
#############################################################################

# Editors
# ---------------------------------------------------------------------------

if [[ -n $SSH_CONNECTION ]]; then
    # for remote session
    export EDITOR='emacs -nw'
else
    # for local session
    export EDITOR='code'
fi

# VSCode
c() {
    if [[ $@ == "" ]]; then
        command code .
    else
        command code "$@"
    fi
}

# emacs
alias emacs="emacs -nw"
alias suemacs="sudo emacs -nw"

# crontab
alias cre="EDITOR=emacs crontab -e"

# zsh & dotfiles
alias zs="source $HOME/.zshrc"
alias zc="code $DOTFILES"
alias ze="emacs -nw $DOTFILES/.zshrc"
# pull dotfiles
zl() {
    current_dir=$(pwd)
    cd $DOTFILES
    git pull
    cd $current_dir
}

# npm and ESLint
# ---------------------------------------------------------------------------
# Initialise ESLint for simple tutorial JS projects
esi() {
    echo "\nnode_modules" >> .gitignore
    npm init -y
    npm i --save-dev eslint
    npm i --save-dev eslint-plugin-import
    npm i --save-dev eslint-config-airbnb-base
    npm i --save-dev eslint-plugin-only-warn
    ln -sv $PROJECTS/dotfiles/eslint/.eslintrc.json ./
    ga .
    gcm "Initialise ESLint"
    # eslint --init
}

# git
# ---------------------------------------------------------------------------
# git status
alias gs="git status"
# normal git log - with timestamps
alias glot="git log --graph --all"
# log with pretty graph
alias glo="git log --graph --oneline --all"
# git commit with message
alias gcm="git commit -m"
alias gc="git commit"
alias gb="git branch"
alias gchm="git checkout master"
alias gch="git checkout"
alias gl="git pull"
alias gp="git push origin --all"
alias ga="git add"
alias gcl="git clone"
alias gt="git tag"
alias gpt="git push origin --tags"
alias gmt='git mergetool'
# delete a emote tag
alias gptd="git push --delete origin"
alias gd="git diff"
alias gdt="git difftool"

# git global status to check if any repos need commits/pushes
ggs() {

    # colors for output
    red='\033[0;31m'
    yellow='\033[1;33m'
    green='\033[0;32m'
    # no color
    nc='\033[0m'

    # store current dir
    current_dir=$(pwd)

    # store names of git repos from $PROJECTS in an array
    repos=()
    while IFS= read -r line; do
        repos+=("$line")
    done < <(find $PROJECTS/ -name .git | sed 's/.git//')

    # navigate to each repo and echo status
    for repo in "${repos[@]}"; do
        cd ${repo}
        # ${PWD##*/} to get dir name w/o full path
        if [[ $(git diff) ]]; then
            echo "${red}${PWD##*/}: need to commit${nc}"
        elif git status | grep -q "Untracked files"; then
            echo "${red}${PWD##*/}: need to commit${nc}"
        elif git status | grep -q "Changes to be committed"; then
            echo "${red}${PWD##*/}: need to commit${nc}"
        elif git status | grep -q "branch is ahead"; then
            echo "${yellow}${PWD##*/}: need to push${nc}"
        else
            echo "${green}${PWD##*/}: up-to-date${nc}"
        fi
    done

    cd $current_dir

}

# Github
# ---------------------------------------------------------------------------
alias hi="hub issue"
alias hic="hub issue create -m"

# cht.sh
# ---------------------------------------------------------------------------
# cheat sheets
alias cht="cht.sh"
# for completions
fpath=($HOME/.oh-my-zsh/custom/plugins/cht.sh $fpath)

# python
# ---------------------------------------------------------------------------
alias pipi="pip install"
alias pipdep="pipdeptree"
alias pipu="pip uninstall"
alias pips="pip show"
# pip zsh completion
function _pip_completion {
    local words cword
    read -Ac words
    read -cn cword
    reply=( $( COMP_WORDS="$words[*]" \
               COMP_CWORD=$(( cword-1 )) \
               PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip

# SSH
# ---------------------------------------------------------------------------
# krupenja.net
alias sshk="ssh igor@krupenja.net"
alias fsk="sshfs root@krupenja.net:/ /Volumes/krupenja.net"
# Mount home dir on enos
alias fsitc="sshfs igkrup@enos.itcollege.ee:/home/igkrup /Volumes/enos"

#############################################################################
# LINUX
# must stay at the end of file
#############################################################################

case "$OSTYPE" in
    linux*)
        source $DOTFILES/zsh/.zsh_linux
esac
