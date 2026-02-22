#!/bin/bash
# Show util + temp for all NVIDIA GPUs
# Output example: "󰢮 0:12% 57°C | 1:03% 41°C"

mapfile -t lines < <(nvidia-smi --query-gpu=index,utilization.gpu,temperature.gpu \
  --format=csv,noheader,nounits)

out=""
for l in "${lines[@]}"; do
  # l like: "0, 12, 57"
  idx=$(echo "$l" | cut -d',' -f1 | xargs)
  util=$(echo "$l" | cut -d',' -f2 | xargs)
  temp=$(echo "$l" | cut -d',' -f3 | xargs)
  seg="${idx}:${util}% ${temp}°C"
  if [[ -z "$out" ]]; then
    out="$seg"
  else
    out="$out | $seg"
  fi
done

echo "󰢮 $out"