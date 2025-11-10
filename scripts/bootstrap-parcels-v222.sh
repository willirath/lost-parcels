#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
pip install "setuptools_scm_git_archive>=1.0,<2"
pip install "progressbar2<4" "python-utils<3"
pip install -e parcels-v222
