# set environment for zsh

# 環境判定用定数定義
ENV_UNKNOWN=0
ENV_XTERM=1			# TeraTerm
ENV_PTERM=2			# pterm
ENV_RXVT_UNICODE=3		# rxvt-unicode
ENV_NETBSD_XTERM=4
ENV_NETBSD_CONSOLE=5
				# hurd: hurd-console
EID=$ENV_UNKNOWN		# 初期値

# 環境判定: $TERM の値とか
case "`uname -s`" in
    "Linux" )
	case "${TERM}" in
	    "xterm" )
		if [ ! -z "${SSH_TTY}" ]; then
		    EID=$ENV_XTERM
		elif [ -z "${XTERM_VERSION}" ]; then
		    EID=$ENV_PTERM
		fi
		;;
	    "rxvt-unicode" )
		EID=$ENV_RXVT_UNICODE
		;;
	esac
	;;
    "NetBSD" )
	case "${TERM}" in
	    "xterm" )
		EID=$ENV_NETBSD_XTERM
		;;
	    "vt100" )
		EID=$ENV_NETBSD_CONSOLE
		;;
	esac
	;;

esac

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

# Prompt
# PROMPT='[%m:%~] '
# PROMPT='[%m:%30<..<%~] '
FOLD_LENGTH=26
PROMPT='[%m:%$FOLD_LENGTH<.:<%~] '
# 時刻：LANG の値によって変わる
RPROMPT='%t'

#
# History
#
[ ! -d $HOME/.work ] && mkdir $HOME/.work
HISTFILE=~/.work/.zsh_histfile
HISTSIZE=10000
SAVEHIST=10000
# root のコマンドはヒストリに追加しない
if [ $UID = 0 ]; then
    unset HISTFILE
    SAVEHIST=0
fi
# 重複を記録しない
setopt hist_ignore_dups
# historyの共有
# setopt share_history
# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups
# スペースで始まるコマンド行はヒストリリストから削除
setopt hist_ignore_space
# ヒストリを呼び出してから実行する間に一旦編集可能
setopt hist_verify
# 余分な空白は詰めて記録
setopt hist_reduce_blanks
# 古いコマンドと同じものは無視
setopt hist_save_no_dups
# historyコマンドは履歴に登録しない
setopt hist_no_store
# 補完時にヒストリを自動的に展開 : predict-on と合わない？ # TEST
## setopt hist_expand
# 履歴をインクリメンタルに追加
setopt inc_append_history

#
# key binding
#
# emacs mode
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
# インクリメンタル検索
bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward
bindkey "\\ep" history-incremental-search-backward
bindkey "\\en" history-incremental-search-forward


#
# alias
#
# ex: use function
function rm-use-in-bin() {
    /bin/rm $@
}
# ls, cp
case $EID in
    $ENV_NETBSD_XTERM | $ENV_NETBSD_CONSOLE )
	alias ls='ls -lAFch'
	alias cp='cp -apR'
	;;
    * )
	alias ls='ls -lAFchv --color=auto'
	alias cp='cp -apr'
	;;
esac
alias m='make'
alias em='emacs'
alias od='od -tax1'
alias hexdump='hexdump -C'
alias g='git'
alias h='hg'
alias r='rake'
# rm: use $HOME/bin/rm

# 先方予測機能
autoload predict-on
predict-on
alias pon='predict-on'
alias poff='predict-off'
zstyle ':predict' verbose true

#
# 環境変数：自動エクスポート
#
set -a
PATH="$HOME/bin:$PATH"
PAGER='lv'
TZ="JST-9"
# LANG を設定 --> RPROMPT の表示
case $EID in
    $ENV_XTERM | $ENV_PTERM | $ENV_RXVT_UNICODE | $ENV_NETBSD_XTERM )
	LANG="ja_JP.UTF-8"
	;;
esac
# 自動エクスポート終了
set +a

#
# プロンプト表示直前用フック
#
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


#
# その他の設定
#
# 一定時間操作しないと自動的にログアウトする
TMOUT=3600


# 最後に・・・
# fortune cookie
if [ -x /usr/games/fortune ]; then
    echo "--[ fortune cookie ]-----------------------------------------------"
    /usr/games/fortune -a
    echo "-------------------------------------------------------------------"
fi
