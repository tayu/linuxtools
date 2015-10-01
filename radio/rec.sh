#! /bin/bash

# CTRL+C is pressed, or other signals
trap "_atexit;  exit 1" HUP INT QUIT USR1 USR2

# env(export)
set -a
# use http proxy for wget
http_proxy="http://127.0.0.1:3128/"
set +a

# default download directory
default_dir="Downloads"
download_dir="$HOME/${default_dir}"

# 変数
authtoken=""
stname=""
retry_limit="1"

# version
VERSION=3.0.0.01

# 認証関係ファイル/urlの保存先
keydir="$HOME/.radiko"
tempdir="/tmp"
keyfile="${keydir}/authkey.jpg"
playerfile="${keydir}/player.swf"
auth1_fms="${tempdir}/auth1_fms_$$"
auth2_fms="${tempdir}/auth2_fms_$$"
playerurl="http://radiko.jp/player/swf/player_${VERSION}.swf"
# 余白
filler="60"

# ページ表示
if [ ! -z "$PAGER" ]; then
    pager="$PAGER"
else
    pager="/bin/more"
fi

# 使い方
function usage() {
    cat <<EOF
Usage: $COMMAND [-a] [-o output_path] [-t recording_seconds] station_ID
  -a  エリア情報を出力して終了 (ex:'JP13, tokyo Japan')
  -d  出力ディレクトリ名 (デフォルトは \$HOME/${default_dir})
  -f  出力ファイル名 (デフォルトは STATION_YYYYMMDD-hhmm.flv)
  -h  時刻指定(ファイル名に設定)
  -l  番組リスト(radiko は JP13)
  -n  番組名(ファイル名に設定)
  -r  リトライ回数
  -t  録音時間 (秒または HMS) (デフォルトは 30秒)
  -w  開始時に（少し）待つ(秒)
EOF
}

# リスト
function show_list() {
    cat | ${pager} <<EOF
放送局一覧
  FM
    INT     InterFM
    BAYFM78 bayfm78
    NACK5   NACK5
    FMT     TOKYO FM
    FMJ     J-WAVE
    YFM     ＦＭヨコハマ
  AM
    TBS     TBS
    QRR     文化放送
    LFR     ニッポン放送
    JORF    ラジオ日本
  短波
    RN1     ラジオNIKKEI第1
    RN2     ラジオNIKKEI第2
  NHK
    NHK-FM  ＮＨＫ－ＦＭ
    NHK-R1  ＮＨＫ第一放送
    NHK-R2  ＮＨＫ第二放送
  サイマルラジオ
    (Now on making)
EOF
}


# at exit
function _atexit() {
    [ -e ${auth1_fms} ] && rm -f ${auth1_fms}
    [ -e ${auth2_fms} ] && rm -f ${auth2_fms}
}


# 放送局名
function get_station_name() {
    stname=`echo $1 | awk '
    BEGIN {
	station[ "INT" ]      = "インターＦＭ";
	station[ "BAYFM78" ]  = "ｂａｙ－ｆｍ";
	station[ "NACK5" ]    = "ＮＡＣＫ５";
	station[ "FMT" ]      = "ＴＯＫＹＯ－ＦＭ";
	station[ "FMJ" ]      = "Ｊ－ＷＡＶＥ";
	station[ "YFM" ]      = "ｆｍ　ｙｏｋｏｈａｍａ";
	station[ "TBS" ]      = "ＴＢＳラジオ";
	station[ "QRR" ]      = "文化放送(NCB) ";
	station[ "LFR" ]      = "ニッポン放送";
	station[ "JORF" ]     = "ラジオ日本";
	station[ "NHK-FM" ]   = "ＮＨＫ－ＦＭ";
	station[ "NHK-R1" ]   = "ＮＨＫ第一放送";
	station[ "NHK-R2" ]   = "ＮＨＫ第二放送";
	station[ "RN1" ]      = "ラジオNIKKEI第1";
	station[ "RN2" ]      = "ラジオNIKKEI第2";
    }
    {
	name = station[ $1 ]
	if ( 0 == length( name ) ) {
	    printf( "(none)" );
	} else {
	    printf( "%s", name );
	}
    }
'`
}



# 放送局名
function hms2second() {
    local tm=$1
    local sec
    sec=`echo $tm | awk '
{
    t = 0;
    tm = 0;
    for ( i = 0; i <= length( $0 ); ++i ) {
	c = toupper( substr( $0, i, 1 ) );
	if ( "0" <= c && c <= "9") {
	    t = t * 10 + c;
	} else if ( "H" == c ) {
	    tm = tm + t * 3600;
	    t = 0;
	} else if ( "M" == c ) {
	    tm = tm + t * 60
	    t = 0;
	} else if ( "S" == c ) {
	    tm = tm + t
	    t = 0;
	    break;
	}
    }
    tm = tm + t
    printf( "%d", tm );
}
'`
    echo "$sec"
}



