#!/bin/sh

interval=3

test -x /usr/sbin/ntpdate || exit 0

if [ "0" = $(expr `date +%H` % $interval) ]; then
    /usr/sbin/ntpdate -4 ntp.jst.mfeed.ad.jp
fi


