#!/bin/bash

echo -e "checking required packages ... "

if ! jq --version >/dev/null 2>&1; then
  echo -e "${RED}jq not found ... installing jq${NC}"
  sudo apt install jq -y

  if ! jq --version >/dev/null 2>&1; then
    echo "jq install was not successful - exiting"
    exit
  fi
fi

if ! lsof -v > /dev/null 2>&1; then
  echo -e "lsof not found ... installing lsof"
  sudo apt-get install lsof -y
fi

#colors
GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE="\\033[38;5;27m"
SEA="\\033[38;5;49m"
NC='\033[0m'

version='Flux Node Viewer 1.0.0'

WRENCH='\xF0\x9F\x94\xA7'
#BLUE_CIRCLE='\xF0\x9F\x94\xB5'
RED_ARROW="${RED}\xE2\x96\xB6${NC}  "
GREEN_ARROW="${GREEN}\xE2\x96\xB6${NC}  "
BLUE_CIRCLE="${SEA}\xE2\x96\xB6${NC}  "

_HLINE="\xE2\x94\x80"
_VLINE="\xE2\x94\x82"

DASH_BENCH_TITLE='FLUX BENCHMARK INFO'
DASH_BENCH_DETAILS_TITLE='FLUX BENCHMARK DETAILS'
DASH_BENCH_ERROR_TITLE='FLUX BENCH ERROR LOG'
DASH_BENCH_PORT_TITLE='FLUX BENCHMARK PORT'

DASH_NODE_TITLE='FLUX NODE INFO'
DASH_NODE_PORT_TITLE='FLUX NODE PORTS'
DASH_NODE_SERVICE_TITLE='FLUX NODE SERVICES'

DASH_DAEMON_TITLE='FLUX DAEMON INFO'
DASH_DAEMON_PORT_TITLE='FLUX DAEMON PORT'
DASH_DAEMON_ERROR_TITLE='FLUX DAEMON ERROR LOG'

DASH_COMMANDS_TITLE='APPLICATION COMMANDS'

WINDOW_WIDTH=$(tput cols)
WINDOW_HALF_WIDTH=$(bc <<<"$WINDOW_WIDTH / 2")

COIN_CLI='flux-cli'
BENCH_CLI='fluxbench-cli'
CONFIG_FILE='flux.conf'
BENCH_DIR_LOG='.fluxbenchmark'
FLUX_DIR='zelflux'

if ! [ -f /usr/local/bin/flux-cli ]; then
  echo -e "${RED}flux-cli tool not installed${NC}"
  echo -e "${RED}application will exit in 5 seconds ...${NC}"
  sleep 5
  exit
fi

if ! [ -f /usr/local/bin/fluxbench-cli ]; then
  echo -e "${RED}fluxbench-cli tool not installed${NC}"
  echo -e "${RED}application will exit in 5 seconds ...${NC}"
  sleep 5
  exit
fi


BENCH_LOG_DIR="/home/$USER/$BENCH_DIR_LOG/debug.log"
DAEMON_LOG_DIR="/home/$USER/.flux/debug.log"
WATCHDOG_LOG_DIR="home/$USER/watchdog/watchdog_error.log"
FLUX_LOG_DIR="/home/$USER/$FLUX_DIR/debug.log"

docker_service_status=""
mongodb_service_status=""
daemon_service_status=""
flux_process_status=""


#variables to draw windows
show_bench='1'
show_daemon='0'
show_node='0'
show_commands='0'

# variable to see if the terminal size has changed
redraw_term='1'

