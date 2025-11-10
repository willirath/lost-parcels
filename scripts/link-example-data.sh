#!/usr/bin/env bash

# Link release-local example-data folders to the shared cache under ./.cache.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

data_cache_default="${repo_root}/.cache/parcels-example-data"
DATA_CACHE="${PARCELS_EXAMPLE_DATA:-$data_cache_default}"

if [[ ! -d "$DATA_CACHE" ]]; then
  echo "Dataset cache '$DATA_CACHE' not found."
  echo "Download the bundles first (see README 'Download tutorial datasets')."
  exit 1
fi

relpath() {
  python3 - "$1" "$2" <<'PY'
import os
import sys

target = sys.argv[1]
base = sys.argv[2]
print(os.path.relpath(target, base))
PY
}

link_dataset() {
  local dataset="$1"
  local target_path="$2"
  local source_path="${DATA_CACHE}/${dataset}"
  local target_dir
  target_dir="$(dirname "$target_path")"

  mkdir -p "$target_dir"

  if [[ ! -d "$source_path" ]]; then
    echo "warning: dataset '$dataset' missing at '$source_path'; skip link for $target_path" >&2
    return
  fi

  if [[ -L "$target_path" || -e "$target_path" ]]; then
    if [[ -L "$target_path" ]]; then
      local current
      current="$(readlink "$target_path")"
      local desired
      desired="$(relpath "$source_path" "$target_dir")"
      if [[ "$current" == "$desired" ]]; then
        return
      fi
    fi
    echo "warning: $target_path already exists; not touching it." >&2
    return
  fi

  local relative
  relative="$(relpath "$source_path" "$target_dir")"
  ln -s "$relative" "$target_path"
  echo "linked $target_path -> $relative"
}

link_release() {
  local base="$1"
  shift
  local dataset
  for dataset in "$@"; do
    link_dataset "$dataset" "${repo_root}/${base}/${dataset}"
  done
}

link_release "parcels-v09/examples" \
  "MovingEddies_data" \
  "OFAM_example_data" \
  "Peninsula_data" \
  "GlobCurrent_example_data" \
  "DecayingMovingEddy_data"

common_py2_datasets=(
  "MovingEddies_data"
  "OFAM_example_data"
  "Peninsula_data"
  "GlobCurrent_example_data"
  "DecayingMovingEddy_data"
  "NemoCurvilinear_data"
)

link_release "parcels-v105/parcels/examples" "${common_py2_datasets[@]}"
link_release "parcels-v111/parcels/examples" "${common_py2_datasets[@]}"

echo "Symlink refresh complete."
