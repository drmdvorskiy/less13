#!/usr/bin/env bash

origin_ip=`terraform output external_ip_address_origin | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
fe0_ip=`terraform output external_ip_address_fe0 | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
fe1_ip=`terraform output external_ip_address_fe1 | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
web0_ip=`terraform output external_ip_address_web0 | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
web1_ip=`terraform output external_ip_address_web1 | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
web2_ip=`terraform output external_ip_address_web2 | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
db_ip=`terraform output external_ip_address_db | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
iscsi_ip=`terraform output external_ip_address_iscsi | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
hname_web0=`terraform output hostname_web0 | grep -Po '\w+'`
hname_web1=`terraform output hostname_web1 | grep -Po '\w+'`
hname_web2=`terraform output hostname_web2 | grep -Po '\w+'`
int_iscsi_ip=`terraform output internal_ip_address_iscsi | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
int_web0_ip=`terraform output internal_ip_address_web0 | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
int_web1_ip=`terraform output internal_ip_address_web1 | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
int_web2_ip=`terraform output internal_ip_address_web2 | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
int_db_ip=`terraform output internal_ip_address_db | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
echo "[origin]" > my.invent
echo "${origin_ip}" >> my.invent
echo "" >> my.invent
echo "[fe]" >> my.invent
echo "${fe0_ip}" >> my.invent
echo "${fe1_ip}" >> my.invent
echo "" >> my.invent
echo "[web]" >> my.invent
echo "${web0_ip}" >> my.invent
echo "${web1_ip}" >> my.invent
echo "${web2_ip}" >> my.invent
echo "" >> my.invent
echo "[db]" >> my.invent
echo "${db_ip}" >> my.invent
echo "" >> my.invent
echo "[iscsi]" >> my.invent
echo "${iscsi_ip}" >> my.invent
echo "" >> my.invent
echo "[web0]" >> my.invent
echo "${web0_ip}" >> my.invent
echo "" >> my.invent
echo "[fe0]" >> my.invent
echo "${fe0_ip}" >> my.invent
echo "" >> my.invent
echo "[fe1]" >> my.invent
echo "${fe1_ip}" >> my.invent
echo "===== inventory hase been generated ====="

echo "int_iscsi_ip: ${int_iscsi_ip}" > roles/create-initiator/vars/main.yml

# for VRRP address
arr=(`grep -Po "(\d+\.){3}\d+" my.invent | cut -d "." -f 4`)
for i in {1..254}; do
  if [ `echo "${arr[@]}" | tr " " "\n" | grep "^${i}$" | wc -l` -eq 0 ]; then
    echo "VRRP: 192.168.6.${i}" > group_vars/fe0
    echo "state: MASTER" >> group_vars/fe0
    echo "priority: 101" >> group_vars/fe0
    echo "VRRP: 192.168.6.${i}" > group_vars/fe1
    echo "state: BACKUP" >> group_vars/fe1
    echo "priority: 80" >> group_vars/fe1
    break
  fi
done

# for /etc/hosts
echo "${int_web0_ip}   ${hname_web0}" > roles/install-pacemaker/files/hosts
echo "${int_web1_ip}   ${hname_web1}" >> roles/install-pacemaker/files/hosts
echo "${int_web2_ip}   ${hname_web2}" >> roles/install-pacemaker/files/hosts
echo "===== file etc/hosts hase been generated ====="

nodes=`echo "${hname_web0} ${hname_web1} ${hname_web2}"`
sed -i '/^nodes/d' roles/install-pacemaker/vars/main.yml
sed -i "$ a nodes: '${nodes}'" roles/install-pacemaker/vars/main.yml

echo "int_web0_ip: ${int_web0_ip}" > roles/configure-nginx-fronts/vars/main.yml
echo "int_web1_ip: ${int_web1_ip}" >> roles/configure-nginx-fronts/vars/main.yml
echo "int_web2_ip: ${int_web2_ip}" >> roles/configure-nginx-fronts/vars/main.yml

echo "int_db_ip: ${int_db_ip}" > roles/configure-nginx-backends/vars/main.yml
###################################################################################
float=`grep -Po "(\d+\.){3}\d+" group_vars/fe0`
echo -e "- ssh ubuntu@${origin_ip}\n- curl ${float}/index.php"
