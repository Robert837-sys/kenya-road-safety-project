from __future__ import annotations

from functools import lru_cache
from pathlib import Path

import pandas as pd

from .config import settings


def _read_csv(path: Path) -> pd.DataFrame:
    if not path.exists():
        raise FileNotFoundError(f"Required data file not found: {path}")
    return pd.read_csv(path)


@lru_cache(maxsize=1)
def get_accidents_df() -> pd.DataFrame:
    df = _read_csv(settings.cleaned_csv).copy()
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    df["hour"] = pd.to_numeric(df["hour"], errors="coerce")
    df["num_victims"] = pd.to_numeric(df["num_victims"], errors="coerce").fillna(0)
    df["is_fatal"] = pd.to_numeric(df["is_fatal"], errors="coerce").fillna(0).astype(int)
    for column in ["county", "road", "time_of_day", "victim_category", "gender_clean", "age_group", "cause_code"]:
        df[column] = df[column].fillna("Unknown").astype(str).str.strip()
    return df


@lru_cache(maxsize=1)
def get_county_risk_df() -> pd.DataFrame:
    df = _read_csv(settings.county_risk_csv).copy()
    df["county"] = df["county"].fillna("Unknown").astype(str).str.strip()
    return df


@lru_cache(maxsize=1)
def get_model_metrics_df() -> pd.DataFrame:
    return _read_csv(settings.model_metrics_csv).copy()
