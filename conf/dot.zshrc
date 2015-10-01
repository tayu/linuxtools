# set environment for zsh

# 環境毎の TERM の値識別用
# UTF-8: TeraTerm xterm pterm mlterm linux hurd
TERM_XTERM="xterm"	# xterm or TeraTerm (see SSH_TTY)
TERM_RXVT_UNICODE="rxvt-unicode" # rxvt-unicode
                        # 以下は設定しない。システムデフォルト
TERM_MLTERM="mlterm"	# mlterm
TERM_KTERM="kterm"	# KTerm
TERM_RXVT="rxvt"	# rxvt
TERM_LINUX="linux"	# console
TERM_HURD="hurd"	# GNU-HURD console
                        # ToDo: NetBSD OpenBSD DragonFry kFreeBSD Plan9


# Screen: os/console/TeraTerm(ssh)
# $TERM を見てプロンプトを切り替える
# $LANG は検討中
# $TERM:
#   debian-hurd-i386 console: mach-color
#   debian console: linux

# Prompt
# PROMPT='[%m:%~] '
# PROMPT='[%m:%30<..<%~] '
FOLD_LENGTH=26
PROMPT='[%m:%$FOLD_LENGTH<.:<%~] '
# 時刻：LANG の値によって変わる
RPROMPT='%t'


# History
HISTFILE=~/.work/.zsh_histfile
HISTSIZE=1000
SAVEHIST=1000
# root のコマンドはヒストリに追加しない
if [ $UID = 0 ]; then
    unset HISTFILE
    SAVEHIST=0
fi
setopt hist_ignore_dups
# setopt share_history


# key binding
bindkey -e
setopt prompt_subst
autoload -Uz compinit
compinit -d $HOME/.work/.zcompdump
setopt hist_expand
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end



# alias
## rm
function rm-use-in-bin() {
    /bin/rm $@
}
alias ls='ls -lAFchv --color=auto'
alias cp='cp -apr'
alias m='make'
alias em='emacs'
alias od='od -tax1'
alias hexdump='hexdump -C'


# 環境変数：自動エクスポート
set -a
PATH="$HOME/bin:$PATH"
PAGER='lv'
TZ="JST-9"
# LANG を設定 --> RPROMPT の表示
case "${TERM}" in
    $TERM_XTERM )
	if [ ! -z "${SSH_TTY}" ]; then
	    LANG="ja_JP.UTF-8"          # TeraTerm
	elif [ -z "${XTERM_VERSION}" ]; then
	    LANG="ja_JP.UTF-8"          # pterm
	fi
	;;
    $TERM_RXVT_UNICODE )
	LANG="ja_JP.UTF-8"              # rxvt
	;;
esac
# 自動エクスポート終了
set +a

## 一定時間操作しないと自動的にログアウトする
TMOUT=3600

# プロンプト表示直前に仕掛ける
precmd () {
  # コマンドが失敗したらビープを鳴らす
  # やめ
#  if [ $? != 0 ]; then
#    echo -n \\a
#  fi

# 長すぎる場合はフルにしない
#  if [ ${FOLD_LEN} -lt ${#PWD} ]; then
#    PROMPT='[::%c] '
#  fi

}


# fortune cookie
if [ -x /usr/games/fortune ]; then
    echo "--[ fortune cookie ]-----------------------------------------------"
    /usr/games/fortune
    echo "-------------------------------------------------------------------"
fi
