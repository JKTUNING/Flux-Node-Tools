#!/bin/bash
if [ -z "$1" ]; then
  read -p 'please chose a server region you would like to test ... (US/EU/AS) ' userInput
else
  userInput="$1"
fi


if [ -z "$userInput" ]; then 
  printf "\nno servers selected .. exiting ...\n"
  exit 0
fi

echo "user selected server $userInput for testing"

for server in 5 6 7 8 9 10 11 12
do
  dotest=0
  #if US selected and server is between 5 and 7
  if [[ $userInput = "US" && $server -ge 5 && $server -le 7 ]]; then
    dotest=1
  fi
  #if EU selected and server is between 8 and 11
  if [[ $userInput = "EU" && $server -ge 8 && $server -le 11 ]]; then
    dotest=1
  fi
  #if AS (ASIA) selected and server is between 12
  if [[ $userInput = "AS" && $server -ge 12 && $server -le 12 ]]; then
    dotest=1
  fi

  #if dotest then wget bootstrap file and let it run for x seconds - then kill process and parse the output and average the last 50 records
  if [[ $dotest -ge 1 ]]; then
    echo "testing server $server ..."
    wget -o download_file$server -O download http://cdn-$server.runonflux.io/apps/fluxshare/getfile/flux_explorer_bootstrap.tar.gz &
    wget_pid=$!
    sleep 8
    kill -s SIGKILL "$wget_pid"
    wait $! 2>/dev/null
    
    #remove download file
    rm -f download

    FILE=download_file$server
    if [ -f "$FILE" ];
    then
      numberLines=$(wc -l < download_file$server)
      if [[ "$numberLines" -gt 0 ]];
      then
        echo "average download time for server $server"
        awk "NR > $((numberLines -50)) && NR <= $numberLines" download_file$server | awk '{print $(NF)}' | awk '{s+=$1}END{print s/(50)" mins"}'
      fi
    fi
  fi
done

rm -f download*