#Function to collect all benchmark information for display
function get_flux_bench_info(){
  #gets fluxbench version info
  flux_bench_version=$(($BENCH_CLI getinfo) 2>/dev/null | jq -r '.version' 2>/dev/null)

  #gets fluxbench info
  flux_bench_details=$($BENCH_CLI getstatus 2>/dev/null)
  flux_bench_back=$(jq -r '.flux' <<<"$flux_bench_details" 2>/dev/null)
  flux_bench_flux_status=$(jq -r '.status' <<<"$flux_bench_details" 2>/dev/null)
  flux_bench_benchmark=$(jq -r '.benchmarking' <<<"$flux_bench_details" 2>/dev/null)

  #gets flux node benchmark info
  flux_bench_stats=$($BENCH_CLI getbenchmarks 2>/dev/null)
  flux_bench_stats_real_cores=$(jq -r '.real_cores' <<<"$flux_bench_stats" 2>/dev/null)
  flux_bench_stats_cores=$(jq -r '.cores' <<<"$flux_bench_stats" 2>/dev/null)
  flux_bench_stats_ram=$(jq -r '.ram' <<<"$flux_bench_stats" 2>/dev/null)
  flux_bench_stats_ssd=$(jq -r '.ssd' <<<"$flux_bench_stats" 2>/dev/null)
  flux_bench_stats_hhd=$(jq -r '.hdd' <<<"$flux_bench_stats" 2>/dev/null)
  flux_bench_stats_ddwrite=$(jq -r '.ddwrite' <<<"$flux_bench_stats" 2>/dev/null)
  flux_bench_stats_storage=$(jq -r '.totalstorage' <<<"$flux_bench_stats" 2>/dev/null)
  flux_bench_stats_eps=$(jq -r '.eps' <<<"$flux_bench_stats" 2>/dev/null)
  flux_bench_stats_ping=$(jq -r '.ping' <<<"$flux_bench_stats" 2>/dev/null)
  flux_bench_stats_download=$(jq -r '.download_speed' <<<"$flux_bench_stats" 2>/dev/null)
  flux_bench_stats_upload=$(jq -r '.upload_speed' <<<"$flux_bench_stats" 2>/dev/null)
  flux_bench_stats_speed_test_version=$(jq -r '.speed_version' <<<"$flux_bench_stats" 2>/dev/null)
  flux_bench_stats_error=$(jq -r '.error' <<<"$flux_bench_stats" 2>/dev/null)
}

## Function to collect flux block chain daemon data
function get_flux_blockchain_info(){
  #gets blockchain info
  flux_daemon_details=$($COIN_CLI getinfo 2>/dev/null)
  flux_daemon_version=$(jq -r '.version' <<<"$flux_daemon_details" 2>/dev/null)
  flux_daemon_protocol_version=$(jq -r '.protocolversion' <<<"$flux_daemon_details" 2>/dev/null)
  flux_daemon_block_height=$(jq -r '.blocks' <<<"$flux_daemon_details" 2>/dev/null)
  flux_daemon_connections=$(jq -r '.connections' <<<"$flux_daemon_details" 2>/dev/null)
  flux_daemon_difficulty=$(jq -r '.difficulty' <<<"$flux_daemon_details" 2>/dev/null)
  flux_daemon_error=$(jq -r '.error' <<<"$flux_daemon_details" 2>/dev/null)
}

## Function to get flux node data
function get_flux_node_info(){
  #gets flux node info
  flux_node_details=$($COIN_CLI getzelnodestatus 2>/dev/null)
  flux_node_status=$(jq -r '.status' <<<"$flux_node_details" 2>/dev/null)
  flux_node_collateral=$(jq -r '.collateral' <<<"$flux_node_details" 2>/dev/null)
  flux_node_added_height=$(jq -r '.added_height' <<<"$flux_node_details" 2>/dev/null)
  flux_node_confirmed_height=$(jq -r '.confirmed_height' <<<"$flux_node_details" 2>/dev/null)
  flux_node_last_confirmed_height=$(jq -r '.last_confirmed_height' <<<"$flux_node_details" 2>/dev/null)
  flux_node_last_paid_height=$(jq -r '.last_paid_height' <<<"$flux_node_details" 2>/dev/null)
}

