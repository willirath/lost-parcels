# 2025-11-09 Old Parcels

## Quick-start

This repo contains a Pixi-managed Python 2.7 environment plus an OceanParcels
submodule (currently checked out at tag `v0.9`). To run anything against that
checkout:

```bash
# install/update the environment
pixi install

# run Python with the local parcels package on the import path
pixi run parcels-python -c "import parcels; print('Loaded parcels from:', parcels.__file__)"
```

The `parcels-python` task simply wraps `python` while setting
`PYTHONPATH=./parcels`, so you can swap the `-c` snippet for any script, module,
or example from the submodule (e.g. `pixi run parcels-python parcels/examples/example_peninsula.py`).
