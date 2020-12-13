#! /bin/bash


# -- ENV(export)
set -a
LANG=C
#http_proxy="http://127.0.0.1:3128/"
#https_proxy="https://127.0.0.1:3128/"
set +a

# -- ENV(not export)
# download directory
DEFAULT_DIR="Downloads"
DOWNLOAD_DIR="$HOME/${DEFAULT_DIR}"
# output directory
ODIR="${HOME}/${DEFAULT_DIR}"
# 認証関係ファイル/urlの保存先
TEMPDIR="/tmp"
AUTH1_FMS="${TEMPDIR}/auth1_fms_$$"
AUTH2_FMS="${TEMPDIR}/auth2_fms_$$"
# date command
CMDDATE="/bin/date"

# Radiko side settings
XRadikoApp="pc_html5"
XRadikoAppVersion="0.0.1"
XRadikoUser="test-stream"
XRadikoDevice="pc"
M3U8="/tmp/timeshift.m3u8.$$"
AUTHKEY="bcd151073c03b352e1ef2fd66c32209da9ca0afa"


# -- CONST
# JP13 (+1) only
# Station name for save
declare -A STATION_NAME=(
    ["INT"]="インターＦＭ"
    ["BAYFM78"]="ｂａｙ－ｆｍ"
    ["NACK5"]="ＮＡＣＫ５"
    ["FMT"]="ＴＯＫＹＯ－ＦＭ"
    ["FMJ"]="Ｊ－ＷＡＶＥ"
    ["YFM"]="ｆｍ　ｙｏｋｏｈａｍａ"
    ["TBS"]="ＴＢＳラジオ"
    ["QRR"]="文化放送(NCB)"
    ["LFR"]="ニッポン放送"
    ["JORF"]="ラジオ日本"
    ["JOAK"]="NHKラジオ第1（東京）"
    ["JOAB"]="NHKラジオ第2"
    ["JOAK-FM"]="NHK-FM（東京）"
    ["NHK-FM"]="ＮＨＫ－ＦＭ"
    ["NHK-R1"]="ＮＨＫ第一放送"
    ["NHK-R2"]="ＮＨＫ第二放送"
    ["RN1"]="ラジオNIKKEI第1"
    ["RN2"]="ラジオNIKKEI第2"
    ["HOUSOU-DAIGAKU"]="放送大学"
    ["AIR-G"]="AIR-G"
)
# key list only
declare STATION=(${!STATION_NAME[@]})

# -- Variables
CHANNEL=""
DATE=""
TIME=""
TERM=""
ST_TIME=""	# YYYYMMDDhhmmss
ED_TIME=""
FL_TIME=""	# to filename
AUTHTOKEN=""
TESTMODE=""
SAVENAMEBASE=""	# savename


# -- Function
# Usage
function _usage() {
    local pg

    pg="`basename $0`"
    cat <<EOF
usage:
  ${pg} [-t] [-w] CHANNEL WeekOfDay|StartDate StartTime Term [OutDir] [-t] [-n Name]

    CHANNEL    Station ID (JP13 only)
    WeekOfDay  Sun Mon Tue Wed Thu Fri Sat
    StartDate  YYYYMMDD  Day. YYYYMMDD YY/MM/DD MM/DD DD
    StartTime  start time. HH:MM HHMM
    Term       Lehgth of listen [00H]00[M] (default 30 sec.)
    OutDir     default ${ODIR}

    -w         wide 10 second, both start/end side
    -t         test, display start/end time
    -n Name    basename for save (BASENAME_STATION_YYMMDDHHMM)

    Station ID
      INT            InterFM897
      BAYFM78        bayfm
      NACK5          NACK5
      FMT            TOKYO FM
      FMJ            J-WAVE
      YFM            ＦＭヨコハマ
      TBS            TBSラジオ
      QRR            文化放送
      LFR            ニッポン放送
      JORF           ラジオ日本
      RN1            ラジオNIKKEI第1
      RN2            ラジオNIKKEI第2
      HOUSOU-DAIGAKU 放送大学
      JOAK           NHKラジオ第1（東京）
      JOAB           NHKラジオ第2
      JOAK-FM        NHK-FM（東京）
      AIR-G          AIR-G (if JP1)

    Week Of Day (Repeat: crontab format)
      0   1   2   3   4   5   6
      Sun Mon Tue Wed Thu Fri Sat
EOF
    exit 1
}