#calculated block height since last confirmed
function get_blocks_since_last_confirmed(){
  blockDiff=$((flux_daemon_block_height-flux_node_last_confirmed_height))
  maint_window=$(((120-(flux_daemon_block_height-flux_node_last_confirmed_height))*2))
}

# get a list of the LISTEN ports
listen_ports=$(sudo lsof -i -n | grep LISTEN)
flux_api_port=""
flux_ui_port=""
mongodb_port=""
flux_bench_port=""
flux_daemon_port=""
flux_ip_check=""
flux_node_version_check=""

local_device=$(ip addr | grep 'BROADCAST,MULTICAST,UP,LOWER_UP' | awk 'NR==1 {print $2}')
flux_node_version=$(jq -r '.version' /home/$USER/$FLUX_DIR/package.json 2>/dev/null)

#log variables
daemon_log=""
bench_log=""
flux_log=""

function update (){
  local userInput

  read -s -n 1 -t 1 userInput
  #'b' shows benchmark screen and the last 5 lines of bench mark error log
  #'d' shows daemon screen and the last 5 lines of daemon error log
  #'n' shows node screen
  #'u' shows ubuntu operating system update screen
  #'c' shows available commands
  #'q' will quit
  if [[ $userInput == 'b' ]]; then
    check_benchmark_log
    show_node='0'
    show_daemon='0'
    show_bench='1'
    show_commands='0'
    redraw_term='1'
    sleep 0.1
  elif [[ $userInput == 'n' ]]; then
    show_node='1'
    show_daemon='0'
    show_bench='0'
    show_commands='0'
    redraw_term='1'
    sleep 0.1
  elif [[ $userInput == 'd' ]]; then
    check_daemon_log
    show_node='0'
    show_daemon='1'
    show_bench='0'
    show_commands='0'
    redraw_term='1'
    sleep 0.1
  elif [[ $userInput == 'u' ]]; then
    node_os_update
    sleep 0.1
    redraw_term='1'
  elif [[ $userInput == 'c' ]]; then
    show_node='0'
    show_daemon='0'
    show_bench='0'
    show_commands='1'
    redraw_term='1'
    sleep 0.1
  elif [[ $userInput == 'q' ]]; then
    clear
    exit
  else
    redraw_term='0'
  fi
}

#this function checks for listen ports using lsof
function check_port_info()
{
  #echo -e "$listen_ports"
  
  if [[ $listen_ports = *'27017'* && $listen_ports = *'mongod'* ]]; then
    mongodb_port="${GREEN_ARROW}   MongoDB is listening on port ${GREEN}27017${NC}"
  else
    mongodb_port="${RED_ARROW}   MongoDB is ${RED}not listening${NC}"
  fi

  if [[ $listen_ports = *'16125'* && $listen_ports = *'fluxd'* ]]; then
    flux_daemon_port="${GREEN_ARROW}   Flux Daemon is listening on port ${GREEN}16125${NC}"
  else
    flux_daemon_port="${RED_ARROW}   Flux Daemon is ${RED}not listening${NC}"
  fi

   if [[ $listen_ports = *'16224'* && $listen_ports = *'bench'* ]]; then
    flux_bench_port="${GREEN_ARROW}   Flux Bench is listening on port ${GREEN}16224${NC}"
  else
    flux_bench_port="${RED_ARROW}   Flux Bench is ${RED}not listening${NC}"
  fi

  #use awk to parse lsof results - find any entry with "node" in the first column and print the port info column $9 - then check to see if that result has a * before the field seperator ":" - return the first row then the second row results
  api_port=$(awk -v var="${listen_ports}" 'BEGIN {print var}' | awk ' { if ($1 == "node") {print $9} }' | awk -F ":" '{ if ($1 == "*") {print $2} }' | awk 'NR==1 {print $1}')
  ui_port=$(awk -v var="${listen_ports}" 'BEGIN {print var}' | awk ' { if ($1 == "node") {print $9} }' | awk -F ":" '{ if ($1 == "*") {print $2} }' | awk 'NR==2 {print $1}')

  if [[ $api_port != "" ]]; then
    flux_api_port="${GREEN_ARROW}   Flux API Listening on ${GREEN}$api_port${NC}"
  else
    flux_api_port="${RED_ARROW}   Flux API is ${RED}not listening${NC}"
  fi

  if [[ $ui_port != "" ]]; then
    flux_ui_port="${GREEN_ARROW}   Flux UI Listening on ${GREEN}$ui_port${NC}"
  else
    flux_ui_port="${RED_ARROW}   Flux UI is ${RED}not listening${NC}"
  fi
}

