from __future__ import annotations

from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .schemas import AccidentRecord, CauseSummary, CountySummary, DashboardResponse, FilterOptionsResponse, HourlyCount, ModelMetric, NamedCount, OverviewResponse, RoadSummary
from .services.analytics import get_age_groups, get_causes, get_counties, get_dashboard_payload, get_filter_options, get_gender, get_hourly_counts, get_models, get_overview, get_records, get_roads, get_time_of_day, get_victims


app = FastAPI(
    title=settings.project_name,
    version=settings.version,
    description="API for the Kenya Road Safety dashboard and analytics views.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.frontend_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root() -> dict:
    return {"message": "Kenya Road Safety API is running.", "docs": "/docs", "version": settings.version}


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.get("/api/dashboard", response_model=DashboardResponse)
def dashboard() -> dict:
    return get_dashboard_payload()


@app.get("/api/overview", response_model=OverviewResponse)
def overview() -> dict:
    return get_overview()


@app.get("/api/time-of-day", response_model=list[NamedCount])
def time_of_day() -> list[dict]:
    return get_time_of_day()


@app.get("/api/hourly", response_model=list[HourlyCount])
def hourly() -> list[dict]:
    return get_hourly_counts()


@app.get("/api/victims", response_model=list[NamedCount])
def victims() -> list[dict]:
    return get_victims()


@app.get("/api/gender", response_model=list[NamedCount])
def gender() -> list[dict]:
    return get_gender()


@app.get("/api/age-groups", response_model=list[NamedCount])
def age_groups() -> list[dict]:
    return get_age_groups()


@app.get("/api/causes", response_model=list[CauseSummary])
def causes(limit: int | None = Query(default=None, ge=1, le=50)) -> list[dict]:
    return get_causes(limit=limit)


@app.get("/api/counties", response_model=list[CountySummary])
def counties(limit: int | None = Query(default=None, ge=1, le=100)) -> list[dict]:
    return get_counties(limit=limit)


@app.get("/api/roads", response_model=list[RoadSummary])
def roads(limit: int = Query(default=10, ge=1, le=100)) -> list[dict]:
    return get_roads(limit=limit)


@app.get("/api/models", response_model=list[ModelMetric])
def models() -> list[dict]:
    return get_models()


@app.get("/api/filters", response_model=FilterOptionsResponse)
def filters() -> dict:
    return get_filter_options()


@app.get("/api/records", response_model=list[AccidentRecord])
def records(
    county: str | None = Query(default=None),
    cause_code: str | None = Query(default=None),
    time_of_day: str | None = Query(default=None),
) -> list[dict]:
    return get_records(county=county, cause_code=cause_code, time_of_day=time_of_day)
