# Lost Parcels Agent Notes

These are the key tricks that made the legacy `v0.9` OceanParcels release usable again:

1. **Isolate per-version environments.** Define a Pixi feature (`parcels-v09`) with its own environment entry so Python 2.7 and friends stay separate from other versions. All tasks (`parcels-v09-python`, `parcels-v09-notebook`, `bootstrap-v09`) live under that feature, so Pixi always activates the matching env.
2. **Leverage the submodule directly.** The OceanParcels repo is vendored as `parcels-v09/`; the tasks set `PYTHONPATH="$PWD/parcels-v09"` before launching Python/Jupyter so the code is used in-place (no editable install).
3. **Bootstrap missing pip-only deps.** Conda-forge no longer ships some Python 2 wheels (`cgen`, `pymbolic`, `progressbar`). A dedicated `pixi run bootstrap-v09` task installs them via pip every time the env is recreated.
4. **Document the workflow.** README walks through `pixi install -e parcels-v09`, `pixi run bootstrap-v09`, then the script/notebook tasks. Future versions can mimic this pattern (new feature + bootstrap task + submodule directory).
5. **Keep notebooks headless-friendly.** `parcels-v09-notebook` disables auto-opening browsers, which keeps the command usable in remote/sandboxed contexts.
