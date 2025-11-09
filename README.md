# 2025-11-09 Lost Parcels

## Quick-start

This repo contains Pixi-managed Python 2.7/3.10 environments plus OceanParcels
submodules (tracked at tags `v0.9`, `v1.1.1`, and `v2.4.2`). To run any checkout:

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

# install/update the parcels-v242 environment (Python 3.10 + OceanParcels v2.4.2)
pixi install -e parcels-v242
# install pip-only deps (setuptools_scm_git_archive) and build the editable install
pixi run bootstrap-v242

# run Python with the local parcels-v242 package
pixi run parcels-v242-python -c 'import parcels; print("Loaded parcels", parcels.__version__)'
pixi run parcels-v242-python parcels-v242/docs/examples/example_brownian.py

# launch the headless-friendly notebook UI rooted at docs/examples
pixi run parcels-v242-notebook
```

The `parcels-v09-python` task simply wraps `python` while setting
`PYTHONPATH=./parcels-v09`, so you can swap the `-c` snippet for any script,
module, or example from the submodule (e.g.
`pixi run parcels-v09-python parcels-v09/examples/example_peninsula.py`).

`parcels-v09-notebook` starts the Jupyter Notebook server rooted at
`parcels-v09/examples`, so you can open `example_radial_rotation.ipynb` (or any
other legacy notebook) without additional path tweaks.

`parcels-v111-python` and `parcels-v111-notebook` behave identically but target
the submodule checked out at tag `v1.1.1`. The notebooks for that release live under
`parcels-v111/parcels/examples`, so the task already points Jupyter there.

`parcels-v242-python` and `parcels-v242-notebook` expose the modern v2.4.2 codebase on
Python 3.10. The commands use `PYTHONPATH=./parcels-v242` so changes to the vendored
tree are imported immediately, and they export `MPLCONFIGDIR=$PWD/.cache/matplotlib`
so Matplotlib never tries to write into a read-only `$HOME`. The v2 examples and
notebooks live in `parcels-v242/docs/examples`, which is where the notebook server
launches from and what the README snippets use as the working directory.
MPI tooling (`mpi4py`, `mpich`) is intentionally omitted from the default feature
because it cannot run inside the sandboxed environment; if you need it locally you
can extend the `parcels-v242` feature with Conda MPI packages before calling
`pixi install`.
