#!/usr/bin/env bash
arr=(`grep -Po "(\d+\.){3}\d+" my.invent | cut -d "." -f 4`)


for i in {1..254}; do
  if [ `echo "${arr[@]}" | tr " " "\n" | grep "^${i}$" | wc -l` -eq 0 ]; then
    echo "VRRP=192.168.6.${i}"
    break
  fi
done
