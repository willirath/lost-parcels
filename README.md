# Lost Parcels

Providing environments for exploring old [OceanParcels / Parcels](https://parcels-code.org) releases.

## Get every Parcels release locally

Each `parcels-v*` directory in this repo is a git submodule pinned to the
matching upstream release tag. To grab everything in one shot, clone with
recursive submodules enabled:

```bash
git clone --recurse-submodules <repo-url>
```

If you already cloned the repo, or if a new release directory gets added later,
run the following from the repo root to make sure every submodule is present:

```bash
git submodule update --init --recursive
```

Whenever a new Parcels release lands in this repo, re-running that command (or
`git submodule update --remote` if you want to track the newest upstream tags)
will pull down the matching `parcels-vXYZ/` contents so Pixi can see them.

## Download tutorial datasets

We keep every NetCDF bundle in a single cache outside of the submodules and then
symlink the legacy paths that older releases expect. That way, you only have to
download the data once and newer releases can continue reusing it even if the
upstream URLs disappear.

1. Pick a cache (default is `./.cache/parcels-example-data`) and tell Pixi where
   it lives:

   ```bash
   export PARCELS_DATA_CACHE="$PWD/.cache/parcels-example-data"
   export PARCELS_EXAMPLE_DATA="$PARCELS_DATA_CACHE"
   mkdir -p "$PARCELS_DATA_CACHE"
   ```

2. Download the union of all datasets by reusing the latest Parcels helper
   (adjust the loop if you only need a subset):

   ```bash
   env PARCELS_EXAMPLE_DATA="$PARCELS_DATA_CACHE" \
     pixi run parcels-v314-python <<'PY'
   from parcels import download_example_dataset, list_example_datasets
   for dataset in list_example_datasets():
       download_example_dataset(dataset)
   PY
   ```

3. Create symlinks for the Python 2 releases so they continue to find the data
   under `parcels-vXYZ/parcels/examples`:

   ```bash
   PARCELS_EXAMPLE_DATA="$PARCELS_DATA_CACHE" bash scripts/link-example-data.sh
   ```

   The script links the directories required by `v09`, `v105`, and `v111`
   (moving them out of the submodule trees if necessary) while leaving the
   shared cache untouched.

4. When running the Python 3 releases (`v242`, `v314`), keep
   `PARCELS_EXAMPLE_DATA` exported so their `parcels.download_example_dataset`
   calls reuse the cache instead of trying to download everything again.

The helper functions skip files that already exist, so re-running these commands
after a pull only grabs newly added datasets. Keeping the cache inside the repo
(`.cache/…`) prevents writes to `$HOME` on headless runners.

Current dataset folders: `MovingEddies_data`, `OFAM_example_data`,
`Peninsula_data`, `GlobCurrent_example_data`, `DecayingMovingEddy_data`,
`NemoCurvilinear_data`, `MITgcm_example_data`, `NemoNorthSeaORCA025-N006_data`,
`POPSouthernOcean_data`, `SWASH_data`, `WOA_data`, and `CROCOidealized_data`
(`CROCO` is only used by `v314`). Update this list + the linking script whenever
new upstream tutorials reference additional data.

## Workflow Overview

Every OceanParcels release in this repo follows the same pattern:

1. Each version lives in `parcels-vXYZ/` (a git submodule checked out at the
   matching upstream tag).
2. Pixi exposes an environment named `parcels-vXYZ` and three tasks:
   `bootstrap-vXYZ`, `parcels-vXYZ-python`, `parcels-vXYZ-notebook`.
3. The bootstrap script installs parcels in editable mode (`pip install -e`),
   so any edits to the submodule are immediately importable without reinstalling.

### Common commands

Pick a slug (`v09`, `v111`, `v242`, `v314`, …) from the table below and run:

```bash
export PARCELS_SLUG=v242   # or v09 / v111 / …

# resolve the conda environment for that slug
pixi install -e parcels-$PARCELS_SLUG

# install pip-only extras + editable package
pixi run bootstrap-$PARCELS_SLUG

# run scripts or modules bundled with that checkout
pixi run parcels-$PARCELS_SLUG-python -c 'import parcels; print("Loaded parcels from:", parcels.__file__)'
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
| `v105` | `v1.0.5` | 2.7 | `parcels-v105/parcels/examples` | `scripts/bootstrap-parcels-v105.sh` | First stable v1.0.x release; editable install for `_version` generation. |
| `v111` | `v1.1.1` | 2.7 | `parcels-v111/parcels/examples` | `scripts/bootstrap-parcels-v111.sh` | Builds an editable install because the package imports `parcels._version`. |
| `v242` | `v2.4.2` | 3.10 | `parcels-v242/docs/examples` | `scripts/bootstrap-parcels-v242.sh` | Uses modern Py3 stack; Matplotlib caches under `.cache/matplotlib`. |
| `v314` | `v3.1.4` | 3.11 | `parcels-v314/docs/examples` | `scripts/bootstrap-parcels-v314.sh` | Latest v3 release; Notebook 7 + docs/examples layout. |

### Release notes

**`v09`**  
- Minimal Python 2.7 stack mirroring the 2017 OceanParcels release.  
- Bootstrap script installs the PyPI-only wheels (`cgen`, `progressbar`, `pymbolic`)
  and performs an editable install.
- Runtime tasks disable automatic browser
  launches for the legacy notebook server.

**`v105`**
- Stable v1.0.x release (Python 2.7) representing the first production-ready v1 line.
- Environment mirrors `environment_py2_osx.yml` with dependencies from the upstream tag
  (matplotlib 2.2.* used for conda-forge compatibility).
- Bootstrap script installs pip-only wheels (`cgen<2020`, `pymbolic<2020`, `progressbar2<4`)
  then runs `pip install -e parcels-v105` to generate `parcels._version`.
- Notebook task points at `parcels-v105/parcels/examples` for v1.0.5 example notebooks.
- Bridges the gap between v0.9 (early experimental) and v1.1.1 (mature v1.x).

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

**`v314`**  
- Modern v3.1.4 release tracked from the PyProject-based tree (Python 3.11).  
- Bootstrap script just runs `pip install -e parcels-v314` because the build now
  ships with `pyproject.toml`.  
- Runtime tasks keep the same headless settings as v242, export `MPLCONFIGDIR`
  for Matplotlib caches, and point Jupyter at `parcels-v314/docs/examples`.  
- Extra tooling (`trajan`, `mypy`, `types-*`, Notebook 7) is available directly
  in the Pixi environment for parity with the upstream `environment.yml`.
