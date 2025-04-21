#!/bin/bash

# 获取公网 IPv4 和 IPv6
ipv4=$(curl -s https://api.ipify.org)
ipv6=$(ip -6 addr show scope global | grep inet6 | awk '{print $2}' | cut -d/ -f1 | head -n 1)

# 获取地理位置数据（使用 ip-api.com）
geo=$(curl -s https://ip-api.com/json/$ipv4)

country=$(echo "$geo" | jq -r .country)
region=$(echo "$geo" | jq -r .regionName)
city=$(echo "$geo" | jq -r .city)

# SSH 端口，默认 22，可通过参数指定
ssh_port=${1:-22}

# 提示用户输入提供商
read -p "请输入当前机器的提供商（如 Vultr、Linode）: " provider

# name 格式：provider-region
name="${provider}-${region}"

# 生成 name 的 SHA-1 哈希，取前 7 位
hash=$(echo -n "$name" | sha1sum | cut -c1-7)

# 输出 JSON
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
