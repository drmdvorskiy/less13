#!/bin/bash

for i in {1..254}; do
  if [ `grep 192.168.6.${i} my.invent|wc -l` -ne 1 ]; then
    echo "VRRP_IP is 192.168.6.${i}"
  fi
done
