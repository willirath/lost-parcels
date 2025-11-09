# Lost Parcels Agent Notes

## Per-version playbook

Use this checklist whenever a new OceanParcels release is added:

1. **Clone the submodule** at `parcels-vXYZ/` (name = `parcels-v{slug}`). Checkout
   the upstream tag you care about and add it to `.gitmodules`.
2. **Define a Pixi feature/environment** named `parcels-vXYZ`. Keep the version’s
   platform requirements isolated; mirror the old upstream `environment_*.yml`
   when possible.
3. **Add three Pixi tasks** under that feature:
   - `bootstrap-vXYZ` → calls `scripts/bootstrap-parcels-vXYZ.sh`.
   - `parcels-vXYZ-python` → sets `PYTHONPATH=$PWD/parcels-vXYZ` (plus any
     extra env like `MPLCONFIGDIR`) and runs `python`.
   - `parcels-vXYZ-notebook` → same env setup, points Jupyter at the correct
     examples directory, and disables browser launch.
4. **Write the bootstrap script** to install any pip-only packages and finish
   with `pip install -e parcels-vXYZ` whenever the package expects `_version`
   files. Shell scripts keep the Pixi config consistent.
5. **Document the release** in `README.md` and update this file to note any
   quirks (extra pip deps, notebook paths, MPI requirements, etc.).
6. **Headless hygiene**: ensure every runtime task avoids launching browsers,
   writes caches inside the repo (e.g. `.cache/matplotlib`), and does not assume
   MPI availability unless explicitly added.

Following this pattern means future releases only need new submodule + feature
entries and a short README/agent blurb.

## Current releases

### `v09` (tag `v0.9`, Python 2.7)
- Environment: legacy Py2 stack with `pixi install -e parcels-v09`.
- Bootstrap: `scripts/bootstrap-parcels-v09.sh` installs the PyPI-only wheels
  (`cgen<2020`, `progressbar<3`, `pymbolic<2020`).
- Runtime tasks: `parcels-v09-python` / `parcels-v09-notebook` set
  `PYTHONPATH=./parcels-v09` and run inside `parcels-v09/examples`.
- Notes: no editable install required, but notebooks must keep
  `--NotebookApp.open_browser=False`.

### `v111` (tag `v1.1.1`, Python 2.7)
- Environment: extends the Py2 stack with the extra packages from
  `environment_py2_osx.yml` (e.g. `cachetools`, `progressbar2`, `matplotlib 2.2.*`).
- Bootstrap: `scripts/bootstrap-parcels-v111.sh` installs the missing pip wheels
  and runs `pip install -e parcels-v111` because the code imports `parcels._version`.
- Runtime tasks: point Jupyter at `parcels-v111/parcels/examples` so the bundled
  notebooks resolve resources correctly.
- Notes: same headless settings as v0.9; keep Python 2.7 tooling pinned.

### `v242` (tag `v2.4.2`, Python 3.10)
- Environment: modern Py3 toolchain derived from `environment_py3_osx.yml`
  (MPI packages intentionally omitted in Pixi because sandboxed runs lack NIC access).
- Bootstrap: `scripts/bootstrap-parcels-v242.sh` first installs
  `setuptools_scm_git_archive` (needed for `_version` generation) and then
  performs the editable install.
- Runtime tasks: export both `PYTHONPATH=./parcels-v242` and
  `MPLCONFIGDIR=$PWD/.cache/matplotlib`, point notebooks at
  `parcels-v242/docs/examples`, and keep browser auto-open disabled.
- Notes: If users need MPI locally they can add `mpi4py/mpich` to the Pixi
  feature before running `pixi install`; leave them out by default for portability.

### `v314` (tag `v3.1.4`, Python 3.11)
- Environment: mirrors the upstream `environment.yml` for the PyProject-based
  release (Notebook 7, typing extras, docs stack, but still no MPI).
- Bootstrap: `scripts/bootstrap-parcels-v314.sh` simply runs
  `pip install -e parcels-v314` because setuptools-scm is already part of the
  environment.
- Runtime tasks: same headless env vars as v242 (`PYTHONPATH` + `MPLCONFIGDIR`)
  but point at `parcels-v314/docs/examples`.
- Notes: Includes newer tooling (`trajan`, `mypy`, `types-*`) so contributors can
  run docs/tests locally without additional installs.