function flux_daemon_info(){
  clear
  sleep 0.25
  make_header "$DASH_DAEMON_TITLE" "$BLUE"
  echo -e "$BLUE_CIRCLE   Flux daemon version          -    $flux_daemon_version"
  echo -e "$BLUE_CIRCLE   Flux protocol version        -    $flux_daemon_protocol_version"
  echo -e "$BLUE_CIRCLE   Flux daemon block height     -    $flux_daemon_block_height"
  echo -e "$BLUE_CIRCLE   Flux daemon connections      -    $flux_daemon_connections"
  echo -e "$BLUE_CIRCLE   Flux deamon difficulty       -    $flux_daemon_difficulty"
  make_header "$DASH_DAEMON_PORT_TITLE" "$BLUE"
  echo -e "$flux_daemon_port"
  echo -e "$daemon_service_status"

  if [[ $daemon_log != "" ]]; then
    make_header "$DASH_DAEMON_ERROR_TITLE" "$RED"
    echo -e "$daemon_log"
  fi
  navigation
}

function flux_node_info(){\
  clear
  sleep 0.25
  make_header "$DASH_NODE_TITLE" "$BLUE"
  echo -e "$BLUE_CIRCLE   Flux node status             -    $flux_node_status"
  echo -e "$BLUE_CIRCLE   Flux node added height       -    $flux_node_added_height"
  echo -e "$BLUE_CIRCLE   Flux node confirmed height   -    $flux_node_confirmed_height"
  echo -e "$BLUE_CIRCLE   Flux node last confirmed     -    $flux_node_last_confirmed_height"
  echo -e "$BLUE_CIRCLE   Flux node last paid height   -    $flux_node_last_paid_height"
  echo -e "$BLUE_CIRCLE   Blocks since last confirmed  -    $blockDiff"
  echo -e "$BLUE_CIRCLE   Node Maintenance Window       -    $maint_window mins"
  echo -e "$flux_node_version_check"
  make_header "$DASH_NODE_PORT_TITLE" "$BLUE"
  echo -e "$flux_ip_check"
  echo -e "$flux_api_port"
  echo -e "$flux_ui_port"
  echo -e "$mongodb_port"
  make_header "$DASH_NODE_SERVICE_TITLE" "$BLUE"
  echo -e "$flux_process_status"
  echo -e "$mongodb_service_status"
  echo -e "$docker_service_status"
  navigation
}

