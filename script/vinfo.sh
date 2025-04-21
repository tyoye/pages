#!/bin/bash

# 获取命令行传递的参数（如果没有提供参数，则提示用户输入）
provider=${1:-$(read -p "请输入当前机器的提供商（如 Vultr、Linode）： " provider && echo "$provider")}

# 获取公网 IPv4 和 IPv6
ipv4=$(curl -s https://api.ipify.org)
ipv6=$(ip -6 addr show scope global | grep inet6 | awk '{print $2}' | cut -d/ -f1 | head -n 1)

# 获取地理位置数据（使用 ipinfo.check.place）
geo=$(curl -s "https://ipinfo.check.place/$ipv4")

# 解析 JSON 数据
asn_number=$(echo "$geo" | jq -r .ASN.AutonomousSystemNumber)
asn_org=$(echo "$geo" | jq -r .ASN.AutonomousSystemOrganization)
city_name=$(echo "$geo" | jq -r .City.Name)
postal_code=$(echo "$geo" | jq -r .City.PostalCode)
latitude=$(echo "$geo" | jq -r .City.Latitude)
longitude=$(echo "$geo" | jq -r .City.Longitude)
timezone=$(echo "$geo" | jq -r .City.Location.TimeZone)
country_name=$(echo "$geo" | jq -r .City.Country.Name)
country_iso=$(echo "$geo" | jq -r .City.Country.IsoCode)
region_name=$(echo "$geo" | jq -r .City.Subdivisions[0].Name)

# name 格式：provider-region
name="${provider}-${region_name}"

# 生成 name 的 SHA-1 哈希，取前 7 位
hash=$(echo -n "$name" | sha1sum | cut -c1-7)

# 输出 JSON
cat <<EOF
{
  "hash": "$hash",
  "name": "$name",
  "location": {
    "country": "$country_name",
    "region": "$region_name",
    "city": "$city_name",
    "postal_code": "$postal_code",
    "latitude": $latitude,
    "longitude": $longitude,
    "timezone": "$timezone"
  },
  "ASN": {
    "number": "$asn_number",
    "organization": "$asn_org"
  },
  "provider": "$provider",
  "ip": {
    "ipv4": "$ipv4",
    "ipv6": "$ipv6"
  },
  "ssh_port": 22
}
EOF