# check args: CHANNEL
function _get_channel() {
    local ch i

    ch="${1,,}"
    ch="${ch~~}"	# 大文字化
    for (( i = 0; i < ${#STATION[@]}; ++i )); do
	if [ "$ch" = "${STATION[ $i ]}" ]; then
	    CHANNEL="$ch"
	    return 0
	fi
    done

    echo "Error: channel miss match: ${ch}"
    return 1
}


# check args: WeekOfDay | MMDD
function _get_date_num() {
    local instr yyyy mm dd

    instr="$1"

    if [[ "$instr" =~ ^([0-9]*)\/([0-9]*)\/([0-9]*)$ ]]; then	# yyyy/mm/dd
	yyyy="${BASH_REMATCH[ 1 ]}"
	mm="${BASH_REMATCH[ 2 ]}"
	dd="${BASH_REMATCH[ 3 ]}"
	if [ 2000 -gt ${yyyy} ]; then
	    yyyy="$(expr ${yyyy} + 2000)"
	fi
	if [ ! 4 -eq ${#yyyy} ]; then
	    echo "Error: Year format: ${yyyy}"
	    return 1
	fi
    elif [[ "$instr" =~ ^([0-9]*)\/([0-9]*)$ ]]; then	# mm/dd
	yyyy="$($CMDDATE +%Y)"
	mm="${BASH_REMATCH[ 1 ]}"
	dd="${BASH_REMATCH[ 2 ]}"
    else					# mmdd or dd
	yyyy="$($CMDDATE +%Y)"
	dd="${instr:$(expr ${#instr} - 2):2}"
	if [ 2 -ge ${#instr} ]; then
	    mm="$($CMDDATE +%m)"
	else
	    mm="${instr::$(expr ${#instr} - 2)}"
	fi
    fi

    if [ $($CMDDATE +%Y) -lt ${yyyy} ]; then
	echo "Error: Year too large: ${yyyy}"
	return 1
    fi
    if [ $($CMDDATE +%Y) -gt ${yyyy} ]; then
	if [ ! 12 -eq ${mm} ]; then
	    echo "Error: Year too short: ${yyyy}"
	    return 1
	fi
    fi
    if [ 1 -gt ${mm} ]; then
	arg="$1"
	echo "Error: Month too short: ${mm}"
	return 1
    fi
    if [ 12 -lt ${mm} ]; then
	echo "Error: Month too large: ${mm}"
	return 1
    fi
    if [ 1 -gt ${dd} ]; then
	echo "Error: Day too short: ${dd}"
	return 1
    fi
    if [ 31 -lt ${dd} ]; then
	echo "Error: Day too large: ${dd}"
	return 1
    fi

    mm="00${mm}"
    mm="${mm:$(expr ${#mm} - 2):2}"
    dd="00${dd}"
    dd="${dd:$(expr ${#dd} - 2):2}"

    DATE="${yyyy}/${mm}/${dd}"
    return 0
}
function _get_date_wod() {
    local declare wods=( SUN MON TUE WED THU FRI SAT )
    local wod today i

    wod="${1,,}"
    wod="${wod^^}"	# 大文字化
    for (( i = 0; i < ${#wods[@]}; ++i )); do
	if [ "$wod" = "${wods[ $i ]}" ]; then
	    break
	fi
    done
    if [ ${#wods[@]} -le $i ]; then
	echo "Error: Bad Week of Date Name: $wod"
	return 1
    fi

    today="$($CMDDATE +%a)"
    today="${today^^}"	# 大文字化
    # 当日はそのまま。後で時刻を見て 7 日前にする
    if [ "$wod" = "$today" ]; then
	DATE="`$CMDDATE +%Y/%m/%d`"
    else
	DATE="`$CMDDATE --date=\"last $wod\" +%Y/%m/%d`"
    fi
    return 0
}
function _get_date() {
    local date

    date="$1"
    if [[ "$date" =~ ^[0-9\/]+$ ]]; then	# 数値＝＞日付指定
	_get_date_num $date
	return $?
    else					# 曜日指定
	_get_date_wod $date
	return $?
    fi
}


function _adj_datetime() {	# 当日の場合、時刻を見て 7 日戻す
    local today now hh mm

    hh=${TIME:0:2}

    # 24 時以降を翌日にする
    if [ 24 -le $hh ]; then
	DATE="`$CMDDATE --date \"$DATE next day\" '+%Y/%m/%d'`"
	hh="00$(($hh - 24))"
	hh="${hh:$(expr ${#hh} - 2):2}"
	TIME="${hh}${TIME:2:3}"
    fi

    # 当日以外は不要
    today="$($CMDDATE '+%Y/%m/%d')"
    if [ ! "$DATE" = "$today" ]; then
	return
    fi

    # 現在時刻より前が当日内。本来は録音終了時刻で見るべきかも
    now="$($CMDDATE '+%H:%M')"
    if [[ "$TIME" < "$now" ]]; then
	return
    fi

    # 当日の未来時刻なので、 1 週間前に戻す
    DATE="`$CMDDATE --date \"$DATE 7 days ago\" '+%Y/%m/%d'`"
}
function _get_time_num() {
    local time hh mm

    time="$1"
    if [ 3 -gt ${#time} ]; then
	echo "Error: too short: $time"
	return 1
    fi
    if [ 4 -lt ${#time} ]; then
	echo "Error: too long: $time"
	return 1
    fi
    if [ 3 -eq ${#time} ]; then
	time="0${time}"
    fi

    hh=${time:0: -2}
    mm=${time:${#time} - 2:2}

    if [ 30 -le ${hh} ]; then	# 29 時までは当日
	echo "Error: too large hour: $hh"
	return 1
    fi
    if [ 60 -le ${mm} ]; then
	echo "Error: too large min: $mm"
	return 1
    fi

    TIME="${hh}:${mm}"
    _adj_datetime

    return 0
}

function _get_time_colon() {
    local instr time hh mm

    instr="$1"
    if [[ "$instr" =~ ^([0-9]*):([0-9]*)$ ]]; then	# hh:mm
	hh="${BASH_REMATCH[ 1 ]}"
	mm="${BASH_REMATCH[ 2 ]}"
    else
	echo "Error: format: $instr"
	return 1
    fi

    if [ 30 -le ${hh} ]; then
	echo "Error: too large: $hh"
	return 1
    fi
    if [ 60 -le ${mm} ]; then
	echo "Error: too large: $mm"
	return 1
    fi

    hh="0${hh}"
    hh=${hh:${#hh} - 2:2}
    mm="0${mm}"
    mm=${mm:${#mm} - 2:2}

    TIME="${hh}:${mm}"
    _adj_datetime

    return 0
}
function _get_time() {
    local time

    time="$1"
    if [[ "$time" =~ ^[0-9]+$ ]]; then		# NNNN
	_get_time_num $time
	return $?

    elif [[ "$time" =~ ^[0-9:]+$ ]]; then	# NN:NN
	_get_time_colon $time
	return $?
    else			       		# other
	echo "Error: format: $time"
	return 1
    fi
}


function _get_term() {
    local term hh mm

    term="$1"
    term="${term^^}"	# 大文字化

    if [ -z "$term" ]; then			# default: 30 sec.
	TERM="30"
	return 0
    fi

    if [[ "$term" =~ ^([0-9]*)H(.*)$ ]]; then	# hour part
	hh="${BASH_REMATCH[ 1 ]}"
	term="${term#${hh}H}"
    fi
    if [[ "$term" =~ ^([0-9]*)M(.*)$ ]]; then	# minutes part
	mm="${BASH_REMATCH[ 1 ]}"
	term="${term#${mm}M}"
    fi

    if [[ "$term" =~ ^([0-9]+)$ ]]; then	# number only as minutes
	mm="$term"
	term="${term#${mm}}"
    fi

    if [ ! -z "$term" ]; then
	echo "Error: Term format: $1"
	return 1
    fi

    if [ -z "$hh" ]; then
	hh="0"
    fi
    if [ -z "$mm" ]; then
	mm="0"
    fi

    TERM="$((3600 * $hh + 60 * $mm))"
    return 0
}


function _wide_term() {
    DATE="`$CMDDATE --date \"$DATE $TIME 10 seconds ago\" '+%Y/%m/%d'`"
    TIME="`$CMDDATE --date \"$DATE $TIME 10 seconds ago\" '+%H:%M:%S'`"
    TERM="$(($TERM + 20))"
}


function _set_fltime() {
    FL_TIME="${DATE//\//}${TIME//:/}"
    FL_TIME="${FL_TIME:2}"
}


function _set_rectime() {
    ST_TIME="${DATE//\//}${TIME//:/}"
    ED_TIME="`$CMDDATE --date \"$DATE $TIME $TERM second\" '+%Y%m%d%H%M%S'`"
}

function _get_odir() {
    local dir

    dir="$1"
    if [ -z "${dir}" ]; then
	return 1
    fi
    if [ "-" = "${dir::1}" ]; then
	return 1
    fi
    if [ ! -d ${dir} ]; then
	echo "Error: wrong directory: ${dir}"
	return 2
    fi

    ODIR="${dir}"
    return 0
}



function _set_param() {
    local wd rc

    if [ 1 -gt $# ]; then
	_usage
    fi

    while (( $# > 0 )); do
	case "$1" in
	    '-h' | '-H' )
		_usage
		;;
	    '-t' | '-T' )
		TESTMODE="yes"
		;;
	    '-w' | '-W' )
		wd="yes"
		;;
	    *)
		break
		;;
	esac
	shift
    done

    if ! _get_channel "$1" ; then
	echo "Error: CHANNEL: $1"
	_usage
    fi
    shift
    if ! _get_date "$1" ; then
	echo "Error: DATE: $1"
	_usage
    fi
    shift
    if ! _get_time "$1" ; then
	echo "Error: TIME: $1"
	_usage
    fi
    shift
    if ! _get_term "$1" ; then
	echo "Error: TERM: $1"
	_usage
    fi
    shift
    TIME="${TIME}:00"		# add second part

    _get_odir "$1"
    rc=$?
    case ${rc} in
	0 )
	    shift
	    ;;
	1 )
	    ;;
	* )
	    echo "Error: TERM: $1"
	    _usage
    esac


    # 末尾に置かれたオプションの評価
    while (( $# > 0 )); do
	case "$1" in
	    '-t' | '-T' )
		TESTMODE="yes"
		;;
	    '-n' | '-N' )
		shift
		SAVENAMEBASE="$1"
		;;
	    '-h' | '-H' )
		_usage
		;;
	    *)
		break
		;;
	esac
	shift
    done

    _set_fltime

    if [ ! -z "$wd" ]; then
	_wide_term
    fi

    _set_rectime
}


# 認証
function _radiko_authorize() {
    local offset length partialkey areaid rc

    echo "==== authorize ===="

    # access auth1_fms
    wget \
	-q \
        --header="pragma: no-cache" \
        --header="X-Radiko-App: ${XRadikoApp}" \
        --header="X-Radiko-App-Version: ${XRadikoAppVersion}" \
        --header="X-Radiko-User: ${XRadikoUser}" \
        --header="X-Radiko-Device: ${XRadikoDevice}" \
        --save-headers \
	-O ${AUTH1_FMS} \
        https://radiko.jp/v2/api/auth1

    if [ $? -ne 0 ]; then
        echo "failed auth1 process"
        _atexit
        return 1
    fi
    #
    # get partial key
    #
    AUTHTOKEN=`perl -ne 'print $1 if(/x-radiko-authtoken: ([\w-]+)/i)' \
        ${AUTH1_FMS}`
    offset=`perl -ne 'print $1 if(/x-radiko-keyoffset: (\d+)/i)' ${AUTH1_FMS}`
    length=`perl -ne 'print $1 if(/x-radiko-keylength: (\d+)/i)' ${AUTH1_FMS}`
    partialkey=$(echo "${AUTHKEY}" \
			| dd bs=1 "skip=${offset}" "count=${length}" \
			     2> /dev/null | base64 \
	      )

    #
    # access auth2_fms
    #
    wget \
	-q \
        --header="pragma: no-cache" \
        --header="X-Radiko-User: ${XRadikoUser}" \
        --header="X-Radiko-Device: ${XRadikoDevice}" \
        --header="X-Radiko-Authtoken: ${AUTHTOKEN}" \
        --header="X-Radiko-Partialkey: ${partialkey}" \
	-O ${AUTH2_FMS} \
        https://radiko.jp/v2/api/auth2
    rc=$?
    if [ ${rc} -ne 0 -o ! -f ${AUTH2_FMS} ]; then
        echo "failed auth2 process"
        _atexit
        exit 1
    fi

    echo "==== authentication success ===="

    areaid=`perl -ne 'print $1 if(/^([^,]+),/i)' ${AUTH2_FMS}`
    echo "areaid: $areaid"

    return $rc
}


# 録音
function _radiko_record() {
    local ofile rc

    ofile="$1"
    if [ -e ${ofile} ]; then
	rm -f ${ofile}
    fi

    wget -q \
	 --header="pragma: no-cache" \
	 --header="Content-Type: application/x-www-form-urlencoded" \
	 --header="X-Radiko-AuthToken: ${AUTHTOKEN}" \
	 --header="Referer: http://radiko.jp/apps/js/flash/myplayer-release.swf" \
	 --post-data='flash=1' \
	 --no-check-certificate \
	 -O ${M3U8} \
	 "https://radiko.jp/v2/api/ts/playlist.m3u8?l=15&station_id=${CHANNEL}&ft=${ST_TIME}&to=${ED_TIME}"
    PLAYLIST_URL=`grep radiko ${M3U8}`
    ffmpeg -i ${PLAYLIST_URL} ${ofile} 2>&1 >/dev/null
    rc=$?

    return $rc
}


# -- main --------------------------------------------------------------
function _main() {
    local wdir ofile savefile

    _set_param "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
    if [ -z "${SAVENAMEBASE}" ]; then
	savefile="${ODIR}/${CHANNEL}_${FL_TIME}.aac"
    else
	savefile="${ODIR}/${SAVENAMEBASE}_${STATION_NAME[${CHANNEL}]}_${FL_TIME::10}.aac"
    fi
    if [ "yes" = "${TESTMODE}" ]; then
	local h m s
	s=$TERM
	h=$(($s / 3600))
	s=$(($s - 3600 * $h))
	m=$(($s / 60))
	s=$(($s - 60 * $m))
	h="0${h}"
	m="0${m}"
	s="0${s}"
	h=${h:${#h} - 2:2}
	m=${m:${#m} - 2:2}
	s=${s:${#s} - 2:2}

	echo "===="
	echo "CHANNEL:  ${STATION_NAME[${CHANNEL}]} (${CHANNEL})"
	echo "DATE:     $DATE (`$CMDDATE --date $DATE +%a`, $((`$CMDDATE --date $DATE +%u` % 7)))"
	echo "TIME:     ${FL_TIME:6:2}:${FL_TIME:9:2} (24h)"
	echo -n "LEHGTH:   $TERM Sec. ("
	if [ 0 -lt ${h} ]; then
	    echo -n "${h}h "
	fi
	if [ 0 -lt ${h} -o 0 -lt ${m} ]; then
	    echo -n "${m}m "
	fi
	echo "${s}s)"
	echo "SAVE_TO:  ${savefile}"
#	echo "ST_TIME:  $ST_TIME"
#	echo "ED_TIME:  $ED_TIME"
#	echo "SAVENAME: ${SAVENAMEBASE}"
	echo "===="
	return 0
    fi
    wdir=${DOWNLOAD_DIR}
    if [ ! -d "${wdir}" ]; then
	if ! mkdir -p ${wdir}; then
            echo "Cannot make directory: ${wdir}"
	    return 1
	fi
    fi

    if ! _radiko_authorize ; then
	echo "Fail: authorize"
	return 1
    fi


    if [ ! -d ${ODIR} ]; then
	echo "Error: output directory: ${ODIR}"
	return 1
    fi


    ofile="${ODIR}/${CHANNEL}_${FL_TIME}.aac"
    if ! _radiko_record "$ofile" ; then
	echo "Fail: record"
	return 1
    fi

    # 保存用ファイル名
    if [ ! -z "${SAVENAMEBASE}" ]; then
	if [ -f "$ofile" ]; then
	    mv "$ofile" "$savefile"
	fi
    fi


    # 後始末
    _atexit
    return 0
}


# at exit
function _atexit() {
    [ -e ${AUTH1_FMS} ] && rm -f ${AUTH1_FMS}
    [ -e ${AUTH2_FMS} ] && rm -f ${AUTH2_FMS}
    [ -e ${M3U8} ] && rm -f ${M3U8}
}
# CTRL+C is pressed, or other signals
trap "_atexit;  exit 1" HUP INT QUIT USR1 USR2

#_main $*	スペース区切りさせない様、クォートする（個々に）
_main "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
exit $?


