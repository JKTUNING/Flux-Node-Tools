#!/bin/bash

source /dev/stdin <<<"$(curl -s https://raw.githubusercontent.com/JKTUNING/Flux-Node-Tools/main/simple_curses.sh)"

#colors
GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE="\\033[38;5;27m"
SEA="\\033[38;5;49m"
NC='\033[0m'

WRENCH='\xF0\x9F\x94\xA7'
BLUE_CIRCLE='\xF0\x9F\x94\xB5'
#BLUE_CIRCLE="${SEA}\xE2\x96\xB6${NC}"

COIN_CLI='flux-cli'
BENCH_CLI='fluxbench-cli'
CONFIG_FILE='flux.conf'
BENCH_DIR_LOG='.fluxbenchmark'

BENCH_LOG_DIR='benchmark_debug_error.log'
DAEMON_LOG_DIR='~/.flux/debug.log'

show_daemon='0'
show_bench='1'
show_node='0'

#gets fluxbench version info
flux_bench_version=$(($BENCH_CLI getinfo) | jq -r '.version')

gets fluxbench status
flux_bench_details=$($BENCH_CLI getstatus)
flux_bench_back=$(jq -r '.flux' <<<"$flux_bench_details")
flux_bench_flux_status=$(jq -r '.status' <<<"$flux_bench_details")
flux_bench_benchmark=$(jq -r '.benchmarking' <<<"$flux_bench_details")

#gets blockchain info
flux_daemon_details=$($COIN_CLI getinfo)
flux_daemon_version=$(jq -r '.version' <<<"$flux_daemon_details")
flux_daemon_protocol_version=$(jq -r '.protocolversion' <<<"$flux_daemon_details")
flux_daemon_block_height=$(jq -r '.blocks' <<<"$flux_daemon_details")
flux_daemon_connections=$(jq -r '.connections' <<<"$flux_daemon_details")
flux_daemon_difficulty=$(jq -r '.difficulty' <<<"$flux_daemon_details")
flux_daemon_error=$(jq -r '.error' <<<"$flux_daemon_details")

#gets flux node status
flux_node_details=$($COIN_CLI getzelnodestatus)
flux_node_status=$(jq -r '.status' <<<"$flux_node_details")
flux_node_collateral=$(jq -r '.collateral' <<<"$flux_node_details")
flux_node_added_height=$(jq -r '.added_height' <<<"$flux_node_details")
flux_node_confirmed_height=$(jq -r '.confirmed_height' <<<"$flux_node_details")
flux_node_last_confirmed_height=$(jq -r '.last_confirmed_height' <<<"$flux_node_details")
flux_node_last_paid_height=$(jq -r '.last_paid_height' <<<"$flux_node_details")

flux_bench_stats=$($BENCH_CLI getbenchmarks)
flux_bench_stats_real_cores=$(jq -r '.real_cores' <<<"$flux_bench_stats")
flux_bench_stats_cores=$(jq -r '.cores' <<<"$flux_bench_stats")
flux_bench_stats_ram=$(jq -r '.ram' <<<"$flux_bench_stats")
flux_bench_stats_ssd=$(jq -r '.ssd' <<<"$flux_bench_stats")
flux_bench_stats_hhd=$(jq -r '.hdd' <<<"$flux_bench_stats")
flux_bench_stats_ddwrite=$(jq -r '.ddwrite' <<<"$flux_bench_stats")
flux_bench_stats_storage=$(jq -r '.totalstorage' <<<"$flux_bench_stats")
flux_bench_stats_eps=$(jq -r '.eps' <<<"$flux_bench_stats")
flux_bench_stats_ping=$(jq -r '.ping' <<<"$flux_bench_stats")
flux_bench_stats_download=$(jq -r '.download_speed' <<<"$flux_bench_stats")
flux_bench_stats_upload=$(jq -r '.cores' <<<"$flux_bench_stats")
flux_bench_stats_speed_test_version=$(jq -r '.speed_version' <<<"$flux_bench_stats")
flux_bench_stats_error=$(jq -r '.error' <<<"$flux_bench_stats")