function flux_benchmark_info(){
  clear
  sleep 0.25
  make_header "$DASH_BENCH_TITLE" "$BLUE"
  echo -e "$BLUE_CIRCLE   Flux bench version           -    $flux_bench_version"
  echo -e "$BLUE_CIRCLE   Flux back status             -    $flux_bench_back"
  echo -e "$BLUE_CIRCLE   Flux bench status            -    $flux_bench_flux_status"
  echo -e "$BLUE_CIRCLE   Flux benchmarks              -    $flux_bench_benchmark"
  make_header "$DASH_BENCH_DETAILS_TITLE" "$BLUE"
  echo -e "$BLUE_CIRCLE   Bench Real Cores             -    $flux_bench_stats_real_cores"
  echo -e "$BLUE_CIRCLE   Bench Cores                  -    $flux_bench_stats_cores"
  echo -e "$BLUE_CIRCLE   Bench Ram                    -    $flux_bench_stats_ram"
  echo -e "$BLUE_CIRCLE   Bench SSD                    -    $flux_bench_stats_ssd"
  echo -e "$BLUE_CIRCLE   Bench HHD                    -    $flux_bench_stats_hhd"
  echo -e "$BLUE_CIRCLE   Bench ddWrite                -    $flux_bench_stats_ddwrite"
  echo -e "$BLUE_CIRCLE   Bench Total Storage          -    $flux_bench_stats_storage"
  echo -e "$BLUE_CIRCLE   Bench EPS                    -    $flux_bench_stats_eps"
  echo -e "$BLUE_CIRCLE   Bench Ping                   -    $flux_bench_stats_ping"
  echo -e "$BLUE_CIRCLE   Bench Download Speed         -    $flux_bench_stats_download"
  echo -e "$BLUE_CIRCLE   Bench Upload Speed           -    $flux_bench_stats_upload"
  echo -e "$BLUE_CIRCLE   Bench Speed Test Version     -    $flux_bench_stats_speed_test_version"
  echo -e "$BLUE_CIRCLE   Bench Errors                 -    $flux_bench_stats_error"
  make_header "$DASH_BENCH_PORT_TITLE" "$BLUE"
  echo -e "$flux_bench_port"

  if [[ $bench_log != "" ]]; then
    make_header "$DASH_BENCH_ERROR_TITLE" "$RED"
    echo -e "$bench_log"
  fi
 
  navigation
}

function show_available_commands(){
  clear
  sleep 0.25
  make_header "$DASH_COMMANDS_TITLE" "$BLUE"
  echo -e "$BLUE_CIRCLE   'd'            -    Show Flux Daemon Info"
  echo -e "$BLUE_CIRCLE   'n'            -    Show Flux Node Info"
  echo -e "$BLUE_CIRCLE   'b'            -    Show Flux Node Benchmark Info"
  echo -e "$BLUE_CIRCLE   'u'            -    Update Ubuntu Operating System"
  echo -e "$BLUE_CIRCLE   'q'            -    Quit Application"
  echo -e "$BLUE_CIRCLE   'c'            -    Show Available Application Commands"
  make_title
  navigation
}


# check to see if docker service is running
function check_docker_service(){
  if systemctl --type=service --state=running --quiet 2>/dev/null |grep docker >/dev/null 2>&1; then
    docker_service_status="${GREEN_ARROW}   Docker Service is ${GREEN}running${NC}"
  elif systemctl --type=service --state=failed --quiet 2>/dev/null |grep docker >/dev/null 2>&1; then
    docker_service_status="${RED_ARROW}   Docker Service is ${RED}inactive${NC}"
  else
    docker_service_status="${RED_ARROW}   Docker Service is ${RED}not installed${NC}"
  fi
}

#check to see if mongoDB service is running
function check_mongodb_service(){
  if systemctl --type=service --state=running --quiet 2>/dev/null |grep mongod >/dev/null 2>&1; then
    mongodb_service_status="${GREEN_ARROW}   MongoDB Service is ${GREEN}running${NC}"
  elif systemctl --type=service --state=failed --quiet 2>/dev/null |grep mongod >/dev/null 2>&1; then
    mongodb_service_status="${RED_ARROW}   MongoDB Service is ${RED}inactive${NC}"
  else
    mongodb_service_status="${RED_ARROW}   MongoDB Service is ${RED}not installed${NC}"
  fi
}

