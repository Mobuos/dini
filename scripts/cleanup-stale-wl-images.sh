#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
IMAGE_DIR="$REPO_ROOT/resources/wl-images"
CONFIG_FILE="$REPO_ROOT/data/wishlist.jsonc"

if [[ ! -d "$IMAGE_DIR" ]]; then
  printf 'Image directory not found: %s\n' "$IMAGE_DIR" >&2
  exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  printf 'Configuration file not found: %s\n' "$CONFIG_FILE" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf -- "$tmp_dir"' EXIT

find "$IMAGE_DIR" -maxdepth 1 -type f \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) \
  -printf '%f\n' | sort > "$tmp_dir/images"

sed -nE 's#.*resources/wl-images/([^"]+)"[[:space:]]*,?[[:space:]]*$#\1#p' "$CONFIG_FILE" |
  sort -u > "$tmp_dir/referenced"

comm -23 "$tmp_dir/images" "$tmp_dir/referenced" > "$tmp_dir/stale"

if [[ ! -s "$tmp_dir/stale" ]]; then
  printf 'No stale images found.\n'
  exit 0
fi

printf 'The following stale images will be deleted:\n'
while IFS= read -r image; do
  printf '  %s\n' "$image"
done < "$tmp_dir/stale"

printf '\nDelete these images? [y/N] '
read -r answer

if [[ ! "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
  printf 'Deletion cancelled.\n'
  exit 0
fi

while IFS= read -r image; do
  rm -- "$IMAGE_DIR/$image"
done < "$tmp_dir/stale"

printf 'Deleted stale images.\n'