# 認証
function radiko_authorize() {
    local offset length partialkey areaid rc

    echo "==== authorize ===="

    # ディレクトリ：認証キー
    if [ ! -d "${keydir}" ]; then
	if ! mkdir -p ${keydir}; then
	    echo "Cannot make directory: ${keydir}"
	    exit 1
	fi
    fi
    #
    # get player
    #
    if [ ! -f $playerfile ]; then
	echo "$playerfile downloading..."
	wget -O $playerfile $playerurl
	if [ $? -ne 0 ]; then
	    echo "failed get player"
	    [ -f $playerfile ] && rm $playerfile
	    exit 1
	fi
    fi

    #
    # get keydata (need swftool)
    #
    if [ ! -f $keyfile ]; then
	echo $keyfile extracting...
	swfextract -b 14 $playerfile -o $keyfile
	if [ ! -f $keyfile ]; then
	    echo "failed get keydata"
	    exit 1
	fi
    fi

    #
    # access auth1_fms
    #
    wget -q \
	--header="pragma: no-cache" \
	--header="X-Radiko-App: pc_1" \
	--header="X-Radiko-App-Version: $VERSION" \
	--header="X-Radiko-User: test-stream" \
	--header="X-Radiko-Device: pc" \
	--post-data='\r\n' \
	--no-check-certificate \
	--save-headers \
	https://radiko.jp/v2/api/auth1_fms -O ${auth1_fms}

    if [ $? -ne 0 ]; then
	echo "failed auth1 process"
	exit 1
    fi

    #
    # get partial key
    #
    authtoken=`perl -ne 'print $1 if(/x-radiko-authtoken: ([\w-]+)/i)' \
	${auth1_fms}`
    offset=`perl -ne 'print $1 if(/x-radiko-keyoffset: (\d+)/i)' ${auth1_fms}`
    length=`perl -ne 'print $1 if(/x-radiko-keylength: (\d+)/i)' ${auth1_fms}`
    partialkey=`dd if=$keyfile bs=1 skip=${offset} count=${length} \
	2>/dev/null \
	| base64`

    #
    # access auth2_fms
    #
    wget -q \
	--header="pragma: no-cache" \
	--header="X-Radiko-App: pc_1" \
	--header="X-Radiko-App-Version: $VERSION" \
	--header="X-Radiko-User: test-stream" \
	--header="X-Radiko-Device: pc" \
	--header="X-Radiko-Authtoken: ${authtoken}" \
	--header="X-Radiko-Partialkey: ${partialkey}" \
	--post-data='\r\n' \
	--no-check-certificate \
	https://radiko.jp/v2/api/auth2_fms -O ${auth2_fms}
    rc=$?

    if [ $? -ne 0 -o ! -f ${auth2_fms} ]; then
	echo "failed auth2 process"
	exit 1
    fi

    echo "==== authentication success ===="

    areaid=`perl -ne 'print $1 if(/^([^,]+),/i)' ${auth2_fms}`
    echo "areaid: $areaid"

    return $rc
}


# 録音: radiko
function radiko_record() {
    local URLLINE RMTP APP PLAYPATH rc

    echo "==== recording ===="
    #
    # get stream-url & get authtoken
    #
    URLLINE=($(wget -q \
	"http://radiko.jp/v2/station/stream/${channel}.xml" -O - \
	| xpath -q -e '//url/item[1]/text()' \
	| perl -pe 's!^(.*)://(.*?)/(.*)/(.*?)$/!$1://$2/ $3 $4!'))
    RMTP="${URLLINE[0]}"
    APP="${URLLINE[1]}"
    PLAYPATH="${URLLINE[2]}"
    #
    # rtmpdump
    #
    # WARNING が出る
    echo "save to '$output'"
    rtmpdump \
	--rtmp ${RMTP} \
	--app ${APP} \
	--playpath ${PLAYPATH} \
	-C S:"" -C S:"" -C S:"" -C S:${authtoken} \
	-W $playerurl \
	--live \
	--stop "${rectime}" \
	--flv "${output}"
    rc=$?
    if [ ! -z "${oname}" ]; then
	mv ${output} "`dirname ${output}`/${oname}"
    fi
    return $rc
}


# 録音: NHK
# WARNING が 2 個出る
# mplayer のみでも可能らしい: https://gist.github.com/matchy2/5310409
function radiko_nhk() {
    local PLAYPATH ID rc

    PLAYPATH="$1"
    ID="${channel##*-}"
    ID="${ID,,}" # 小文字にしておく

    echo "==== recording ===="
    echo "save as '$output'"

    rtmpdump --rtmp "rtmpe://netradio-${ID}-flash.nhk.jp" \
	--playpath "${PLAYPATH}" \
	--app "live" \
	-W http://www3.nhk.or.jp/netradio/files/swf/rtmpe.swf \
	--live \
	--stop "${rectime}" \
	-o "${output}"
    rc=$?

    if [ ! -z "${oname}" ]; then
	mv ${output} "`dirname ${output}`/${oname}"
    fi

    return $rc
}


