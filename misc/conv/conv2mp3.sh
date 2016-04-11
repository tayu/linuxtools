#! /bin/sh

# ToDo:
#   title などのエスケープ
#     'title', "title" などとするとそのまま入る。
#     スペースなどのエスケープが必要となる（はず）
#     まぁ、そちらはラッパー側でやる。拡張子とかも。

# env
title=""
artist=""
album=""
year=""
comment=""
mono=""
bitrate=""
infile=""
outfile=""
quiet=""
silent=""
brief=""
verbose=""
noise=""

mp="/usr/bin/mplayer"
mp_opt=""
lm="/usr/bin/lame"
lm_opt=""

test=""

# error
USAGE() {
    cat <<-EOF
usage: `/usr/bin/basename $0` [-o|--option] infile outfile
   infile: input file. wmp mp3 etc.
  outfile: output file. mp3
   option:
     t|title:   audio/song title (max 30 chars for version 1 tag)
     a|artist:  audio/song artist (max 30 chars for version 1 tag)
     l|album:   audio/song album (max 30 chars for version 1 tag)
     y|year:    audio/song year of issue (1 to 9999)
     c|comment: user-defined text (max 30 chars for v1 tag, 28 for v1.1)

     m|mono:    mono encoding
     b|bitrate: set the bitrate in kbps, default 128 kbps
       MPEG-1   layer III sample frequencies (kHz):  32  48  44.1
       bitrates (kbps): 32 40 48 56 64 80 96 112 128 160 192 224 256 320

       MPEG-2   layer III sample frequencies (kHz):  16  24  22.05
       bitrates (kbps):  8 16 24 32 40 48 56 64 80 96 112 128 144 160

       MPEG-2.5 layer III sample frequencies (kHz):   8  12  11.025
       bitrates (kbps):  8 16 24 32 40 48 56 64

     n|noise:   Noise shaping & psycho acoustic algorithms:
         <arg>        <arg> = 0...9.  Default  -q 5
         0:  Highest quality, very slow
         9:  Poor quality, but fast

     q|quiet:   don't print anything on screen
     s|silentt: don't print anything on screen, but fatal errors
     r|brief:   print more useful information
     v|verbose: print a lot of useful information

     test:      show command line
EOF
    exit 1
}


# eval args
while [ 0 -lt $# ]; do
    case $1 in
	-a | --artist )
	    shift
	    artist="$1"
	    shift
	    ;;
	-b | --bitrate )
	    shift
	    bitrate="$1"
	    shift
	    ;;
	-c | --comment )
	    shift
	    comment="$1"
	    shift
	    ;;
	-l | --album )
	    shift
	    album="$1"
	    shift
	    ;;
	-m | --mono )
	    mono="yes"
	    shift
	    ;;
	-n | --noise )
	    shift
	    noise="$1"
	    shift
	    ;;
	-q | --quiet )
	    quiet="yes"
	    shift
	    ;;
	-r | --brief )
	    brief="yes"
	    shift
	    ;;
	-s | --silent )
	    silent="yes"
	    shift
	    ;;
	-t | --title )
	    shift
	    title="$1"
	    shift
	    ;;
        -v | --verbose )
	    verbose="yes"
	    shift
	    ;;
        -y | --year )
            shift
            year="$1"
            shift
            ;;
        --test )
	    test="yes"
	    shift
	    ;;
        -* | --* )
	    USAGE
	    ;;
        * )
	    infile="$1"
	    shift
	    outfile="$1"
	    shift
	    ;;
    esac
done


# check args
if [ -z "${infile}" ]; then
    USAGE
fi
if [ -z "${outfile}" ]; then
    USAGE
fi


# make option for lame
if [ ! -z "${title}" ]; then
    lm_opt="${lm_opt} --tt ${title}"
fi
if [ ! -z "${artist}" ]; then
    lm_opt="${lm_opt} --ta ${artist}"
fi
if [ ! -z "${album}" ]; then
    lm_opt="${lm_opt} --tl ${album}"
fi
if [ ! -z "${year}" ]; then
    lm_opt="${lm_opt} --ty ${year}"
fi
if [ ! -z "${comment}" ]; then
    lm_opt="${lm_opt} --tc ${comment}"
fi
if [ ! -z "${mono}" ]; then
    lm_opt="${lm_opt} -m m"
fi
if [ ! -z "${quiet}" ]; then
    lm_opt="${lm_opt} --quiet"
fi
if [ ! -z "${silent}" ]; then
    lm_opt="${lm_opt} --silent"
fi
if [ ! -z "${brief}" ]; then
    lm_opt="${lm_opt} --brief"
fi
if [ ! -z "${verbose}" ]; then
    lm_opt="${lm_opt} --verbose"
fi
if [ ! -z "${bitrate}" ]; then
    lm_opt="${lm_opt} -b ${bitrate}"
fi
if [ ! -z "${noise}" ]; then
    lm_opt="${lm_opt} -q ${noise}"
fi


# main
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

