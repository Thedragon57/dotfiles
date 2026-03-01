#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <input_music_folder> <output_folder>"
  exit 1
fi

INPUT_DIR="$(realpath "$1")"
OUTPUT_DIR="$(realpath "$2")"
mkdir -p "$OUTPUT_DIR"

sanitize() {
  # keep it filesystem-safe
  echo "$1" | tr '/' '_' | tr -d '\000' | sed 's/[[:cntrl:]]//g'
}

get_tag() {
  local file="$1" key="$2"
  ffprobe -v error -show_entries "format_tags=$key" -of default=nw=1:nk=1 "$file" 2>/dev/null || true
}

find "$INPUT_DIR" -type f \( \
  -iname "*.flac" -o -iname "*.mp3" -o -iname "*.ogg" -o -iname "*.opus" -o -iname "*.m4a" -o -iname "*.aac" -o -iname "*.wav" \
\) -print0 | while IFS= read -r -d '' file; do

  rel_dir="$(dirname "${file#$INPUT_DIR/}")"
  artist="$(sanitize "$(get_tag "$file" artist)" | sed 's/;/\&/g; s/ //g; s/-//g;')"
  title="$(sanitize "$(get_tag "$file" title)")"
  album="$(sanitize "$(get_tag "$file" album)" | sed 's/ //g')"

  # fallbacks
  base="$(basename "${file%.*}")"
  [[ -z "$artist" ]] && artist="UnknownArtist"
  [[ -z "$title"  ]] && title="$base"

  #Output name goes here!
  out_name="${title} - ${artist}.wav"
  out_path="$OUTPUT_DIR/$rel_dir/$out_name"

  mkdir -p "$(dirname "$out_path")"

  if [[ -f "$out_path" ]]; then
    echo "Skipping (exists): $rel_dir/$out_name"
    continue
  fi

  echo "Converting: ${file#$INPUT_DIR/} -> $rel_dir/$out_name"

  ffmpeg -hide_banner -loglevel error -y \
    -i "$file" \
    -map_metadata 0 \
    -vn \
    -c:a pcm_s16le \
    "$out_path"
done

echo "Done."
