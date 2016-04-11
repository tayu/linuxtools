#! /bin/bash

# とにかく mp3 変換 for スマフォ

# 今回は RadioServer 用

CONV="./conv2mp3.sh"
#OPT="--test"
OPT=""
OPT="${OPT} -b 32 -m -n 0 -r"


SRCDIR="src"
DSTDIR="dst"


for i in ${SRCDIR}/*; do
    _base="${i:4:$((${#i} - 4 - 4))}"
    _ofile="${DSTDIR}/${_base}.mp3"
    if [ ! -f "${_ofile}" ]; then
	${CONV} ${OPT} "$i" "${_ofile}"
	if [ 0 -ne $? ] ;then
	    echo "ERROR: $?"
	fi
    fi
done


echo "---- done ----"

exit 0
