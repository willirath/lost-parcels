# 2025-11-09 Lost Parcels

## Quick-start

This repo contains Pixi-managed Python 2.7 environments plus OceanParcels
submodules (tracked at tags `v0.9` and `v1.1.1`). To run either checkout:

```bash
# install/update the parcels-v09 environment
pixi install -e parcels-v09
# install legacy PyPI-only deps (cgen, progressbar, pymbolic)
pixi run bootstrap-v09

# run Python with the local parcels-v09 package on the import path
pixi run parcels-v09-python -c 'import parcels; print("Loaded parcels from:", parcels.__file__)'

# launch the legacy notebook UI in the examples directory (no browser auto-open)
pixi run parcels-v09-notebook

# install/update the parcels-v111 environment
pixi install -e parcels-v111
# install pip-only deps (and build the editable install)
pixi run bootstrap-v111

# run Python with the local parcels-v111 package
pixi run parcels-v111-python parcels-v111/parcels/examples/example_brownian.py
```

The `parcels-v09-python` task simply wraps `python` while setting
`PYTHONPATH=./parcels-v09`, so you can swap the `-c` snippet for any script,
module, or example from the submodule (e.g.
`pixi run parcels-v09-python parcels-v09/examples/example_peninsula.py`).

`parcels-v09-notebook` starts the Jupyter Notebook server rooted at
`parcels-v09/examples`, so you can open `example_radial_rotation.ipynb` (or any
other legacy notebook) without additional path tweaks.

`parcels-v111-python` and `parcels-v111-notebook` behave identically but target
the submodule checked out at tag `v1.1.1`.
