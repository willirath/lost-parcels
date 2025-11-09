# 2025-11-09 Old Parcels

## Quick-start

This repo contains a Pixi-managed Python 2.7 environment plus an OceanParcels
submodule (currently checked out at tag `v0.9`). To run anything against that
checkout:

```bash
# install/update the parcels-v09 environment
pixi install -e parcels-v09
# install legacy PyPI-only deps (cgen, progressbar, pymbolic)
pixi run bootstrap-v09

# run Python with the local parcels package on the import path
pixi run parcels-v09-python -c "import parcels; print('Loaded parcels from:', parcels.__file__)"
```

The `parcels-v09-python` task simply wraps `python` while setting
`PYTHONPATH=./parcels-v09`, so you can swap the `-c` snippet for any script,
module, or example from the submodule (e.g.
`pixi run parcels-v09-python parcels-v09/examples/example_peninsula.py`).
