#!/bin/bash

declare -A PC_IPS=(
  [PC11_IPV4]="192.168.11.2"
  [PC11_IPV6]="c1:1:feed::2"
  [PC12_IPV4]="192.168.12.2"
  [PC12_IPV6]="c1:2:feed::2"
  [PC13_IPV4]="192.168.13.2"
  [PC13_IPV6]="c1:3:feed::2"
  [PC21_IPV4]="192.168.21.2"
  [PC21_IPV6]="c2:1:feed::2"
  [PC22_IPV4]="192.168.22.2"
  [PC22_IPV6]="c2:2:feed::2"
  [PC23_IPV4]="192.168.23.2"
  [PC23_IPV6]="c2:3:feed::2"
)

# Define pairs to test for each client
declare -a CLIENT1_TESTS=(
  "PC11 PC12 ${PC_IPS[PC11_IPV4]} ${PC_IPS[PC12_IPV4]}"
  "PC11 PC12 ${PC_IPS[PC11_IPV6]} ${PC_IPS[PC12_IPV6]}"
  "PC11 PC13 ${PC_IPS[PC11_IPV4]} ${PC_IPS[PC13_IPV4]}"
  "PC11 PC13 ${PC_IPS[PC11_IPV6]} ${PC_IPS[PC13_IPV6]}"
  "PC12 PC13 ${PC_IPS[PC12_IPV4]} ${PC_IPS[PC13_IPV4]}"
  "PC12 PC13 ${PC_IPS[PC12_IPV6]} ${PC_IPS[PC13_IPV6]}"
)
declare -a CLIENT2_TESTS=(
  "PC21 PC22 ${PC_IPS[PC21_IPV4]} ${PC_IPS[PC22_IPV4]}"
  "PC21 PC22 ${PC_IPS[PC21_IPV6]} ${PC_IPS[PC22_IPV6]}"
  "PC21 PC23 ${PC_IPS[PC21_IPV4]} ${PC_IPS[PC23_IPV4]}"
  "PC21 PC23 ${PC_IPS[PC21_IPV6]} ${PC_IPS[PC23_IPV6]}"
  "PC22 PC23 ${PC_IPS[PC22_IPV4]} ${PC_IPS[PC23_IPV4]}"
  "PC22 PC23 ${PC_IPS[PC22_IPV6]} ${PC_IPS[PC23_IPV6]}"
)

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Handle CTRL-C
trap "echo -e '\nInterrupted. Exiting.'; exit 130" SIGINT

printf "\nLayer3 VPN Connectivity Validation\n"
printf "================================\n"

printf "\nClient 1:\n"
for test in "${CLIENT1_TESTS[@]}"; do
  set -- $test
  SRC=$1; DST=$2; SRC_IP=$3; DST_IP=$4
  if [[ $DST_IP == *:* ]]; then
    PING_CMD="ping6 -c 2 -W 1 $DST_IP"
  else
    PING_CMD="ping -c 2 -W 1 $DST_IP"
  fi
  docker exec -i $SRC $PING_CMD > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    printf "${GREEN}✅${NC} $SRC ($SRC_IP) <-> $DST ($DST_IP)\n"
  else
    printf "${RED}❌${NC} $SRC ($SRC_IP) <-> $DST ($DST_IP)\n"
  fi
done

printf "\nClient 2:\n"
for test in "${CLIENT2_TESTS[@]}"; do
  set -- $test
  SRC=$1; DST=$2; SRC_IP=$3; DST_IP=$4
  if [[ $DST_IP == *:* ]]; then
    PING_CMD="ping6 -c 2 -W 1 $DST_IP"
  else
    PING_CMD="ping -c 2 -W 1 $DST_IP"
  fi
  docker exec -i $SRC $PING_CMD > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    printf "${GREEN}✅${NC} $SRC ($SRC_IP) <-> $DST ($DST_IP)\n"
  else
    printf "${RED}❌${NC} $SRC ($SRC_IP) <-> $DST ($DST_IP)\n"
  fi
done

printf "================================\n\n"