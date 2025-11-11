# Lost Parcels

Providing environments for exploring old [OceanParcels / Parcels](https://parcels-code.org) releases.

## Get every Parcels release locally

Each `parcels-v*` directory in this repo is a git submodule pinned to the
matching upstream release tag. To grab everything in one shot, clone with
recursive submodules enabled:

```bash
git clone --recurse-submodules https://github.com/willirath/lost-parcels.git
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

This repo keeps a single cache of example NetCDF bundles under
`.cache/parcels-example-data` and wires every release up to that location. Run
the global bootstrap task once to fill the cache:

```bash
pixi run bootstrap-example-data
```

The downloader skips files that already exist, so you can re-run it after a pull
to grab newly added datasets without re-touching the old ones.

Every `pixi run bootstrap-vXYZ` command automatically re-links the cache inside
the legacy `parcels-vXYZ/parcels/examples/*` paths (where the Py2 releases
expect the data). The modern Py3 tasks (`parcels-v242-*`, `parcels-v314-*`)
export `PARCELS_EXAMPLE_DATA=$PWD/.cache/parcels-example-data`, so the shared
cache is also visible to their `parcels.download_example_dataset(...)` helper.

Current dataset folders: `MovingEddies_data`, `OFAM_example_data`,
`Peninsula_data`, `GlobCurrent_example_data`, `DecayingMovingEddy_data`,
`NemoCurvilinear_data`, `MITgcm_example_data`, `NemoNorthSeaORCA025-N006_data`,
`POPSouthernOcean_data`, `SWASH_data`, `WOA_data`, and `CROCOidealized_data`
(`CROCO` is only used by `v314`). Update this list and the helper scripts
whenever new upstream tutorials reference additional data.

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

| Slug | Upstream tag | Python | Notebook root | Bootstrap script |
| ---- | ------------ | ------ | ------------- | ---------------- |
| `v09`  | `v0.9`   | 2.7  | `parcels-v09/examples` | `scripts/bootstrap-parcels-v09.sh` |
| `v105` | `v1.0.5` | 2.7  | `parcels-v105/parcels/examples` | `scripts/bootstrap-parcels-v105.sh` |
| `v111` | `v1.1.1` | 2.7  | `parcels-v111/parcels/examples` | `scripts/bootstrap-parcels-v111.sh` |
| `v200` | `v2.0.0` | 3.6  | `parcels-v200/parcels/examples` | `scripts/bootstrap-parcels-v200.sh` |
| `v215` | `v2.1.5` | 3.7  | `parcels-v215/parcels/examples` | `scripts/bootstrap-parcels-v215.sh` |
| `v222` | `v2.2.2` | 3.8  | `parcels-v222/parcels/examples` | `scripts/bootstrap-parcels-v222.sh` |
| `v232` | `v2.3.2` | 3.9  | `parcels-v232/parcels/examples` | `scripts/bootstrap-parcels-v232.sh` |
| `v242` | `v2.4.2` | 3.10 | `parcels-v242/docs/examples` | `scripts/bootstrap-parcels-v242.sh` |
| `v306` | `v3.0.6` | 3.10 | `parcels-v306/docs/examples` | `scripts/bootstrap-parcels-v306.sh` |
| `v314` | `v3.1.4` | 3.11 | `parcels-v314/docs/examples` | `scripts/bootstrap-parcels-v314.sh` |

For version-specific notes, quirks, and maintenance guidance, see [AGENTS.md](AGENTS.md).