daemon_log=""
bench_log=""

#calculated block height since last confirmed
blockDiff=$(($flux_daemon_block_height-$flux_node_last_confirmed_height))

main (){

  if [[ $show_bench == '1' ]]; then
  #Display Bench Details
    window "Flux Benchmark Details" "red" "100%"
      append_tabbed "Flux bench version:$flux_bench_version"  2
      append_tabbed "Flux back status:$flux_bench_back"  2
      append_tabbed "Flux bench status:$flux_bench_flux_status"  2
      append_tabbed "Flux benchmarks:$flux_bench_benchmark"  2
      addsep
      append_tabbed "real cores:$flux_bench_stats_real_cores"  2
      append_tabbed "cores:$flux_bench_stats_cores"  2
      append_tabbed "ram:$flux_bench_stats_ram"  2
      append_tabbed "ssd:$flux_bench_stats_ssd"  2
      append_tabbed "hhd:$flux_bench_stats_hhd"  2
      append_tabbed "dd write:$flux_bench_stats_ddwrite"  2
      append_tabbed "Total Storage:$flux_bench_stats_storage"  2
      append_tabbed "EPS:$flux_bench_stats_eps"  2
      append_tabbed "Ping:$flux_bench_stats_ping"  2
      append_tabbed "Download Speed:$flux_bench_stats_download"  2
      append_tabbed "Upload Speed:$flux_bench_stats_upload"  2
      append_tabbed "Speed Test Version:$flux_bench_stats_speed_test_version"  2
      append_tabbed "Errors:$flux_bench_stats_error"  2      
    endwin

        #show bench log under
        #col_right  

    if [[ $bench_log != "" ]]; then
      window "Flux Bench Log" "red" "100%"
        append "$bench_log"
      endwin
    endwin
    fi
  fi



  if [[ $show_daemon == '1' ]]; then
    #Display Daemon Details
    window "Flux Daemon Details" "blue" "100%"
      append_tabbed "Flux daemon version:$flux_daemon_version" 2
      append_tabbed "Flux version:$flux_daemon_protocol_version"  2
      append_tabbed "Flux block height:$flux_daemon_block_height"  2
      append_tabbed "Flux connections:$flux_daemon_connections"  2
      append_tabbed "Flux difficulty:$flux_daemon_difficulty"  2
    endwin

    #col_right

    if [[ $daemon_log != "" ]]; then
      window "Flux Daemon Log" "red" "100%"
        append "$daemon_log"
      endwin
    fi

  fi
    
  if [[ $show_node == '1' ]]; then
    #Display Node Details
    window "Flux Node Details" "green" "100%"
      append_tabbed "Flux node status:$flux_node_status"  2
      #append_tabbed "Flux collateral:$flux_node_collateral"  2
      append_tabbed "Flux added height:$flux_node_added_height"  2
      append_tabbed "Flux confirmed height:$flux_node_confirmed_height"  2
      append_tabbed "Flux last confirmed:$flux_node_last_confirmed_height"  2
      append_tabbed "Flux last paid height:$flux_node_last_paid_height"  2
      append_tabbed "Blocks since last confirmed:$blockDiff"  2
    endwin
  fi

    
}

update (){
  local userInput

  read -s -n 1 -t 2 userInput
  #'b' shows the last 5 lines of bench mark error log
  #'d' shows the last 5 lines of daemon error log
  #'q' will quit
  if [[ $userInput == 'b' ]]; then
    bench_log=$(tail -5 $BENCH_LOG_DIR)
    show_node='0'
    show_daemon='0'
    show_bench='1'
  elif [[ $userInput == 'n' ]]; then
    show_node='1'
    show_daemon='0'
    show_bench='0'
  elif [[ $userInput == 'd' ]]; then
    daemon_log=$(tail -5 $DAEMON_LOG_DIR)
    show_node='0'
    show_daemon='1'
    show_bench='0'
  elif [[ $userInput == 'q' ]]; then
    clear
    exit
  fi
}

