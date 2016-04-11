#! /bin/bash

# スマフォ用にタグ情報を削除

# 今回は RadioServer 用

CONV="./conv2mp3.sh"
#OPT="--test"
OPT=""
OPT="${OPT} -b 64 -n 9 -r"


SRCDIR="src"
DSTDIR="dst"


for i in ${SRCDIR}/*; do
    _base="${i:4:$((${#i} - 4 - 4))}"
    _ofile="${DSTDIR}/${_base}.mp3"

    if [ ! -f "${_ofile}" ]; then
	${CONV} ${OPT} "$i" "${_ofile}"
    fi
done


echo "---- done ----"

exit 0
