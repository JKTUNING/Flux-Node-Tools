#!/bin/bash

COIN_CLI='flux-cli'
BENCH_CLI='fluxbench-cli'
CONFIG_FILE='flux.conf'
BENCH_DIR_LOG='.fluxbenchmark'

# if [[ "$($BENCH_CLI getinfo 2>/dev/null | jq -r '.version' 2>/dev/null)" != "" ]]; then

#   echo -e "${BOOK} ${YELLOW}Flux benchmark status:${NC}"
#   bench_getatus=$($BENCH_CLI getstatus)
#   bench_status=$(jq -r '.status' <<<"$bench_getatus")
#   bench_benchmark=$(jq -r '.benchmarking' <<<"$bench_getatus")
#   bench_back=$(jq -r '.zelback' <<<"$bench_getatus")
#   if [[ "$bench_back" == "null" ]]; then
#     bench_back=$(jq -r '.flux' <<<"$bench_getatus")
#   fi

#   bench_getinfo=$($BENCH_CLI getinfo)
#   bench_version=$(jq -r '.version' <<<"$bench_getinfo")

#   if [[ "$bench_benchmark" == "failed" || "$bench_benchmark" == "toaster" ]]; then
#     bench_benchmark_color="${RED}$bench_benchmark"
#   else
#     bench_benchmark_color="${SEA}$bench_benchmark"
#   fi

#   if [[ "$bench_status" == "online" ]]; then
#     bench_status_color="${SEA}$bench_status"
#   else
#     bench_status_color="${RED}$bench_status"
#   fi

#   if [[ "$bench_back" == "connected" ]]; then
#     bench_back_color="${SEA}$bench_back"
#   else
#     bench_back_color="${RED}$bench_back"
#   fi

#   echo -e "${PIN} ${CYAN}Flux benchmark version: ${SEA}$bench_version${NC}"
#   echo -e "${PIN} ${CYAN}Flux benchmark status: $bench_status_color${NC}"
#   echo -e "${PIN} ${CYAN}Benchmark: $bench_benchmark_color${NC}"
#   echo -e "${PIN} ${CYAN}Flux: $bench_back_color${NC}"
#   echo -e "${NC}"

#   if [[ "$bench_benchmark" == "running" ]]; then
#     echo -e "${ARROW} ${CYAN} Benchmarking hasn't completed, please wait until benchmarking has completed.${NC}"
#   fi

#   if [[ "$bench_benchmark" == "CUMULUS" || "$bench_benchmark" == "NIMBUS" || "$bench_benchmark" == "STRATUS" ]]; then
#     echo -e "${CHECK_MARK} ${CYAN} Flux benchmark working correct, all requirements met.${NC}"
#   fi

#   if [[ "$bench_benchmark" == "failed" ]]; then
#     echo -e "${X_MARK} ${CYAN} Flux benchmark problem detected, check benchmark debug.log${NC}"
#   fi

#   core=$($BENCH_CLI getbenchmarks | jq '.cores')

#   if [[ "$bench_benchmark" == "failed" && "$core" > "0" ]]; then
#     BTEST="1"
#     echo -e "${X_MARK} ${CYAN} Flux benchmark working correct but minimum system requirements not met.${NC}"
#     check_benchmarks "eps" "89.99" " CPU speed" "< 90.00 events per second"
#     check_benchmarks "ddwrite" "159.99" " Disk write speed" "< 160.00 events per second"
#   fi
#   if [[ "$bench_back" == "disconnected" ]]; then
#     echo -e "${X_MARK} ${CYAN} FluxBack does not work properly${NC}"

#     WANIP=$(wget http://ipecho.net/plain -O - -q)
#     if [[ "$WANIP" == "" ]]; then
#       WANIP=$(curl ifconfig.me)
#     fi

#     if [[ "$WANIP" != "" ]]; then

#       back_error_check=$(curl -s -m 5 http://$WANIP:$FluxAPI/zelid/loginphrase | jq -r .status)

#       if [[ "$back_error_check" != "success" && "$back_error_check" != "" ]]; then

#         back_error=$(curl -s -m 8 http://$WANIP:$FluxAPI/zelid/loginphrase | jq -r .data.message.message 2>/dev/null)

