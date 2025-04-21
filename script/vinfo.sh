#!/bin/bash


ipv4=$(curl -s https://ipinfo.io/ip)
ipv6=$(ip -6 addr show scope global | grep inet6 | awk '{print $2}' | cut -d/ -f1 | head -n 1)


geo=$(curl -s https://ipinfo.io/json)

country=$(echo "$geo" | jq -r .country)
region=$(echo "$geo" | jq -r .region)
city=$(echo "$geo" | jq -r .city)


ssh_port=${1:-22}


read -p "请输入当前机器的提供商（如 Vultr、Linode）: " provider


name="${provider}-${region}"


hash=$(echo -n "$name" | sha1sum | cut -c1-7)


cat <<EOF
{
  "hash": "$hash",
  "name": "$name",
  "location": {
    "country": "$country",
    "region": "$region",
    "city": "$city"
  },
  "provider": "$provider",
  "ip": {
    "ipv4": "$ipv4",
    "ipv6": "$ipv6"
  },
  "ssh_port": $ssh_port
}
EOF
