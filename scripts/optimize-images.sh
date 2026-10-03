#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
IMAGE_DIR="$REPO_ROOT/resources/wl-images"

if ! command -v magick >/dev/null 2>&1; then
    printf 'ImageMagick (magick) is required to build WebP images.\n' >&2
    exit 1
fi

converted=0
skipped=0
original_bytes=0
webp_bytes=0

while IFS= read -r -d '' source; do
    extension="${source##*.}"
    extension="${extension,,}"
    if [[ "$extension" == "webp" ]]; then
        ((skipped += 1))
        continue
    fi

    output="${source%.*}.webp"
    if [[ -e "$output" ]]; then
        printf 'Skipping existing output: %s\n' "${output#"$REPO_ROOT/"}"
        ((skipped += 1))
        continue
    fi

    magick "$source" -auto-orient -strip -resize '1200x1200>' \
        -quality 82 -define webp:method=6 "$output"
    source_size=$(stat -c '%s' "$source")
    output_size=$(stat -c '%s' "$output")
    original_bytes=$((original_bytes + source_size))
    webp_bytes=$((webp_bytes + output_size))
    ((converted += 1))
    printf '%s -> %s (%s -> %s bytes)\n' \
        "${source#"$REPO_ROOT/"}" "${output#"$REPO_ROOT/"}" \
        "$source_size" "$output_size"
done < <(find "$IMAGE_DIR" -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
    -print0 | sort -z)

printf '\nConverted %d image(s); skipped %d.\n' "$converted" "$skipped"
if (( converted > 0 )); then
    printf 'Converted source total: %s bytes; WebP total: %s bytes.\n' \
        "$original_bytes" "$webp_bytes"
fi
