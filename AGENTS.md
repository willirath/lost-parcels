# Lost Parcels Agent Notes

## Per-version playbook

Use this checklist whenever a new OceanParcels release is added:

**Important**: Always work on a separate branch when making changes. The main branch
is protected and requires pull requests for all updates.

1. **Clone the submodule** at `parcels-vXYZ/` (name = `parcels-v{slug}`). Checkout
   the upstream tag you care about and add it to `.gitmodules`.
2. **Define a Pixi feature/environment** named `parcels-vXYZ`. Keep the version’s
   platform requirements isolated; mirror the old upstream `environment_*.yml`
   when possible.
3. **Add three Pixi tasks** under that feature:
   - `bootstrap-vXYZ` → calls `scripts/bootstrap-parcels-vXYZ.sh`.
   - `parcels-vXYZ-python` → runs `python` (optionally setting `MPLCONFIGDIR` for
     matplotlib cache management).
   - `parcels-vXYZ-notebook` → points Jupyter at the correct examples directory
     and disables browser launch (optionally setting `MPLCONFIGDIR`).
4. **Write the bootstrap script** to install any pip-only packages and finish
   with `pip install -e parcels-vXYZ`. The editable install ensures edits to the
   submodule are immediately importable. Shell scripts keep the Pixi config consistent.
5. **Document the release** in `README.md` and update this file to note any
   quirks (extra pip deps, notebook paths, MPI requirements, etc.).
6. **Headless hygiene**: ensure every runtime task avoids launching browsers,
   writes caches inside the repo (e.g. `.cache/matplotlib`), and does not assume
   MPI availability unless explicitly added.

Following this pattern means future releases only need new submodule + feature
entries and a short README/agent blurb.

## Submodule workflow

- All `parcels-v*` directories are git submodules pinned to upstream tags.
- Recommend `git clone --recurse-submodules <repo-url>` in the README so
  contributors land with every release checked out.
- Remind folks that `git submodule update --init --recursive` reruns safely
  after pulling, while `git submodule update --remote` refreshes to the newest
  upstream tags when a new release directory is added.

## Tutorial data workflow

- `pixi run bootstrap-example-data` must download the union of datasets into
  `.cache/parcels-example-data`. Keep `scripts/bootstrap-example-data.py`
  aligned with the upstream Parcels manifest when releases add/remove folders.
- Each `scripts/bootstrap-parcels-vXYZ.sh` script calls
  `scripts/link-example-data.sh <slug>` to wire the shared cache into the legacy
  `parcels/examples/*` paths that the Py2 releases expect. Update the slug →
  dataset mapping inside that script whenever requirements change.
- All v242/v314 Pixi tasks set `PARCELS_EXAMPLE_DATA=$PWD/.cache/parcels-example-data`
  so their `download_example_dataset()` helper reuses the cache automatically.
- The README’s tutorial-data section should keep pointing users at
  `pixi run bootstrap-example-data`, explain that bootstraps relink the cache,
  and enumerate the currently supported dataset folders.

## Current releases

### `v09` (tag `v0.9`, Python 2.7)
- Environment: legacy Py2 stack with `pixi install -e parcels-v09`.
- Bootstrap: `scripts/bootstrap-parcels-v09.sh` installs the PyPI-only wheels
  (`cgen<2020`, `progressbar<3`, `pymbolic<2020`). and runs `pip install -e parcels-v09`.
- Runtime tasks: `parcels-v09-python` / `parcels-v09-notebook` use the editable install
  and point notebooks at `parcels-v09/examples`.
- Notes: Notebooks disable auto-browser launch with
  `--NotebookApp.open_browser=False`.

### `v105` (tag `v1.0.5`, Python 2.7)
- Environment: Py2 stack mirroring the upstream `environment_py2_osx.yml` with
  additional dependencies like `cachetools`, `matplotlib 2.2.*`, `progressbar2`.
- Bootstrap: `scripts/bootstrap-parcels-v105.sh` installs the pip-only wheels
  (`cgen<2020`, `pymbolic<2020`, `progressbar2<4`) and runs `pip install -e parcels-v105`
  to generate `parcels._version` (required for imports).
- Runtime tasks: point Jupyter at `parcels-v105/parcels/examples` and set
  `PYTHONPATH=./parcels-v105`, with headless notebook settings.
- Notes: First stable v1.0.x release; sits between v0.9 and v1.1.1 chronologically.
  Requires editable install like v1.1.1 due to `_version` dependency.

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
