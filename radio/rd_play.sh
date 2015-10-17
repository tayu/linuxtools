#! /bin/bash


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
    echo "save to '$output' (${rectime} Sec.)"
    ${RTMPDUMP} \
        --rtmp ${RMTP} \
        --app ${APP} \
        --playpath ${PLAYPATH} \
        -C S:"" -C S:"" -C S:"" -C S:${authtoken} \
        -W $playerurl \
        --live \
        --stop "${rectime}" \
        --flv - \
	| ${MPLAYER} -

    return 0
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

    ${RTMPDUMP} \
	--rtmp "rtmpe://netradio-${ID}-flash.nhk.jp" \
        --playpath "${PLAYPATH}" \
        --app "live" \
        -W http://www3.nhk.or.jp/netradio/files/swf/rtmpe.swf \
        --live \
        --stop "${rectime}" \
        -o - \
	| ${MPLAYER} -

    return 0
}


# 録音: simul radio
function sumul_record() {
    local url svfile outfile rc pid st ed interval opt mms
    url="$1"
    interval=10

    svfile="${output%%.flv}.wma"
    opt="$mpopt"
    if [ "mms://" = "${url:0:6}" ]; then
	opt="$opt ${url}"
    elif [ ".asx" = "${url:${#url}-4:4}" ]; then
	mms=($( \
	    wget -q "${url}" -O - \
	      | grep 'mms://' \
	      | perl -pe 's!^(.*)"(.*)"(.*)$!$2!' \
	      ))
	if [ ! -z "${mms}" ]; then
	    opt="$opt ${mms}"
	else
	    opt="$opt -playlist ${url}"
	fi
    else
	opt="$opt ${url}"
    fi
    st="`date +%s`"
    ed="`expr $st + ${rectime}`"
    ${MPLAYER} $opt &
    pid=$!
    while [ $st -lt $ed ]; do
	sleep ${interval}
	if [ -z "`ps --no-headers -o pid $pid`" ]; then
	    # abend
	    rc=1
	    break
	fi
	st="`date +%s`"
    done
    if [ -z "$rc" ]; then
	# normal end
	kill $pid
	wait $pid
	rc=0
    fi

    return $rc
}


# common part
. `dirname $0`/rd_inc.sh

