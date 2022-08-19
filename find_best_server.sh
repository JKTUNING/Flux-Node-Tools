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

#initialize empty array
serverIndex=()

#amount of time we want the wget function to run
downloadTime='8'
downloadFileSize=0

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
    wget -o download_file$server -O download_bootstrap http://cdn-$server.runonflux.io/apps/fluxshare/getfile/flux_explorer_bootstrap.tar.gz &
    wget_pid=$!
    sleep $downloadTime
    kill -s SIGKILL "$wget_pid"
    wait $! 2>/dev/null
    
    #remove bootstrap download file
    rm -f download_bootstrap

    FILE=download_file$server
    if [ -f "$FILE" ];
    then
      printf "average download speed for server $server\n"

      #grab the size of the file after wget call for $downloadTime amount of time
      #s=substr - this gets the number value in Kb and then converts the output to Mb with the  s/1000
      downloadFileSize=($(tail -1 download_file$server | awk '{printf $0}' | awk '{ s=substr($1,1,length($1)); $1=(s/1000); }1' | awk '{printf "%.1f", ($1)}'))

      #store the size of the downloadFile into an array
      fileSizes+=($downloadFileSize)

      #divide the size of the $downloadFile by $downloadTime and store it in an array
      #bash can't do floating point math - so only storing integer value for download speed at this time
      downloadSpeed+=($(echo "($downloadFileSize / ($downloadTime))" | bc))

      #add the current server number to serverIndex array
      serverIndex+=($server)

      printf "Server $server total download size $downloadFileSize Mb\n"

      #remove temp download speed file
      rm -f download_file$server
    fi
  fi
done

printf "\n\n"

#loop through every element in the array to find highest download speed in Kbps
bestTime=0
bestServer=0
count=0
 
 for i in "${downloadSpeed[@]}"
 do
    
     if [[ $bestTime -lt $i ]]; then
        #printf "$i\n"
        bestTime=$i
        bestServer=${serverIndex[$count]}
        echo "${fileSizes[$count]} Mb"
        echo "${downloadSpeed[$count]} Mb/s"
     fi
     ((count++))
 done

printf "\n----------- RESULTS -----------\nBest server -- $bestServer\nDownload speed -- $bestTime Mb/s\n"