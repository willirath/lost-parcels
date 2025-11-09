# Lost Parcels Agent Notes

These are the key tricks that made the legacy `v0.9` OceanParcels release usable again:

1. **Isolate per-version environments.** Define a Pixi feature (`parcels-v09`) with its own environment entry so Python 2.7 and friends stay separate from other versions. All tasks (`parcels-v09-python`, `parcels-v09-notebook`, `bootstrap-v09`) live under that feature, so Pixi always activates the matching env.
2. **Leverage the submodule directly.** The OceanParcels repo is vendored as `parcels-v09/`; the tasks set `PYTHONPATH="$PWD/parcels-v09"` before launching Python/Jupyter so the code is used in-place (no editable install).
3. **Bootstrap missing pip-only deps.** Conda-forge no longer ships some Python 2 wheels (`cgen`, `pymbolic`, `progressbar`). A dedicated `pixi run bootstrap-v09` task installs them via pip every time the env is recreated.
4. **Document the workflow.** README walks through `pixi install -e parcels-v09`, `pixi run bootstrap-v09`, then the script/notebook tasks. Future versions can mimic this pattern (new feature + bootstrap task + submodule directory).
5. **Keep notebooks headless-friendly.** `parcels-v09-notebook` disables auto-opening browsers, which keeps the command usable in remote/sandboxed contexts.

---

For `v1.1.1`, the same pattern applies with a second feature (`parcels-v111`) plus:

- Editable install is required because the package imports `parcels._version`. The bootstrap task now calls `scripts/bootstrap-parcels-v111.sh`, which installs the pip-only deps and then runs `pip install -e parcels-v111`.
- Extra conda deps (`cachetools`, `matplotlib 2.2.*`, `netcdftime`, `progressbar2`, etc.) come from the historic `environment_py2_osx.yml`.
- Tasks `parcels-v111-python` / `parcels-v111-notebook` mirror the v0.9 ones but point to the new submodule path.
- Notebooks live under `parcels-v111/parcels/examples`, so the Pixi task points Jupyter at that subdirectory instead of the top-level `examples`.

Add future releases by cloning another submodule, defining a feature/environment pair, capturing any pip-only needs in a bootstrap script, and documenting the workflow in the README.

