from __future__ import annotations

from typing import Dict, List, Optional

import pandas as pd

from ..data_loader import get_accidents_df, get_county_risk_df, get_model_metrics_df


CAUSE_LABELS: Dict[str, str] = {
    "98": "Other / Unknown causes",
    "26": "Careless driving",
    "10": "Speeding",
    "7": "Dangerous overtaking",
    "29": "Drunk driving",
    "8": "Failure to give way",
    "60": "Poor road condition",
    "63": "Pedestrian carelessness",
    "68": "Defective vehicle",
    "79": "Bad weather",
}

TIME_ORDER = ["Morning", "Afternoon", "Evening", "Night", "Unknown"]


def _top_counts(series: pd.Series, limit: Optional[int] = None) -> List[dict]:
    counts = (
        series.fillna("Unknown")
        .astype(str)
        .str.strip()
        .replace("", "Unknown")
        .value_counts()
    )
    if limit is not None:
        counts = counts.head(limit)
    return [{"name": name, "count": int(count)} for name, count in counts.items()]


def _to_optional_float(value: object) -> Optional[float]:
    if pd.isna(value):
        return None
    return round(float(value), 2)


def get_overview() -> dict:
    df = get_accidents_df()
    total = int(len(df))
    fatal = int(df["is_fatal"].sum())
    non_fatal = total - fatal
    date_min = df["date"].min()
    date_max = df["date"].max()
    return {
        "total_accidents": total,
        "fatal_accidents": fatal,
        "non_fatal_accidents": non_fatal,
        "fatality_rate": round((fatal / total) * 100, 2) if total else 0.0,
        "counties_covered": int(df["county"].nunique()),
        "roads_covered": int(df["road"].nunique()),
        "date_range": {
            "start": None if pd.isna(date_min) else date_min.date().isoformat(),
            "end": None if pd.isna(date_max) else date_max.date().isoformat(),
        },
    }


def get_time_of_day() -> List[dict]:
    df = get_accidents_df()
    counts = df["time_of_day"].value_counts().to_dict()
    return [{"name": name, "count": int(counts.get(name, 0))} for name in TIME_ORDER if name in counts]


def get_hourly_counts() -> List[dict]:
    df = get_accidents_df()
    hourly_df = df.dropna(subset=["hour"]).copy()
    hourly_df["hour"] = hourly_df["hour"].astype(int)
    hourly = hourly_df.groupby("hour").size().reindex(range(24), fill_value=0)
    return [{"hour": int(hour), "count": int(count)} for hour, count in hourly.items()]


def get_victims() -> List[dict]:
    return _top_counts(get_accidents_df()["victim_category"])


def get_gender() -> List[dict]:
    return _top_counts(get_accidents_df()["gender_clean"])


def get_age_groups() -> List[dict]:
    return _top_counts(get_accidents_df()["age_group"])


def get_causes(limit: Optional[int] = None) -> List[dict]:
    df = get_accidents_df()
    grouped = (
        df.groupby("cause_code", dropna=False)
        .agg(count=("cause_code", "size"), fatal_accidents=("is_fatal", "sum"))
        .reset_index()
        .sort_values(["count", "cause_code"], ascending=[False, True])
    )
    if limit is not None:
        grouped = grouped.head(limit)

    items = []
    for row in grouped.to_dict(orient="records"):
        count = int(row["count"])
        fatal_accidents = int(row["fatal_accidents"])
        code = str(row["cause_code"]).strip() or "Unknown"
        items.append(
            {
                "code": code,
                "name": CAUSE_LABELS.get(code, "Unmapped cause code"),
                "count": count,
                "fatal_accidents": fatal_accidents,
                "fatality_rate": round((fatal_accidents / count) * 100, 2) if count else 0.0,
            }
        )
    return items


def get_counties(limit: Optional[int] = None) -> List[dict]:
    df = get_accidents_df()
    county_metrics = (
        df.groupby("county", dropna=False)
        .agg(accidents=("county", "size"), fatalities=("is_fatal", "sum"), average_victims=("num_victims", "mean"))
        .reset_index()
    )
    county_metrics["fatality_rate"] = (county_metrics["fatalities"] / county_metrics["accidents"] * 100).round(2)
    county_metrics = county_metrics.rename(columns={"fatality_rate": "calculated_fatality_rate"})
    merged = county_metrics.merge(get_county_risk_df(), on="county", how="left")
    merged = merged.sort_values(["accidents", "county"], ascending=[False, True])
    if limit is not None:
        merged = merged.head(limit)

    items = []
    for row in merged.to_dict(orient="records"):
        items.append(
            {
                "county": row["county"],
                "accidents": int(row["accidents"]),
                "fatalities": int(row["fatalities"]),
                "fatality_rate": round(float(row["calculated_fatality_rate"]), 2),
                "average_victims": round(float(row["average_victims"]), 2),
                "risk_level": "Unknown" if pd.isna(row.get("risk_level")) else str(row.get("risk_level")),
                "night_rate": _to_optional_float(row.get("night_rate")),
                "latitude": _to_optional_float(row.get("latitude")),
                "longitude": _to_optional_float(row.get("longitude")),
            }
        )
    return items


