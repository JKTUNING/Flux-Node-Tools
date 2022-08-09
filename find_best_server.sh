#!/bin/bash
wget -o download_file -O download http://cdn-6.runonflux.io/apps/fluxshare/getfile/flux_explorer_bootstrap.tar.gz &
wget_pid=$!
sleep 5
kill -s SIGKILL "$wget_pid"

numberLines=$(wc -l < download_file)
#echo $numberLines

awk "NR > $((numberLines -10)) && NR <= $numberLines" download_file

#awk 'NR >= 100 && NR <= 200 {print $(NF)}' download_file
