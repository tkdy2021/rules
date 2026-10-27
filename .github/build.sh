#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

convert_geoip() {
  local dir="$1" f
  rm -rf "$dir/classical"
  rm -f "$dir"/*.yaml "$dir"/*.mrs
  for f in "$dir"/*.list; do
    [ -e "$f" ] || continue
    awk '{
      gsub(/[\t\r ]/, "")
      if ($0 == "" || $0 ~ /^#/) next
      if ($0 ~ /:/) print "IP-CIDR6," $0 ",no-resolve"
      else           print "IP-CIDR,"  $0 ",no-resolve"
    }' "$f" > "${f%.list}.lrs"
  done
  rm -f "$dir"/*.list
}

convert_geosite() {
  local dir="$1" f
  rm -rf "$dir/classical"
  rm -f "$dir"/*.yaml "$dir"/*.mrs
  for f in "$dir"/*.list; do
    [ -e "$f" ] || continue
    awk '{
      gsub(/[\t\r ]/, "")
      if ($0 == "" || $0 ~ /^#/) next
      if ($0 ~ /^(\+\.|\*\.)/) print "DOMAIN-SUFFIX," substr($0, 3)
      else                      print "DOMAIN," $0
    }' "$f" > "${f%.list}.lrs"
  done
  rm -f "$dir"/*.list
}

process_tree() {
  local base="$1"
  convert_geoip "$base/geoip"
  rm -rf "$base/geoip_no_resolve"
  cp -r "$base/geoip" "$base/geoip_no_resolve"
  sed -i 's/,no-resolve$//' "$base"/geoip/*.lrs
  convert_geosite "$base/geosite"
}

rm -rf ./asn
process_tree geo-lite
process_tree geo