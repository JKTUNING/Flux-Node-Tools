#!/bin/bash

#fluxbench-cli getbenchmarks | grep status > currentBenchmarks

fluxbench-cli getstatus > currentFluxBack
fluxbench-cli getbenchmarks > currentBenchmarks

flux_status=$(grep -i "status" currentFluxBack)
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
  if [[ (-z $bench_status) || ($bench_status == *"failed"*) || ($bench_status == *"toaster"*) ]];
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
  else
    echo 'node oprating normally'
  fi
}

function check_back(){
  if [[ ($flux_back = *"disconnected"*) || (-z $flux_back) ]];
  then
    echo 'flux back disconnected'
    read -p 'would you like to check for updates and restart flux-back? (y/n) ' userInput
    if [ $userInput == 'n' ]
    then
      echo 'user does not want to restart flux back'
	      else
      echo 'user would like to update and restart flux-back'
      flux_update_restart
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
check_bench
check_back
