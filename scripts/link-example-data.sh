#!/usr/bin/env bash

# Link release-local example-data folders to the shared cache under ./.cache.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/link-example-data.sh [slug ...]

Create symlinks from release-local example directories into the shared cache.
If no slug is provided, every supported release is linked.
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

data_cache_default="${repo_root}/.cache/parcels-example-data"
DATA_CACHE="${PARCELS_EXAMPLE_DATA:-$data_cache_default}"

if [[ ! -d "$DATA_CACHE" ]]; then
  echo "Dataset cache '$DATA_CACHE' not found."
  echo "Run 'pixi run bootstrap-example-data' first."
  exit 1
fi

declare -A RELEASE_PATHS=(
  [v09]="parcels-v09/examples"
  [v105]="parcels-v105/parcels/examples"
  [v111]="parcels-v111/parcels/examples"
)

declare -A RELEASE_DATASETS
RELEASE_DATASETS[v09]="MovingEddies_data OFAM_example_data Peninsula_data GlobCurrent_example_data DecayingMovingEddy_data"
RELEASE_DATASETS[v105]="MovingEddies_data OFAM_example_data Peninsula_data GlobCurrent_example_data DecayingMovingEddy_data NemoCurvilinear_data"
RELEASE_DATASETS[v111]="${RELEASE_DATASETS[v105]}"

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
    echo "error: dataset '$dataset' missing at '$source_path'. Run 'pixi run bootstrap-example-data'." >&2
    return 1
  fi

  if [[ -L "$target_path" || -e "$target_path" ]]; then
    if [[ -L "$target_path" ]]; then
      local current
      current="$(readlink "$target_path")"
      local desired
      desired="$(relpath "$source_path" "$target_dir")"
      if [[ "$current" == "$desired" ]]; then
        return 0
      fi
    fi
    echo "warning: $target_path already exists; not touching it." >&2
    return 0
  fi

  local relative
  relative="$(relpath "$source_path" "$target_dir")"
  ln -s "$relative" "$target_path"
  echo "linked $target_path -> $relative"
}

link_release() {
  local slug="$1"
  local base="${RELEASE_PATHS[$slug]}"
  local datasets_string="${RELEASE_DATASETS[$slug]}"
  local dataset
  local status=0
  while read -r dataset; do
    [[ -z "$dataset" ]] && continue
    if ! link_dataset "$dataset" "${repo_root}/${base}/${dataset}"; then
      status=1
    fi
  done < <(tr ' ' '\n' <<<"$datasets_string")
  return $status
}

targets=()
if [[ $# -eq 0 ]]; then
  targets=(v09 v105 v111)
else
  for slug in "$@"; do
    if [[ -z "${RELEASE_PATHS[$slug]:-}" ]]; then
      usage
      echo "Unknown slug '$slug' (expected: v09, v105, v111)." >&2
      exit 1
    fi
    targets+=("$slug")
  done
fi

overall_status=0
for slug in "${targets[@]}"; do
  echo "Linking datasets for $slug..."
  if ! link_release "$slug"; then
    overall_status=1
  fi
done

if [[ $overall_status -ne 0 ]]; then
  exit $overall_status
fi

echo "Symlink refresh complete."
