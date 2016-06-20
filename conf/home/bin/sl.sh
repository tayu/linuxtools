#! /bin/bash

OPTS=( a l F c )
SL="$HOME/build/sl/sl"

OPT=""
for i in ${OPTS[*]}; do
    if [ "0" = "`expr $RANDOM % 2`" ]; then
	OPT="${OPT}$i"
    fi
done
if [[ ! -z "$OPT" ]]; then
    OPT="-${OPT}"
fi
#echo \
$SL $OPT
