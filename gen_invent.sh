#!/bin/bash

for i in {1..254}; do
  if [ `grep 192.168.6.${i} my.invent|wc -l` -eq 0 ]; then
    echo "VRRP_IP is 192.168.6.${i}"; exit 0
  fi
done
