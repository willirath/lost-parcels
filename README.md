# Lost Parcels

Providing environments for exploring old [OceanParcels / Parcels](https://parcels-code.org) releases.

## Workflow Overview

Every OceanParcels release in this repo follows the same pattern:

1. Each version lives in `parcels-vXYZ/` (a git submodule checked out at the
   matching upstream tag).
2. Pixi exposes an environment named `parcels-vXYZ` and three tasks:  
   `bootstrap-vXYZ`, `parcels-vXYZ-python`, `parcels-vXYZ-notebook`.
3. The Python/Jupyter tasks run directly from the vendored sources by setting
   `PYTHONPATH=$PWD/parcels-vXYZ`, so any edits to the submodule are immediately
   importable.

### Common commands

Pick a slug (`v09`, `v111`, `v242`, …) from the table below and run:

```bash
export PARCELS_SLUG=v242   # or v09 / v111 / …

# resolve the conda environment for that slug
pixi install -e parcels-$PARCELS_SLUG

# install pip-only extras + editable package
pixi run bootstrap-$PARCELS_SLUG

# run scripts or modules bundled with that checkout
pixi run parcels-$PARCELS_SLUG-python -c 'import parcels; print(parcels.__version__)'
pixi run parcels-$PARCELS_SLUG-python parcels-$PARCELS_SLUG/.../example_brownian.py

# start the matching notebook server (headless friendly)
pixi run parcels-$PARCELS_SLUG-notebook
```

The notebook and Python tasks already set the correct working directories and
environment variables for each release, so you only need to provide the script,
module, or notebook you want to run.

## Supported releases

| Slug | Upstream tag | Python | Notebook root | Bootstrap script | Notes |
| ---- | ------------ | ------ | ------------- | ---------------- | ----- |
| `v09`  | `v0.9`   | 2.7 | `parcels-v09/examples` | `scripts/bootstrap-parcels-v09.sh` | Installs legacy pip-only wheels (`cgen`, `progressbar`, `pymbolic`). |
| `v111` | `v1.1.1` | 2.7 | `parcels-v111/parcels/examples` | `scripts/bootstrap-parcels-v111.sh` | Builds an editable install because the package imports `parcels._version`. |
| `v242` | `v2.4.2` | 3.10 | `parcels-v242/docs/examples` | `scripts/bootstrap-parcels-v242.sh` | Uses modern Py3 stack; Matplotlib caches under `.cache/matplotlib`. |

### Release notes

**`v09`**  
- Minimal Python 2.7 stack mirroring the 2017 OceanParcels release.  
- Bootstrap script installs the few remaining PyPI-only wheels every time the
  env is recreated.  
- Runtime tasks keep `PYTHONPATH=./parcels-v09` and disable automatic browser
  launches for the legacy notebook server.

**`v111`**  
- Adds the extra historic dependencies from `environment_py2_osx.yml` and still
  targets Python 2.7.  
- Bootstrap script installs the pip-only wheels, then runs
  `pip install -e parcels-v111` to materialise `parcels._version`.  
- Notebook task points at `parcels-v111/parcels/examples`, which is where the
  v1.1.1 notebooks live.

**`v242`**  
- Latest v2 line checked out at tag `v2.4.2` with a Python 3.10 toolchain.  
- Bootstrap script installs `setuptools_scm_git_archive` before the editable
  install so `_version` files are generated.  
- Python/notebook tasks export `MPLCONFIGDIR=$PWD/.cache/matplotlib` to avoid
  writes into `$HOME`, and they look in `parcels-v242/docs/examples` for scripts
  and notebooks.  
- MPI tooling (`mpi4py`, `mpich`) is intentionally omitted from the default
  feature; add them yourself if you run outside sandboxed environments.