#
# -- main -----------------------------------------------------------
#

# 引数解析
COMMAND=`basename $0`
while getopts ad:f:h:ln:r:t:w: OPTION; do
    case $OPTION in
	a )
	    OPTION_a="TRUE"
	    ;;
	d )
	    OPTION_d="TRUE"
	    VALUE_d="$OPTARG"
	    ;;
	f )
	    OPTION_f="TRUE"
	    VALUE_f="$OPTARG"
	    ;;
	h )
	    OPTION_h="TRUE"
	    VALUE_h="$OPTARG"
	    ;;
	l )
	    OPTION_l="TRUE"
	    ;;
	n )
	    OPTION_n="TRUE"
	    VALUE_n="$OPTARG"
	    ;;
	r )
	    OPTION_r="TRUE"
	    VALUE_r="$OPTARG"
	    ;;
	t )
	    OPTION_t="TRUE"
	    VALUE_t="$OPTARG"
	    ;;
	w )
	    OPTION_w="TRUE"
	    VALUE_w="$OPTARG"
	    ;;
	* )
	    usage
	    exit 1
	    ;;
    esac
done

shift $(($OPTIND - 1))  # 残りの非オプションな引数のみが、$@に設定される

# 残りのオプションはチャンネルのみ
channel=$1



# オプション処理: 指定できる放送局一覧
if [ "TRUE" = "$OPTION_l" ]; then
    show_list
    exit 1
fi

# オプション処理: エリアチェック
if [ "TRUE" = "$OPTION_a" ]; then
    radiko_authorize && cat ${auth2_fms} | grep -e '^\w\+'
    _atexit
    exit 0
fi

# 引数チェック: 放送局指定が無い
if [ -z "$channel" ]; then
    usage
    exit 1
fi

# オプション処理: ディレクトリ名
if [ "$OPTION_d" = "TRUE" ]; then
    wdir="${VALUE_d}"
else
    wdir=${download_dir}
fi

# オプション処理: ファイル名
if [ "$OPTION_f" = "TRUE" ]; then
    oname=`basename $VALUE_f`
fi
fname="${channel}_`date +%Y%m%d-%H%M`.flv"

# オプション処理: 番組名, 時刻表記　-f を上書き
if [ "$OPTION_n" = "TRUE" -a "$OPTION_h" = "TRUE" ]; then
    get_station_name $channel
    datetime="`date +%y%m%d`"
    oname="${VALUE_n}_${stname}_${datetime}${VALUE_h}.flv"
fi

# オプション処理: リトライ回数
if [ "$OPTION_r" = "TRUE" ]; then
    retry_limit="${VALUE_r}"
fi

# オプション処理: 開始時待ち
if [ "$OPTION_w" = "TRUE" ]; then
    waits="${VALUE_w}"
else
    waits=0
fi

# オプション処理: 録音時間
if [ "$OPTION_t" = "TRUE" ]; then
    rectime="`hms2second $VALUE_t`"
    rectime=`expr ${rectime} + ${filler} - ${waits}`
else
    rectime=30
fi

# 引数解析：終了

# 開始時ウエイト
sleep ${waits}

# ディレクトリ：出力先
if [ ! -d "${wdir}" ]; then
    if ! mkdir -p ${wdir}; then
	echo "Cannot make directory: ${wdir}"
    fi
fi

# 出力ファイル名: 第一回
output="${wdir}/${fname}"


# メイン
retry_count=0
st="`date +%s`"
ed="`expr $st + $rectime`"
while [ $st -lt $ed ]; do
    case ${channel} in
	NHK-R1)  # ラジオ第1
	    radiko_nhk "NetRadio_R1_flash@63346"
	    ;;
	NHK-R2)  # ラジオ第2
	    radiko_nhk "NetRadio_R2_flash@63342"
	    ;;
	NHK-FM)  # NHK-FM
	    radiko_nhk "NetRadio_FM_flash@63343"
	    ;;
	* )
	    radiko_authorize && radiko_record
    esac
    if [ 0 -eq $? ]; then
	break
    fi

    retry_prev=${retry_count}
    retry_count="`expr ${retry_count} + 1`"
    if [ $retry_count -gt $retry_limit ]; then
	echo "== abort: retry count reached to limit =="
	break
    fi
    if [ 0 -eq $retry_prev ]; then
	output="${output/.flv/(1).flv}"
	oname="${oname/.flv/(1).flv}"
    else
	output="${output/(${retry_prev}).flv/(${retry_count}).flv}"
	oname="${oname/(${retry_prev}).flv/(${retry_count}).flv}"
    fi

    st="`date +%s`"
    rectime="`expr $ed - $st`"
    echo "== retry(${retry_count}): rest time is $rectime =="
done


# 後始末
_atexit