#         if [[ "$back_error" != "" ]]; then

#           echo -e "${X_MARK} ${CYAN} FluxBack error: ${RED}$back_error${NC}"

#         else

#           back_error=$(curl -s -m 8 http://$WANIP:$FluxAPI/zelid/loginphrase | jq -r .data.message 2>/dev/null)

#           if [[ "$back_error" != "" ]]; then

#             echo -e "${X_MARK} ${CYAN} FluxBack error: ${RED}$back_error${NC}"

#           fi
#         fi
#       fi
#     fi

#     device_name=$(ip addr | grep 'BROADCAST,MULTICAST,UP,LOWER_UP' | head -n1 | awk '{print $2}' | sed 's/://' | sed 's/@/ /' | awk '{print $1}')
#     local_device_ip=$(ip a list $device_name | grep -o $WANIP)

#     if [[ "$WANIP" != "" ]]; then

#       if [[ "$local_device_ip" == "$WANIP" ]]; then
#         echo -e "${CHECK_MARK} ${CYAN} Public IP(${GREEN}$WANIP${CYAN}) matches local device(${GREEN}$device_name${CYAN}) IP(${GREEN}$local_device_ip${CYAN})${NC}"
#       else
#         echo -e "${X_MARK} ${CYAN} Public IP(${GREEN}$WANIP${CYAN}) not matches local device(${GREEN}$device_name${CYAN}) IP${NC}"
#         echo -e "${ARROW} ${CYAN} If you under NAT use option 10 from multitoolbox (self-hosting)${NC}"
#         ## dev_name=$(ip addr | grep 'BROADCAST,MULTICAST,UP,LOWER_UP' | head -n1 | awk '{print $2"0"}')
#         ## sudo ip addr add "$WANPI" dev "$dev_name"
#       # IP_FIX="1"
#       fi

#     else
#       echo -e "${ARROW} ${CYAN} Local device(${GREEN}$device_name${CYAN}) IP veryfication failed...${NC}"
#     fi

#   fi
#   echo -e "${NC}"
# fi

#fluxbench-cli getbenchmarks | grep status > currentBenchmarks
flux_status=$($($BENCH_CLI getstatus) | jq -r '.status')
echo "$flux_status"
exit

fluxbench-cli getstatus > currentFluxBack
fluxbench-cli getbenchmarks > currentBenchmarks

#flux_status=$(grep -i "status" currentFluxBack)
flux_benchmarks=$(grep -i "benchmarking" currentFluxBack)
flux_back=$(grep -i "flux" currentFluxBack)

#bench_status=$(grep -io "status" currentBenchmarks)
bench_status=$(grep -i "status" currentBenchmarks)

function check_status() {
  if [[ $flux_status == *"online"* ]];
  then
    echo 'flux online'
  else
    echo 'flux offline'
  fi
}

function check_bench() {
  if [[ ($bench_status == *"failed"*) || ($bench_status == *"toaster"*) ]];
  then
    echo 'benchmarks failed'
    read -p 'would you like to check for updates and restart benchmarks? (y/n) ' userInput
    if [ $userInput == 'n' ]
    then
      echo 'user does not want to restart benchmarks'
    else
      echo 'user would like to restart benchmarks'
      flux_update_restart
    fi
  elif [[ $bench_status == *"running"* ]];
  then
    echo 'node benchmarks running ... '
  else
    echo 'node oprating normally'
  fi
}

function check_back(){
  if [[ $flux_back != *"connected"* ]];
  then
    echo 'flux back disconnected'
    read -p 'would you like to check for updates and restart flux-back? (y/n) ' userInput
    if [ $userInput == 'n' ]
    then
      echo 'user does not want to restart flux back'
    else
      echo 'user would like to update and restart flux-back'
      echo 'updating ... '
      flux_update_restart
      exit 0
    fi
  else
    echo 'flux back connected'
  fi
}

function flux_update_restart(){
  sleep 1
  #sudo apt-get --with-new-pkgs upgrade -y && sudo apt autoremove -y
  #sudo systemctl stop flux
  #sleep 2
  #sudo systemctl start flux
  #sleep 5
}

check_status
check_back
check_bench