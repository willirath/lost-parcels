#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
pip install 'cgen<2020' 'progressbar<3' 'pymbolic<2020'
pip install -e parcels-v09
