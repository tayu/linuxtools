#! /bin/sh

# 却って扱いが難しいので、引数部分を簡略化する

mp="/usr/bin/mplayer"
mp_opt=""
lm="/usr/bin/lame"
lm_opt=""

test=""
opt=""

# error
USAGE() {
    cat <<-EOF
usage: `/usr/bin/basename $0` [options [--test]] infile  utfile
  options: options for lame
   infile: input file. wmp mp3 etc.
  outfile: output file. mp3
   --test: show command line. and exit.
EOF
    exit 1
}




# -- main --------------------------------------------------------
[ 0 -eq $# ] && USAGE
while [ 2 -lt $# ]; do

    if [ "--test" = "$1" ]; then
	test="1"
    else
	opt="${opt} $1"
    fi
    shift
done
lm_opt="${opt}"
infile="$1"
outfile="$2"

if [ -z "${infile}" -o ! -e "${infile}" ]; then
    echo "Error: Not Exist: Input File: ${infile}"
    exit 1
fi
if [ -z "${outfile}" ]; then
    echo "Error: Not Exist: Output File: ${outfile}"
    exit 1
fi

if [ ! -z "${test}" ]; then
    cat <<EOF
${mp} \
    ${mp_opt} -really-quiet -ao pcm:file=/dev/stdout "${infile}" \
    2>/dev/null \
    | \
    ${lm} ${lm_opt} /dev/stdin "${outfile}"
EOF
else
    ${mp} \
	${mp_opt} -really-quiet -ao pcm:file=/dev/stdout "${infile}" \
	2>/dev/null \
	| \
	${lm} ${lm_opt} /dev/stdin "${outfile}"

fi

exit $?

