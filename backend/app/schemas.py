from __future__ import annotations

from typing import Dict, List, Optional

from pydantic import BaseModel


class OverviewResponse(BaseModel):
    total_accidents: int
    fatal_accidents: int
    non_fatal_accidents: int
    fatality_rate: float
    counties_covered: int
    roads_covered: int
    date_range: Dict[str, Optional[str]]


class NamedCount(BaseModel):
    name: str
    count: int


class HourlyCount(BaseModel):
    hour: int
    count: int


class CauseSummary(BaseModel):
    code: str
    name: str
    count: int
    fatal_accidents: int
    fatality_rate: float


class CountySummary(BaseModel):
    county: str
    accidents: int
    fatalities: int
    fatality_rate: float
    average_victims: float
    risk_level: str
    night_rate: Optional[float] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class RoadSummary(BaseModel):
    road: str
    count: int


class ModelMetric(BaseModel):
    name: str
    task: str
    accuracy: Optional[float] = None
    precision: Optional[float] = None
    recall: Optional[float] = None
    f1_score: Optional[float] = None
    auc_roc: Optional[float] = None
    mae: Optional[float] = None
    rmse: Optional[float] = None
    r2: Optional[float] = None
    best: bool = False


class DashboardResponse(BaseModel):
    overview: OverviewResponse
    time_of_day: List[NamedCount]
    hourly: List[HourlyCount]
    victims: List[NamedCount]
    gender: List[NamedCount]
    age_groups: List[NamedCount]
    causes: List[CauseSummary]
    counties: List[CountySummary]
    roads: List[RoadSummary]
    models: List[ModelMetric]


class AccidentRecord(BaseModel):
    county: str
    road: str
    time_of_day: str
    hour: Optional[int] = None
    victim_category: str
    gender_clean: str
    age_group: str
    cause_code: str
    num_victims: int
    is_fatal: int


class FilterOptionsResponse(BaseModel):
    counties: List[str]
    causes: List[Dict[str, str]]
    time_of_day: List[str]
