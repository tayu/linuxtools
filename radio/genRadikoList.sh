#! /bin/bash

HTML="radiko.html"
ODIR="area"
HRER="13"

declare AREANAME=(
    "北海道"
    "青森県"
    "岩手県"
    "宮城県"
    "秋田県"
    "山形県"
    "福島県"
    "茨城県"
    "栃木県"
    "群馬県"
    "埼玉県"
    "千葉県"
    "東京都"
    "神奈川県"
    "新潟県"
    "富山県"
    "石川県"
    "福井県"
    "山梨県"
    "長野県"
    "岐阜県"
    "静岡県"
    "愛知県"
    "三重県"
    "滋賀県"
    "京都府"
    "大阪府"
    "兵庫県"
    "奈良県"
    "和歌山県"
    "鳥取県"
    "島根県"
    "岡山県"
    "広島県"
    "山口県"
    "徳島県"
    "香川県"
    "愛媛県"
    "高知県"
    "福岡県"
    "佐賀県"
    "長崎県"
    "熊本県"
    "大分県"
    "宮崎県"
    "鹿児島県"
    "沖縄県"
)


# IN: エリアコード
_genHtml() {
    local area xml opt
    local ids names hrefs banners
    local i w e

    ids=()
    names=()
    hrefs=()
    banners=()

    area=$1
    xml="${ODIR}/${area}.xml"
    if [ ! -f ${xml} ]; then
	opt="-q -O ${xml} http://radiko.jp/v2/station/list/${area}.xml"
	wget ${opt}
    fi

    for w in $(cat ${xml} | xpath -q -e 'stations/station/id/text()'); do
	ids+=(${w})
    done
    for w in $(cat ${xml} | xpath -q -e 'stations/station/href/text()'); do
	hrefs+=(${w})
    done
    for w in $(cat ${xml} | xpath -q -e 'stations/station/banner/text()'); do
	banners+=(${w})
    done
    IFS='	
'
    for w in $(cat ${xml} | xpath -q -e 'stations/station/name/text()'); do
	names+=(${w})
    done
    IFS=' 	
'

    for i in $(seq 0 $((${#ids[@]} - 1))); do
	cat <<EOF
<tr class="radiko_tr">
<td class="radiko_td">${names[i]}</td>
<td class="radiko_td">${ids[i]}</td>
<td class="radiko_td">
  <a href="${hrefs[i]}">
    <img class="banner"
    src="${banners[i]}"
    alt="${names[i]}"
    />
  </a>
</td>
</tr>
EOF
    done
}



_head() {
    cat <<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja-JP" xml:lang="ja-JP">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
    <link rel="INDEX" href="./index.html" />
    <link rel="stylesheet" type="text/css" href="web/index.css" />
    <title>radiko</title>
  </head>
  <body>
  <div class="title">radiko</div>
  <hr />
EOF
}
_foot() {
    cat <<EOF
  </body>
</html>
EOF
}

_areahead() {
    local aid aname

    aid=$1
    aname=$2

    cat <<EOF
  <div id="${aid}">
  <span class="area_name">${aid} ${aname}</span>
  <table>
EOF
}

_areafoot() {
    cat <<EOF
  </table>
  </div>
  <hr />
EOF
}


_toc() {
    local i

    cat <<EOF
  <div>
  <span class="area_list">
EOF
    for i in $(seq ${HRER} ${HRER}); do
	cat <<EOF
  <a href="#JP${i}">JP${i}:${AREANAME[$((i - 1))]}</a>
EOF
    done
    for i in $(seq 1 47); do
	if [ ${HRER} -eq $i ]; then continue; fi
	cat <<EOF
  <a href="#JP${i}">JP${i}:${AREANAME[$((i - 1))]}</a>
EOF
    done
    cat <<EOF
  </span>
  </div>
  <hr />
EOF
}


_main() {
    local i n

    echo "" > ${HTML}
    _head >> ${HTML}

    _toc >> ${HTML}
    for i in $(seq ${HRER} ${HRER}); do
	n="${AREANAME[$((i - 1))]}"
	_areahead JP${i} ${n} >> ${HTML}
	_genHtml JP${i} ${n} >> ${HTML}
	_areafoot JP${i} ${n} >> ${HTML}
    done
    for i in $(seq 1 47); do

	if [ ${HRER} -eq $i ]; then continue; fi

	n="${AREANAME[$((i - 1))]}"
	_areahead JP${i} ${n} >> ${HTML}
	_genHtml JP${i} ${n} >> ${HTML}
	_areafoot JP${i} ${n} >> ${HTML}
    done

    _foot >> ${HTML}
}
_main
