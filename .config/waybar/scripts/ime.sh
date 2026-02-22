#!/bin/bash
IM=$(fcitx5-remote -n)

if [[ "$IM" == "mozc" ]]; then
  echo '{"text":"JP ","class":"jp"}'
else
  echo '{"text":"EN ","class":"en"}'
fi
