# The following lines were added by compinstall
zstyle :compinstall filename '/home/alex/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=2000
SAVEHIST=2000
bindkey -v
# End of lines configured by zsh-newuser-install

# >> X4 INIT
set -uo pipefail
printf "A>* X4 init...\n"
local_home="${X4_LOCAL:="$HOME/Local"}"
config="${X4_CONFIG:="$local_home/config"}"
misc="${X4_MISC:="$local_home/misc"}"
zsh_config="${X4_ZSH_CONFIG:="$X4_CONFIG/zsh"}"
printf "I>* Shell: zsh\n"
printf "I>* Local: $local_home\n"
printf "I>* Config: $zsh_config\n"

# >>> antidote
# https://antidote.sh/install
printf "A># Init antidote plugin manager...\n"
antidote_home="$misc/antidote"
zsh_plugins="$zsh_config/plugins"
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt
fpath=("$antidote_home/functions" $fpath)
autoload -Uz antidote
printf "A># Loading antidote plugins...\n"
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi
printf "S># Load antidote plugins ok!\n"
printf "S># Init antidote ok!\n"

# >>> sources
printf "A># Including sources...\n"
sources_delim="$zsh_plugins.zsh;${X4_ZSH_SOURCES:="$X4_ZSH_CONFIG/aliases.zsh;$HOME/.asdf/asdf.sh"}"
sources=($(printf %s "$sources_delim" | tr ';' '\n'))
for source in $sources; do
    if [[ ! -f "$source" ]]; then
        printf "!>W Missing configured source. Skipping include. [fs:$source]\n"
        continue
    fi
    printf "T># Including source [fs:$source]... "
    . "$source"
    printf "ok!\n"
done
printf "S># Include sources ok!\n"

# >>> asdf
# https://asdf-vm.com/guide/getting-started.html
printf "A># Checking tools...\n"
printf "A># Checking asdf plugins...\n"
plugins=($(printf %s "${X4_ASDF_PLUGINS:="golang;rust;python;just;ripgrep;fzf;bat;helix:https://github.com/nklmilojevic/asdf-helix.git"}" | tr ';' '\n'))
for plugin in $plugins; do
    eval "asdf plugin add $(printf %s "$plugin" | sed 's/:/ /') 1> /dev/null"
done
printf "S># Check asdf plugins ok!\n"
printf "A># Checking asdf tools...\n"
asdf install
printf "S># Check asdf tools ok!\n"
printf "S># Check tools ok!\n"

# >>> croq
# https://github.com/voidxela/croq
printf "A># Init croq...\n"
which croq 1> /dev/null
if [[ "$?" != "0" ]]; then
    printf "A># Installing croq...\n"
    cargo install --git https://github.com/voidxela/croq croq
    if [[ "$?" != "0" ]]; then
        printf "W>! Unable to install croq!\n"
    else
        asdf reshim rust
        printf "S># Install croq ok!\n"
    fi
fi
CRAQ_WARN_MISSING_INFO=0 eval "$(croq init zsh)"
if [[ "$?" != "0" ]]; then
    printf "W># Unable to init croq!\n"
else
    printf "S># Init croq ok!\n"
fi

set +u
printf "S>* X4 init ok!\n"
clear
printf "X4>> Welcome to zsh!\n"
# >> END X4 INIT