# this runs update function
main_loop -t 5 "$@"

#this runs a timer
#main_loop -t 5 "$@"




# function check_status() {
#   if [[ $flux_bench_flux_status == "online" ]];
#   then
#     echo -e "Flux node status           -    ${GREEN}ONLINE${NC}"
#   else
#     echo -e "Flux node status           -    ${RED}OFFLINE${NC}"
#   fi
# }

# function check_bench() {
#   if [[ ($flux_bench_benchmark == "failed") || ($flux_bench_benchmark == "toaster") ]]; then
#     echo -e "Flux node benchmark        -    ${RED}$flux_bench_status${NC}"
#     read -p 'would you like to check for updates and restart benchmarks? (y/n) ' userInput
#     if [ $userInput == 'n' ]; then
#       echo 'user does not want to restart benchmarks'
#     else
#       echo 'user would like to restart benchmarks'
#       flux_update_benchmarks
#     fi
#   elif [[ $flux_bench_benchmark == "running" ]]; then
#     echo -e "${BLUE}node benchmarks running ... ${NC}"
#   elif [[ $flux_bench_benchmark == "dos" ]]; then
#     echo -e "${RED}node in denial of service state${NC}"
#   else
#     echo -e "Flux node benchmark        -    ${GREEN}$flux_bench_benchmark${NC}"
#   fi
# }

# function check_back(){
#   if [[ $flux_bench_back != *"connected"* ]];
#   then
#     echo -e "Flux back status           -    ${RED}DISCONNECTED${NC}"
#     read -p 'would you like to check for updates and restart flux-back? (y/n) ' userInput
#     if [ $userInput == 'n' ]; then
#       echo -e "${RED}user does not want to restart flux back${NC}"
#     else
#       echo -e "${BLUE}user would like to update and restart flux-back${NC}"
#       echo 'updating ... '
#       flux_update_restart
#     fi
#   else
#     echo -e "Flux back status           -    ${GREEN}CONNECTED${NC}"
#   fi
# }

# function node_os_update(){
#   sudo apt-get --with-new-pkgs upgrade -y && sudo apt autoremove -y
# }

# function flux_update_service(){
#   node_os_update
#   #sudo systemctl stop flux
#   #sleep 2
#   #sudo systemctl start flux
#   #sleep 5
# }

# function flux_update_benchmarks(){
#   node_os_update
#   #$BENCH_CLI restartnodebenchmarks
# }

# function flux_daemon_info(){
#   echo -e "$BLUE_CIRCLE   Flux daemon version          -    $flux_daemon_version"
#   echo -e "$BLUE_CIRCLE   Flux protocol version        -    $flux_daemon_protocol_version"
#   echo -e "$BLUE_CIRCLE   Flux daemon block height     -    $flux_daemon_block_height"
#   echo -e "$BLUE_CIRCLE   Flux daemon connections      -    $flux_daemon_connections"
#   echo -e "$BLUE_CIRCLE   Flux deamon difficulty       -    $flux_daemon_difficulty"
# }

# function flux_node_info(){
#   echo -e "$BLUE_CIRCLE   Flux node status             -    $flux_node_status"
#   echo -e "$BLUE_CIRCLE   Flux node collateral         -    $flux_node_collateral"
#   echo -e "$BLUE_CIRCLE   Flux node added height       -    $flux_node_added_height"
#   echo -e "$BLUE_CIRCLE   Flux node confirmed height   -    $flux_node_confirmed_height"
#   echo -e "$BLUE_CIRCLE   Flux node last confirmed     -    $flux_node_last_confirmed_height"
#   echo -e "$BLUE_CIRCLE   Flux node last paid height   -    $flux_node_last_paid_height"
#   echo -e "$BLUE_CIRCLE   Blocks since last confirmed  -    $blockDiff"
# }

#flux_daemon_info
#flux_node_info
#check_status
#check_back
#check_bench

