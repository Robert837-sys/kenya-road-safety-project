from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv


ROOT_DIR = Path(__file__).resolve().parents[2]
load_dotenv(ROOT_DIR / ".env", override=False)


class Settings:
    def __init__(self) -> None:
        self.project_name = "Kenya Road Safety API"
        self.version = "1.0.0"
        self.host = os.getenv("BACKEND_HOST", "127.0.0.1")
        self.port = int(os.getenv("BACKEND_PORT", "8000"))
        origins = os.getenv(
            "FRONTEND_ORIGINS",
            "http://127.0.0.1:5500,http://localhost:5500,http://127.0.0.1:5501,http://localhost:5501,http://127.0.0.1:3000,http://localhost:3000,null",
        )
        self.frontend_origins = [origin.strip() for origin in origins.split(",") if origin.strip()]
        self.project_root = ROOT_DIR
        self.cleaned_csv = self.project_root / "data" / "cleaned" / "accidents_clean.csv"
        self.county_risk_csv = self.project_root / "data" / "exports" / "county_risk_powerbi.csv"
        self.model_metrics_csv = self.project_root / "data" / "exports" / "model_comparison_full.csv"


settings = Settings()