#check to ese if Daemon Service is running
function check_daemon_service(){
  if systemctl --type=service --state=running --quiet 2>/dev/null |grep zelcash >/dev/null 2>&1; then
    daemon_service_status="${GREEN_ARROW}   Flux Daemon Service is ${GREEN}running${NC}"
  elif systemctl --type=service --state=failed --quiet 2>/dev/null |grep zelcash >/dev/null 2>&1; then
    daemon_service_status="${RED_ARROW}   Flux Daemon Service is ${RED}inactive${NC}"
  else
    daemon_service_status="${RED_ARROW}   Flux Daemon Service is ${RED}not installed${NC}"
  fi
}

#check if pm2 flux process is running
function check_pm2_flux_service(){
  local pm2_status_check=$(pm2 info flux 2>/dev/null | grep 'status')

  if [[ $pm2_status_check == *"online"* ]]; then
    flux_process_status="${GREEN_ARROW}   Flux PM2 process is ${GREEN}running${NC}"
  elif [[ $pm2_status_check == *"offline"* ]]; then
    flux_process_status="${RED_ARROW}   Flux PM2 process is ${RED}offline${NC}"
  else
    flux_process_status="${RED_ARROW}   Flux PM2 process ${RED}not found${NC}"
  fi

}

#checks last 100 lines of daemon log file for errors or failed entries
function check_daemon_log(){
  if [[ -f $DAEMON_LOG_DIR ]]; then
    daemon_log=$(tail -100 $DAEMON_LOG_DIR | egrep -a -wi 'error|failed')
    if [[ $daemon_log == "" ]]; then
      daemon_log="${GREEN_ARROW}   No Daemon Errors logged"
    fi
  else
    daemon_log="${GREEN_ARROW}   No Daemon Errors logged"
  fi
}

function check_benchmark_log(){
  if [[ -f $BENCH_DIR_LOG ]]; then
    bench_log=$(tail -10 $BENCH_LOG_DIR| egrep -a -wi 'failed')
    if [[ $bench_log == "" ]]; then
      bench_log="${GREEN_ARROW}   No failed benchmark errors logged"
    fi
  else
    bench_log="${GREEN_ARROW}   No failed benchmark errors logged"
  fi
}

