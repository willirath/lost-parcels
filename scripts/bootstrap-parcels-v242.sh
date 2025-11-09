#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
pip install "setuptools_scm_git_archive>=1.4.1,<1.5"
pip install -e parcels-v242
