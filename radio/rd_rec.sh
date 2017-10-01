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
    echo "save to '$output'"
    ${RTMPDUMP} \
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
# こじまさん http://plamo.linet.gr.jp/wiki/index.php?diary%2FKojima
# チャンネルhttp://www.nhk.or.jp/radio/config/config_web.xml
function radiko_nhk() {
    local url savefile rc

    url="$1"
    ID="${channel##*-}"
    ID="${ID,,}" # 小文字にしておく
    savefile="${output%%.flv}.m4a"

    echo "==== recording (nhk-${ID}) ===="
    echo "save as '${savefile}'"

    ffmpeg \
	-i "${url}" \
	-t ${rectime} \
	-movflags faststart \
	-c copy \
	-bsf:a aac_adtstoasc \
	"${savefile}"
    rc=$?

    if [ ! -z "${oname}" ]; then
        mv ${output} "`dirname ${output}`/${oname}"
    fi

    return $rc
}


# 録音: simul radio
function sumul_record() {
    local url svfile outfile rc pid st ed interval opt mms
    url="$1"
    interval=10

    svfile="${output%%.flv}.wma"
    opt="$mpopt -dumpstream -dumpfile ${svfile}"
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

    if [ ! -z "${oname}" ]; then
	outfile="${oname%%.flv}.wma"
        mv ${svfile} "`dirname ${svfile}`/${outfile}"
    fi

    return $rc
}


# common part
. `dirname $0`/rd_inc.sh