def get_roads(limit: int = 10) -> List[dict]:
    return [
        {"road": item["name"], "count": item["count"]}
        for item in _top_counts(get_accidents_df()["road"], limit=limit)
    ]


def get_models() -> List[dict]:
    df = get_model_metrics_df().copy()
    numeric_columns = ["Accuracy", "Precision", "Recall", "F1 Score", "AUC-ROC", "MAE", "RMSE", "R2"]
    for column in numeric_columns:
        df[column] = pd.to_numeric(df[column], errors="coerce")

    best_auc = df["AUC-ROC"].max(skipna=True)
    items = []
    for row in df.to_dict(orient="records"):
        auc = row["AUC-ROC"]
        items.append(
            {
                "name": row["Model"],
                "task": row["Task"],
                "accuracy": _to_optional_float(row["Accuracy"]),
                "precision": _to_optional_float(row["Precision"]),
                "recall": _to_optional_float(row["Recall"]),
                "f1_score": _to_optional_float(row["F1 Score"]),
                "auc_roc": _to_optional_float(auc),
                "mae": _to_optional_float(row["MAE"]),
                "rmse": _to_optional_float(row["RMSE"]),
                "r2": _to_optional_float(row["R2"]),
                "best": False if pd.isna(auc) or pd.isna(best_auc) else float(auc) == float(best_auc),
            }
        )

    has_kmeans = any(item["name"].strip().lower() == "k-means clustering" for item in items)
    if not has_kmeans:
        items.append(
            {
                "name": "K-Means Clustering",
                "task": "Clustering",
                "accuracy": None,
                "precision": None,
                "recall": None,
                "f1_score": None,
                "auc_roc": None,
                "mae": None,
                "rmse": None,
                "r2": None,
                "best": False,
            }
        )
    return items


def get_dashboard_payload() -> dict:
    return {
        "overview": get_overview(),
        "time_of_day": get_time_of_day(),
        "hourly": get_hourly_counts(),
        "victims": get_victims(),
        "gender": get_gender(),
        "age_groups": get_age_groups(),
        "causes": get_causes(),
        "counties": get_counties(),
        "roads": get_roads(),
        "models": get_models(),
    }


def get_filter_options() -> dict:
    df = get_accidents_df()
    return {
        "counties": sorted([value for value in df["county"].dropna().astype(str).str.strip().unique().tolist() if value]),
        "causes": [
            {
                "value": code,
                "label": f"{code} - {CAUSE_LABELS.get(code, 'Unmapped cause code')}",
            }
            for code in sorted([value for value in df["cause_code"].dropna().astype(str).str.strip().unique().tolist() if value])
        ],
        "time_of_day": [value for value in TIME_ORDER if value in df["time_of_day"].dropna().astype(str).unique().tolist()],
    }


def get_records(
    county: Optional[str] = None,
    cause_code: Optional[str] = None,
    time_of_day: Optional[str] = None,
) -> List[dict]:
    df = get_accidents_df().copy()

    if county:
        df = df[df["county"] == county]
    if cause_code:
        df = df[df["cause_code"] == cause_code]
    if time_of_day:
        df = df[df["time_of_day"] == time_of_day]

    records = []
    for row in df.to_dict(orient="records"):
        hour = row.get("hour")
        num_victims = row.get("num_victims")
        records.append(
            {
                "county": str(row.get("county") or "Unknown"),
                "road": str(row.get("road") or "Unknown"),
                "time_of_day": str(row.get("time_of_day") or "Unknown"),
                "hour": None if pd.isna(hour) else int(hour),
                "victim_category": str(row.get("victim_category") or "Unknown"),
                "gender_clean": str(row.get("gender_clean") or "Unknown"),
                "age_group": str(row.get("age_group") or "Unknown"),
                "cause_code": str(row.get("cause_code") or "Unknown"),
                "num_victims": 0 if pd.isna(num_victims) else int(num_victims),
                "is_fatal": int(row.get("is_fatal") or 0),
            }
        )
    return records
