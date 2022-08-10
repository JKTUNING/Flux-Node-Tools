#!/bin/bash
echo "User chose $1 servers ... "
for server in 5 6 7 8 9 10 11 12
do
  dotest=0

  if [[ $1 = "US" && $server -ge 5 && $server -le 7 ]]; then
    dotest=1
  fi

  if [[ $1 = "EU" && $server -ge 8 && $server -le 11 ]]; then
    dotest=1
  fi

  if [[ $1 = "AS" && $server -ge 12 && $server -le 12 ]]; then
    dotest=1
  fi

  if [[ $dotest -ge 1 ]]; then
    echo "testing server $server ..."
    wget -o download_file$server -O download http://cdn-$server.runonflux.io/apps/fluxshare/getfile/flux_explorer_bootstrap.tar.gz &
    wget_pid=$!
    sleep 5
    kill -s SIGKILL "$wget_pid"
    wait $! 2>/dev/null

    FILE=download_file$server
    if [ -f "$FILE" ];
    then
      numberLines=$(wc -l < download_file$server)
      if [[ "$numberLines" -gt 0 ]];
      then
        echo "average download time for server $server"
        awk "NR > $((numberLines -50)) && NR <= $numberLines" download_file$server > new_download_file$server
        awk '{print $(NF)}' new_download_file$server > average_time_server$server
        awk '{s+=$1}END{print s/(50)" mins"}' average_time_server$server
      fi
    fi
  fi
done

rm download*
rm new_download_file*
rm average_time_server*
