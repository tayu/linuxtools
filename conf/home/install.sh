#! /bin/sh

# 環境設定

DRYRUN="yes"

CONFHOME=$PWD

# util
## check dry-run: no argument: return 0(yes) or 1(no)
_DryRunP() {
    if [ "YES" = "${DRYRUN}" ]; then
	return 0
    fi
    if [ "Yes" = "${DRYRUN}" ]; then
	return 0
    fi
    if [ "yes" = "${DRYRUN}" ]; then
	return 0
    fi
    return 1
}


## make symlink: _Make_Symlink src dst
_Make_Symlink() {

    if [ -z "$1" ]; then
	echo "Symlink: Error: no source"
	return 1
    fi
    if [ -z "$2" ]; then
	echo "Symlink: Error: no destination"
	return 1
    fi

    if _DryRunP ; then
	echo "Dry-Run: ln -sf $1 $2"
	return 0
    fi
    echo "do: ln -sf $1 $2"
    ln -sf $1 $2
}


## make directory: _Make_Dir dir
_Make_Dir() {
    if _DryRunP ; then
	echo "Dry-Run: mkdir -p $1"
	return 0
    fi
    echo "do: mkdir -p $1"
    mkdir -p $1
}


## make elc: _Make_Elc path/.el
_Make_Elc() {
    _p=`dirname $1`
    _f=`basename $1`
    (
	cd ${_p}
	if _DryRunP ; then
	    echo "Dry-Run: el2elc.el $PWD/${_f}"
	    return 0
	fi
	echo "do: el2elc.el $PWD/${_f}"
	el2elc.el ${_f}
    )
}



# zsh
_SetZsh() {
    echo "Set: zsh"
    (
	cd
	_Make_Symlink ${CONFHOME}/dot.zshrc .zshrc
    )
}


# Wget
_SetWget() {
    echo "Set: Wget"

    if [ "rsv" = "`hostname`" ]; then
	echo "Not Do: wgetrc"
    else
	(
	    cd
	    _Make_Symlink ${CONFHOME}/dot.wgetrc .wgetrc
	)
    fi
}


# Mercurial
_SetMercurial() {
    echo "Set: Mercurial"
    (
	cd
	_Make_Symlink ${CONFHOME}/dot.hgrc .hgrc
    )
}

# Git
_SetGit() {
    echo "Set: Git"
    (
	cd
	_Make_Symlink ${CONFHOME}/dot.gitconfig .gitconfig
    )
}


# Emacs
_SetEmacs() {
    echo "Set: Emacs"
    (
	cd
	_Make_Dir .emacs.d
	_Make_Symlink ${CONFHOME}/dot.emacs.d/init.el .emacs.d/init.el
	_Make_Dir .conf/site-lisp/
	_Make_Symlink ${CONFHOME}/dot.conf/site-lisp/m-mode.el .conf/site-lisp/m-mode.el
	_Make_Elc .emacs.d/init.el
	_Make_Elc .conf/site-lisp/m-mode.el
    )
}


# $HOME/bin
_SetHomeBin() {
    echo "Set: ~/bin"
    [ ! -d ${HOME}/bin ]; mkdir ${HOME}/bin
    (
	cd
	_Make_Dir bin
	for i in ${CONFHOME}/bin/*; do
	    chmod u+x $i
	    _Make_Symlink $i bin/`basename $i`
	done
    )
}

_main() {
    echo "Create settings ..."
    # Zwh
    _SetZsh
    # ~/bin
    _SetHomeBin
    # Wget
    _SetWget
    # Mercurial - 分散構成管理ツール
    _SetMercurial
    # Git
    _SetGit
    # Emacs
    _SetEmacs

    # cron: ../cron

}
_main $*
exit $?
