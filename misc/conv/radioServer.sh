#! /bin/bash

# RadioServer 用に mp3 変換
# どうせ wav ファイルを使うなら自前で良いじゃない

# env
SRCDIR="src"
DSTDIR="dst"
TEMPDIR="${DSTDIR}"
TEMPFILE="${TEMPDIR}/temp$$.wav"

mp="/usr/bin/mplayer"
mp_opt=""
lm="/usr/bin/lame"
lm_opt="-q 0 -a -b 32 -r"
rm="rm"

# do conv
# args: 1:infile 2:outfile 3:tempfile
function  _conv() {
    local -r _in="$1"
    local -r _out="$2"
    local -r _tmp="$3"
    local r

    echo " >>>> " \
    ${mp} ${mp_opt} -quiet -ao pcm:file="${_tmp}" "${_in}"
    r=$?
    if [ 0 -ne $r ] ;then
	${rm} "${_tmp}"
	return $r
    fi

    echo " >>>> " \
    ${lm} ${lm_opt} "${_tmp}" "${_out}"
    r=$?
    ${rm} "${_tmp}"
    return $r
}


# main entry
# args: 1:indir 2:outdir
function _entry() {
    local -r _src="$1"
    local -r _dst="$2"
    local r
    local i
    local _b
    local base
    local _ofile


    echo "---- entry: '$1' '$2' '$3'  "


    if [ ! -d "${_src}" ]; then
	echo "Error: Directory not exist: '${_src}'"
	return 1
    fi
    if [ ! -d "${_dst}" ]; then
	mkdir "${_dst}"
	r=$?
	if [ 0 -ne $r ] ;then
	    echo "ERROR: mkdir: '${_dst}'"
	    return $r
	fi
    fi

    for i in ${_src}/*; do
	_b=`basename "$i"`
	_base="${_b:0:$((${#_b} - 4))}"
	_ofile="${_dst}/${_base}.mp3"


	echo "++++ File: '$i'"


	if [ -d "$i" ]; then
	    _entry "${_src}/${_b}" "${_dst}/${_b}"

	elif [ -f "$i" -a ! -f "${_ofile}" ]; then
	    _conv "$i" "${_ofile}" "${TEMPFILE}"
	    r=$?
	    if [ 0 -ne $r ] ;then
		echo "ERROR: $r"
		return $r
	    fi
	fi
    done
}


# -- main -------------------------------------------------------
_entry "${SRCDIR}" "${DSTDIR}"
echo "---- done ----"
