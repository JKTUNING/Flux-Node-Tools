#!/bin/bash
#check the input from the command line to see if it is empty - if so then ask for a server
if [ -z "$1" ]; then
  read -p 'please chose a server region you would like to test ... (US/EU/AS) ' userInput
else
  userInput="$1"
fi

#check to see if user input is null - if so exit
if [ -z "$userInput" ]; then 
  printf "\nno servers selected ... exiting ...\n"
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
    printf "\ntesting server $server ...\n"
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
      #if number of lines greater than 57 means we have something we can work with - otherwise it's too slow!
      if [[ "$numberLines" -gt 57 ]];
      then
        printf "average download speed for server $server\n"
        #could store output into an array to give user the best choice for download speed 
        #downloadSpeed+=($(awk "NR > $((numberLines -50)) && NR <= $numberLines" download_file$server | awk '{print $(NF)}')) #| awk '{s+=$1}END{print s/(50)}'))

        downloadSpeed+=($(awk "NR > $((numberLines -50)) && NR <= $numberLines" download_file$server | awk '{print $8}' | grep -o "[0-9.]\+[KMG]" | awk '{ s=substr($1,1,length($1)); u=substr($1,length($1)); if(u=="K") $1=(s*1); if(u=="M") $1=(s*1000); if(u=="G") $1=(s*1000000); }1' | awk '{s+=$1}END{printf "%.0f", s/(50)}'))
        awk "NR > $((numberLines -50)) && NR <= $numberLines" download_file$server | awk '{print $8}' | grep -o "[0-9.]\+[KMG]" | awk '{ s=substr($1,1,length($1)); u=substr($1,length($1)); if(u=="K") $1=(s*1); if(u=="M") $1=(s*1000); if(u=="G") $1=(s*1000000); }1' | awk '{s+=$1}END{printf "%.0f", s/(50)}'

        #awk "NR > $((numberLines -50)) && NR <= $numberLines" download_file$server | awk '{print $8}' | grep -o "[0-9.]\+[KMG]"
        #awk "NR > $((numberLines -50)) && NR <= $numberLines" download_file$server | awk '{print $(NF)}' | awk '{s+=$1}END{print s/(50)" mins"}'
      else
        printf "\nServer $server download speed too slow .. trying next server"
      fi
    fi
  fi
done

printf "\n\n"

#loop through every element in the array to find highest download speed in Kbps
bestTime=0
 
 for i in "${downloadSpeed[@]}"
 do
     if [[ $bestTime -lt $i ]]; then
        printf "\n$i"
        bestTime=$i
     fi
 done

printf "\n\nBest download speed is $bestTime Kbps\n\n"

#remove download file and temp wget output file
rm -f download*
