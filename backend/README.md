# Kenya Road Safety Backend

This backend uses FastAPI and reads directly from the CSV files already in the project.

## Endpoints

- GET /health
- GET /api/dashboard
- GET /api/overview
- GET /api/time-of-day
- GET /api/hourly
- GET /api/victims
- GET /api/gender
- GET /api/age-groups
- GET /api/causes
- GET /api/counties
- GET /api/roads
- GET /api/models

## Run

```powershell
cd backend
.\run.ps1
```

Then open:
- http://127.0.0.1:8000/docs
- http://127.0.0.1:8000/api/dashboard
