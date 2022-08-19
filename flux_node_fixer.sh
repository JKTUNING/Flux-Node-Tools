#!/bin/bash

#colors
GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE="\\033[38;5;27m"
NC='\033[0m'

COIN_CLI='flux-cli'
BENCH_CLI='fluxbench-cli'
CONFIG_FILE='flux.conf'
BENCH_DIR_LOG='.fluxbenchmark'

flux_bench_version=$(($BENCH_CLI getinfo) | jq -r '.version')

flux_bench_status=$($BENCH_CLI getstatus)
flux_bench_back=$(jq -r '.flux' <<<"$flux_bench_status")
flux_bench_flux_status=$(jq -r '.status' <<<"$flux_bench_status")
flux_bench_benchmark=$(jq -r '.benchmarking' <<<"$flux_bench_status")

# echo "Flux Bench Version    -  $flux_bench_version"
# echo "Flux back status      -  $flux_bench_back"
# echo "Flux node status      -  $flux_bench_flux_status"
# echo -e "Flux node benchmark   -  $flux_bench_benchmark - sweet"
#exit

function check_status() {
  if [[ $flux_bench_flux_status == "online" ]];
  then
    echo -e "Flux node status - ${GREEN}ONLINE${NC}"
  else
    echo -e "Flux node status - ${RED}OFFLINE${NC}"
  fi
}

function check_bench() {
  if [[ ($flux_bench_benchmark == "failed") || ($flux_bench_benchmark == "toaster") ]]; then
    echo -e "Flux node benchmark - ${RED}$flux_bench_status${NC}"
    read -p 'would you like to check for updates and restart benchmarks? (y/n) ' userInput
    if [ $userInput == 'n' ]; then
      echo 'user does not want to restart benchmarks'
    else
      echo 'user would like to restart benchmarks'
      flux_update_benchmarks
    fi
  elif [[ $flux_bench_benchmark == "running" ]]; then
    echo -e "${BLUE}node benchmarks running ... ${NC}"
  elif [[ $flux_bench_benchmark == "dos" ]]; then
    echo -e "${RED}node in denial of service state${NC}"
  else
    echo -e "Flux node benchmark - ${GREEN}$flux_bench_benchmark${NC}"
  fi
}

function check_back(){
  if [[ $flux_bench_back != *"connected"* ]];
  then
    echo -e "Flux back status - ${RED}DISCONNECTED${NC}"
    read -p 'would you like to check for updates and restart flux-back? (y/n) ' userInput
    if [ $userInput == 'n' ]; then
      echo -e "${RED}user does not want to restart flux back${NC}"
    else
      echo -e "${BLUE}user would like to update and restart flux-back${NC}"
      echo 'updating ... '
      flux_update_restart
    fi
  else
    echo -e "Flux back status - ${GREEN}CONNECTED${NC}"
  fi
}

function node_os_update(){
  sudo apt-get --with-new-pkgs upgrade -y && sudo apt autoremove -y
}

function flux_update_service(){
  node_os_update
  #sudo systemctl stop flux
  #sleep 2
  #sudo systemctl start flux
  #sleep 5
}

function flux_update_benchmarks(){
  node_os_update
  #$BENCH_CLI restartnodebenchmarks
}

check_status
check_back
check_bench