function check_ip(){
  WANIP=$(curl --silent -m 15 https://api.ipify.org | tr -dc '[:alnum:].')
  if [[ "$WANIP" == "" ]]; then
    WANIP=$(curl --silent -m 15 https://ipv4bot.whatismyipaddress.com | tr -dc '[:alnum:].')
  else
  WANIP=$(curl --silent -m 15 https://checkip.amazonaws.com | tr -dc '[:alnum:].')
  fi

  local_device_ip=$(ip a list $local_device | grep -o $WANIP)

  if [[ "$WANIP" == "$local_device_ip" ]]; then
    flux_ip_check="${GREEN_ARROW}   Public IP ${GREEN}matches${NC} device IP"
  else
    flux_ip_check="${RED_ARROW}   Public IP ${RED}does NOT match${NC} device IP"
  fi
}

function check_version(){
  ## grab current version requirements from the pacakge.json and compare to current node version
  flux_required_version=$(curl -sS --max-time 10 https://raw.githubusercontent.com/RunOnFlux/flux/master/package.json | jq -r '.version')
  if [[ "$flux_required_version" == "$flux_node_version" ]]; then
    flux_node_version_check="${GREEN_ARROW}   You have the required version ${GREEN}$flux_node_version${NC}"
  else
    flux_node_version_check="${RED_ARROW}   You do not have the required version ${GREEN}$flux_required_version${NC} - your current version is ${RED}$flux_node_version${NC}"
  fi
}

#This function simply draws a title header if arguments are provided and a footer if no arguments are provided
#If text is provided it will be centered and if a second color argument is provided it will have that color
function make_header(){
  local output
  local inputLength
  local halfInputLength
  local HEADER_TEXT_START
  local HEADER_TEXT_STOP
  output=""
  if [[ -z $1 ]]; then
    for (( c=1; c<=$WINDOW_WIDTH; c++ ))
    do 
      output="${output}${_HLINE}"
    done
  else
    inputLength=${#1}
    halfInputLength=$(bc <<<"$inputLength / 2")
    HEADER_TEXT_START=$((WINDOW_HALF_WIDTH-halfInputLength))
    HEADER_TEXT_STOP=$((HEADER_TEXT_START+inputLength))
    for (( c=1; c<=$WINDOW_WIDTH; c++ ))
    do 
      if [[ $c -lt $HEADER_TEXT_START || $c -gt $HEADER_TEXT_STOP ]]; then
        output="${output}${NC}${_HLINE}"
      else
        offset=$((c-HEADER_TEXT_START))
        output="${output}${2}${1:offset:1}"
      fi
    done
  fi

  echo -e ${output}
}

#this function simply prints tile navigation at the bottom of the current tile
function navigation(){
  make_header
  echo -e "d - daemon | b - benchmarks | n - node | q - quit | c - commands" 
}

#this function simply prints the version at the top of the page
function make_title(){
  make_header "$version" "$BLUE"
}

#checks the current window size and compares it to the last windows size to see if we need to redraw the term
function check_term_resize(){
  local currentWidth
  currentWidth=$(tput cols)
  if [[ $WINDOW_WIDTH -ne $currentWidth  ]]; then
    redraw_term='1'
  fi
}

function check_bench() {
  if [[ ($flux_bench_benchmark == "failed") || ($flux_bench_benchmark == "toaster") || ($flux_bench_benchmark == "") ]]; then
    if whiptail --title "Benchmarks Failed" --yesno "Would you like to restart your node benchmarks?" 8 60; then
      flux_update_benchmarks
    else
      whiptail --msgbox "User would not like to restart benchmarks" 8 60;
    fi
  fi
}

function check_back(){
  if [[ $flux_bench_back != *"connected"* ]]; then
    if whiptail --title "Flux Back Status Not Connected" --yesno "Would you like to update and restart the flux daemon and node?" 8 60; then
      flux_update_service
    else
      whiptail --msgbox "User would not like to update and restart flux daemon and flux node" 8 60;
    fi
  fi
}

function node_os_update(){
  if whiptail --title "Ubuntu Operating System Update" --yesno "Would you like to update the operating system?" 8 60; then
      sudo apt-get update -y && sudo apt-get --with-new-pkgs upgrade -y && sudo apt autoremove -y
    else
      whiptail --msgbox "User would not like to update the operating system" 8 60;
    fi
 
}

function flux_update_service(){
  echo -e "${RED}   Stopping Node Daemon Service"
  #sudo systemctl stop zelcash
  sleep 2
  echo -e "${RED}   Starting Node Daemon Service"
  #sudo systemctl start zelcash
  sleep 5
  echo -e "${RED}   Restarting Flux Service"
  #pm2 restart flux
  sleep 2
}

function flux_update_benchmarks(){
  echo -e "starting node benchmarks"
  redraw_term='1'
  #$BENCH_CLI restartnodebenchmarks
}

function main_terminal(){
 
  while true; do
    check_term_resize

    WINDOW_WIDTH=$(tput cols)
    WINDOW_HALF_WIDTH=$(bc <<<"$WINDOW_WIDTH / 2")

    if [[ $redraw_term == '1' ]]; then
      if [[ $show_daemon == '1' ]]; then
        flux_daemon_info
      elif [[ $show_node == '1' ]]; then
        check_back
        flux_node_info
      elif [[ $show_bench == '1' ]]; then
        flux_benchmark_info
      elif [[ $show_commands == '1' ]]; then
        show_available_commands
      fi
    fi
    update
  done
}

echo -e "\n${GREEN}gathering node and daemon info ... ${NC}"

get_flux_bench_info
get_flux_blockchain_info
get_flux_node_info
get_blocks_since_last_confirmed
check_port_info
check_docker_service
check_mongodb_service
check_daemon_service
check_pm2_flux_service
check_ip
check_version
main_terminal