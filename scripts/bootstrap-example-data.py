#!/usr/bin/env python3
"""Download and cache Parcels example datasets in one place."""

from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, Iterable, List
from urllib.request import urlopen


BASE_URL = "http://oceanparcels.org/examples-data"
DEFAULT_CACHE = Path(__file__).resolve().parents[1] / ".cache" / "parcels-example-data"


def globcurrent_files() -> List[str]:
    start = datetime(2002, 1, 1)
    files = [
        f"{(start + timedelta(days=i)).strftime('%Y%m%d')}000000-GLOBCURRENT-L4-CUReul_hs-ALT_SUM-v02.0-fv01.0.nc"
        for i in range(365)
    ]
    files.append("20030101000000-GLOBCURRENT-L4-CUReul_hs-ALT_SUM-v02.0-fv01.0.nc")
    return files


def nemo_northsea_files() -> List[str]:
    days = ["04", "09", "14", "19", "24", "29"]
    components = ["U", "V", "W"]
    files = [f"ORCA025-N06_200001{day}d05{comp}.nc" for comp in components for day in days]
    files.append("coordinates.nc")
    return files


DATASETS: Dict[str, List[str]] = {
    "MovingEddies_data": [
        "moving_eddiesP.nc",
        "moving_eddiesU.nc",
        "moving_eddiesV.nc",
    ],
    "OFAM_example_data": ["OFAM_simple_U.nc", "OFAM_simple_V.nc"],
    "Peninsula_data": [
        "peninsulaU.nc",
        "peninsulaV.nc",
        "peninsulaP.nc",
        "peninsulaT.nc",
    ],
    "GlobCurrent_example_data": globcurrent_files(),
    "DecayingMovingEddy_data": [
        "decaying_moving_eddyU.nc",
        "decaying_moving_eddyV.nc",
    ],
    "NemoCurvilinear_data": [
        "U_purely_zonal-ORCA025_grid_U.nc4",
        "V_purely_zonal-ORCA025_grid_V.nc4",
        "mesh_mask.nc4",
    ],
    "MITgcm_example_data": ["mitgcm_UV_surface_zonally_reentrant.nc"],
    "NemoNorthSeaORCA025-N006_data": nemo_northsea_files(),
    "POPSouthernOcean_data": [
        "t.x1_SAMOC_flux.169000.nc",
        "t.x1_SAMOC_flux.169001.nc",
        "t.x1_SAMOC_flux.169002.nc",
        "t.x1_SAMOC_flux.169003.nc",
        "t.x1_SAMOC_flux.169004.nc",
        "t.x1_SAMOC_flux.169005.nc",
    ],
    "SWASH_data": [
        "field_0065532.nc",
        "field_0065537.nc",
        "field_0065542.nc",
        "field_0065548.nc",
        "field_0065552.nc",
        "field_0065557.nc",
    ],
    "WOA_data": [f"woa18_decav_t{month:02d}_04.nc" for month in range(1, 13)],
    "CROCOidealized_data": ["CROCO_idealized.nc"],
}


def iter_datasets(selected: Iterable[str] | None) -> Iterable[str]:
    if selected:
        for name in selected:
            if name not in DATASETS:
                raise SystemExit(
                    f"Dataset '{name}' is unknown. Available datasets: {', '.join(sorted(DATASETS))}"
                )
            yield name
    else:
        for name in sorted(DATASETS):
            yield name


def download_dataset(dataset: str, cache_dir: Path) -> None:
    files = DATASETS[dataset]
    target_root = cache_dir / dataset
    target_root.mkdir(parents=True, exist_ok=True)

    total = len(files)
    downloaded = 0
    for filename in files:
        target_path = target_root / filename
        if target_path.exists():
            continue
        target_path.parent.mkdir(parents=True, exist_ok=True)
        url = f"{BASE_URL}/{dataset}/{filename}"
        print(f"[{dataset}] downloading {filename}")
        with urlopen(url) as response, open(target_path, "wb") as dest:
            dest.write(response.read())
        downloaded += 1
    skipped = total - downloaded
    print(f"[{dataset}] ready (fetched {downloaded}, cached {skipped})")


def main(argv: List[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description="Download Parcels example datasets.")
    parser.add_argument(
        "--cache",
        type=Path,
        default=Path(os.environ.get("PARCELS_EXAMPLE_DATA", DEFAULT_CACHE)),
        help="Where to store the shared dataset cache (default: %(default)s).",
    )
    parser.add_argument(
        "datasets",
        nargs="*",
        help="Optional subset of datasets to download (default: all known datasets).",
    )
    args = parser.parse_args(argv)

    args.cache.mkdir(parents=True, exist_ok=True)
    for dataset in iter_datasets(args.datasets):
        download_dataset(dataset, args.cache)


if __name__ == "__main__":
    main(sys.argv[1:])
