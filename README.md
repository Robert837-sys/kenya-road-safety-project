# Kenya Road Accident Analytics & Risk Prediction System

> **A complete end-to-end data science pipeline analyzing NTSA Kenya road accident data to uncover patterns, predict fatality risk, and provide actionable insights for road safety authorities.**

---

## Table of Contents

- [Project Overview](#project-overview)
- [Problem Statement](#problem-statement)
- [Research Questions](#research-questions)
- [Project Structure](#project-structure)
- [Dataset Description](#dataset-description)
- [Installation & Setup](#installation--setup)
- [How to Run the Project](#how-to-run-the-project)
- [Notebooks Overview](#notebooks-overview)
- [SQL Files Overview](#sql-files-overview)
- [Machine Learning Models](#machine-learning-models)
- [Key Findings](#key-findings)
- [Power BI Dashboard](#power-bi-dashboard)
- [Technologies Used](#technologies-used)
- [Project Results](#project-results)
- [Recommendations](#recommendations)
- [Limitations](#limitations)
- [References](#references)

---

## Project Overview

Kenya's roads are among the most dangerous in sub-Saharan Africa. The National
Transport and Safety Authority (NTSA) reports that road accidents claim over
**3,000 lives every year** and injure tens of thousands more. The economic burden
exceeds **KSh 300 billion annually**.

This project builds a complete data-driven road accident analytics and risk
prediction system using real NTSA accident records. It covers the full data
science lifecycle — from raw data ingestion through machine learning to an
interactive Power BI dashboard — specifically designed to support evidence-based
road safety decision making by NTSA and Kenya's county governments.

---

## Problem Statement

> _"Kenya experiences thousands of road accidents annually, yet traffic management
> authorities lack a centralized data-driven tool to identify high-risk routes,
> peak accident times, and key contributing factors. This project analyzes Kenyan
> road accident data to uncover patterns, predict accident-prone conditions, and
> provide NTSA and county governments with an actionable dashboard to guide road
> safety interventions."_

---

## Research Questions

| #    | Research Question                                   | Answered By       |
| ---- | --------------------------------------------------- | ----------------- |
| RQ1  | Which counties and roads have the most accidents?   | EDA Charts 1 & 5  |
| RQ2  | What time of day are accidents most frequent?       | EDA Chart 4       |
| RQ3  | What are the leading causes of road accidents?      | EDA Chart 2       |
| RQ4  | Which victim types are most at risk?                | EDA Chart 3       |
| RQ5  | What are the gender and age group patterns?         | EDA Charts 6 & 7  |
| RQ6  | Which counties have the highest fatality rates?     | EDA Chart 8       |
| RQ7  | What factors correlate with fatal accidents?        | Random Forest     |
| RQ8  | Can we predict whether an accident will be fatal?   | LR, DT, RF        |
| RQ9  | How many victims will an accident likely involve?   | Linear Regression |
| RQ10 | Can counties be grouped into meaningful risk tiers? | K-Means           |

---

## Project Structure

```
kenya_road_safety_project/
│
├── data/
│   ├── raw/
│   │   └── accidents-database-.csv        # Original NTSA CSV
│   ├── cleaned/
│   │   └── accidents_clean.csv            # Cleaned data (1,119 records)
│   └── exports/
│       ├── county_risk_powerbi.csv        # K-Means output for Power BI
│       └── model_comparison_full.csv      # All model scores
│
├── notebooks/
│   ├── 01_load_data.ipynb                 # Load CSV into PostgreSQL
│   ├── 02_clean_data.ipynb                # Data cleaning & preprocessing
│   ├── 03_eda.ipynb                       # Exploratory Data Analysis
│   ├── 04_linear_reg.ipynb                # Linear Regression model
│   ├── 05_logistic_reg.ipynb              # Logistic Regression model
│   ├── 06_decision_tree.ipynb             # Decision Tree model
│   ├── 07_random_forest.ipynb             # Random Forest model
│   ├── 08_kmeans.ipynb                    # K-Means Clustering
│   └── 09_model_comparison.ipynb          # Final model comparison
│
├── sql/
│   ├── create_tables.sql                  # Database schema
│   ├── load_data.sql                      # Data verification scripts
│   └── queries.sql                        # 15 analytical queries
│
├── visuals/                               # All 34 saved chart images
│   ├── chart1_accidents_by_county.png
│   ├── chart2_accident_causes.png
│   ├── ... (34 total charts)
│   └── rf_roc_comparison.png
│
├── dashboard/
│   └── Kenya_Road_Safety.pbix             # Power BI dashboard (5 pages)
│
├── report/
│   └── Kenya_Road_Safety_Project_Report.pdf
│
├── .env                                   # Database credentials (not in Git)
├── .env.example                           # Credentials template for teammates
├── .gitignore                             # Git ignore rules
└── README.md                              # This file
```

---

## Dataset Description

| Property                | Value                                                |
| ----------------------- | ---------------------------------------------------- |
| **Source**              | NTSA Kenya — National Transport and Safety Authority |
| **File**                | accidents-database-.csv                              |
| **Records**             | 1,119 accident records                               |
| **Time Period**         | June 2016                                            |
| **Geographic Coverage** | 42 of Kenya's 47 counties                            |
| **Raw Columns**         | 15 columns                                           |
| **Cleaned Columns**     | 20 columns (after feature engineering)               |
| **Fatal Accidents**     | 159 records (14.2% fatality rate)                    |

### Column Reference

| Column            | Type    | Description                                               |
| ----------------- | ------- | --------------------------------------------------------- |
| `time`            | Numeric | Accident time in 24hr format                              |
| `hour`            | Integer | Extracted hour (0–23)                                     |
| `time_of_day`     | Text    | Morning / Afternoon / Evening / Night                     |
| `county`          | Text    | Kenya county name (standardized)                          |
| `road`            | Text    | Road name where accident occurred                         |
| `cause_code`      | Text    | NTSA numeric cause code                                   |
| `victim_type`     | Text    | Raw victim type from NTSA                                 |
| `victim_category` | Text    | Cleaned: Motorcyclist/Pedestrian/Passenger/Driver/Cyclist |
| `gender`          | Text    | Raw gender field                                          |
| `gender_clean`    | Text    | Cleaned: Male/Female/Multiple/Unknown                     |
| `age`             | Text    | Raw age field                                             |
| `age_group`       | Text    | Cleaned: Juvenile/Young Adult/Adult/Middle Aged/Elderly   |
| `num_victims`     | Integer | Number of victims per accident                            |
| `accident_date`   | Date    | Date of accident                                          |
| `is_fatal`        | Integer | **Target variable**: 1=Fatal, 0=Not Fatal                 |

### NTSA Cause Code Reference

| Code | Description             |
| ---- | ----------------------- |
| 98   | Other / Unknown causes  |
| 26   | Careless driving        |
| 10   | Speeding                |
| 7    | Dangerous overtaking    |
| 29   | Drunk driving           |
| 8    | Failure to give way     |
| 60   | Poor road condition     |
| 63   | Pedestrian carelessness |
| 68   | Defective vehicle       |
| 79   | Bad weather             |

---

## Installation & Setup

### Prerequisites

- Python 3.10 or higher
- PostgreSQL 15 or higher
- pgAdmin 4
- Power BI Desktop (free from microsoft.com)
- Git

### Step 1 — Clone the Repository

```bash
git clone https://github.com/yourusername/kenya-road-safety-project.git
cd kenya-road-safety-project
```

### Step 2 — Install Python Dependencies

```bash
pip install -r requirements.txt
```

Or install manually:

```bash
pip install pandas numpy matplotlib seaborn scikit-learn sqlalchemy psycopg2-binary python-dotenv openpyxl jupyter
```

### Step 3 — Set Up PostgreSQL Database

Open pgAdmin 4 and create the database:

```sql
CREATE DATABASE kenya_road_safety;
```

Then run the schema script:

```bash
# In pgAdmin Query Tool — open and run:
sql/create_tables.sql
```

### Step 4 — Configure Environment Variables

Copy the template and fill in your credentials:

```bash
cp .env.example .env
```

Edit `.env` with your actual PostgreSQL credentials:

```
DB_USER=postgres
DB_PASSWORD=your_password_here
DB_HOST=localhost
DB_PORT=5432
DB_NAME=kenya_road_safety
```

> **Security Note:** The `.env` file is listed in `.gitignore` and will never
> be uploaded to GitHub. Never commit real credentials to version control.

### Step 5 — Launch Jupyter Notebook

```bash
jupyter notebook
```

Navigate to the `notebooks/` folder to begin.

---

## How to Run the Project

Run the notebooks **in order** from 01 to 09:

```
01_load_data.ipynb       → Load raw CSV into PostgreSQL
02_clean_data.ipynb      → Clean and preprocess data
03_eda.ipynb             → Exploratory Data Analysis
04_linear_reg.ipynb      → Linear Regression model
05_logistic_reg.ipynb    → Logistic Regression model
06_decision_tree.ipynb   → Decision Tree model
07_random_forest.ipynb   → Random Forest model
08_kmeans.ipynb          → K-Means Clustering
09_model_comparison.ipynb→ Final model comparison
```

> **Important:** Always run notebooks from top to bottom, cell by cell.
> Do not skip notebooks — each one depends on the output of the previous one.

---

## Notebooks Overview

### 01 — Data Loading

Loads the raw `accidents-database-.csv` file into a PostgreSQL staging table
`accidents_raw` using SQLAlchemy. Verifies row counts and connection.

**Output:** `accidents_raw` table in PostgreSQL (1,119 records)

---

### 02 — Data Cleaning

Resolves all data quality issues in the raw dataset:

- Standardizes 58 county name variants to 42 valid counties
- Strips `HRS` suffix from time values (e.g. `1530HRS` → `1530`)
- Creates `time_of_day` category from hour of day
- Reduces 53 victim type variants to 7 clean categories
- Cleans 20 gender variants to Male/Female/Multiple/Unknown
- Maps age values `A` (Adult) and `J` (Juvenile) to age groups
- Engineers `is_fatal` target variable using keyword detection
- Exports `accidents_clean.csv` and loads into PostgreSQL

**Output:** `accidents_clean` table (1,119 records, 20 columns, 14.2% fatal rate)

---

### 03 — Exploratory Data Analysis

Produces 10 analytical charts answering RQ1–RQ7:

| Chart   | Title                                  |
| ------- | -------------------------------------- |
| chart1  | Top 10 Counties by Number of Accidents |
| chart2  | Top 10 Accident Cause Codes            |
| chart3  | Victim Type Distribution (Pie + Bar)   |
| chart4  | Accidents by Time of Day               |
| chart5  | Top 10 Most Dangerous Roads            |
| chart6  | Gender Breakdown of Accident Victims   |
| chart7  | Age Group Distribution                 |
| chart8  | Fatality Rate by County                |
| chart9  | Correlation Heatmap                    |
| chart10 | Fatal vs Non-Fatal by Victim Type      |

**Output:** 10 chart files saved to `visuals/`

---

### 04 — Linear Regression

Predicts the number of victims per accident.

- **Target:** `num_victims` (continuous)
- **Features:** Hour, County, Cause Code, Victim Type, Time of Day
- **Split:** 80% train / 20% test
- **Metrics:** MAE, RMSE, R-Squared

**Output:** 3 charts saved to `visuals/lr_*.png`

---

### 05 — Logistic Regression

Predicts whether an accident will be fatal (binary classification).

- **Target:** `is_fatal` (0 or 1)
- **Features:** Hour, County, Cause Code, Victim Type, Time of Day, Num Victims
- **Split:** 80/20 stratified
- **Class weight:** balanced (handles imbalance)
- **Metrics:** Accuracy, Precision, Recall, F1, AUC-ROC

**Output:** 3 charts saved to `visuals/log_*.png`

---

### 06 — Decision Tree

Predicts fatality with human-readable decision rules.

- **Target:** `is_fatal`
- **Depths tested:** 3, 5, unlimited (demonstrates overfitting)
- **Primary model:** depth=5
- **Key feature:** Visual tree diagram exportable for NTSA training

**Output:** 5 charts saved to `visuals/dt_*.png`

---

### 07 — Random Forest

Most accurate fatality prediction model — combines 100 decision trees.

- **Target:** `is_fatal`
- **Trees:** 100
- **Cross-validation:** 5-fold
- **Key output:** Feature importance ranking
- **Best AUC-ROC:** 0.749

**Output:** 4 charts + `model_comparison.csv` saved to `visuals/rf_*.png`

---

### 08 — K-Means Clustering

Groups Kenya's counties into High/Medium/Low risk tiers.

- **Method:** Unsupervised learning — no target variable
- **Optimal K:** 3 (determined by Elbow Method + Silhouette Score)
- **Features:** Total accidents, fatalities, fatality rate, avg victims, night rate
- **Output:** County coordinates added for Power BI map

**Output:** 4 charts + `county_risk_powerbi.csv` saved to `visuals/km_*.png`

---

### 09 — Model Comparison

Final side-by-side evaluation of all classification models.

- Retrains all 3 classifiers on same dataset
- Produces unified comparison table
- Generates combined ROC curve chart
- Runs 5-fold cross-validation on all models
- Exports `model_comparison_full.csv` for Power BI

**Output:** 5 comparison charts saved to `visuals/comparison_*.png`

---

## SQL Files Overview

### create_tables.sql

Creates the full database schema:

- `accidents_raw` — staging table for raw CSV data
- `accidents_clean` — main analytical table (20 columns, CHECK constraints, indexes)
- `county_risk_clusters` — K-Means output with risk levels and GPS coordinates
- 8 performance indexes

### load_data.sql

Verification queries to confirm all data loaded correctly after each notebook run.
Includes data quality checks for null values and invalid entries.

### queries.sql

15 analytical queries answering all project research questions:

| Query | Description                     | SQL Feature                |
| ----- | ------------------------------- | -------------------------- |
| Q1    | Project overview statistics     | Aggregate functions        |
| Q2    | Top 10 counties by accidents    | GROUP BY + ORDER BY        |
| Q3    | Accidents by time of day        | GROUP BY + percentage      |
| Q4    | Accidents by hour (24-hr)       | GROUP BY hour              |
| Q5    | Top 10 cause codes              | GROUP BY + TOP N           |
| Q6    | Accidents by victim category    | GROUP BY + fatality rate   |
| Q7    | Accidents by gender             | GROUP BY                   |
| Q8    | Accidents by age group          | GROUP BY                   |
| Q9    | Top 10 most dangerous roads     | GROUP BY + ORDER BY        |
| Q10   | Fatality rate by county         | GROUP BY + HAVING          |
| Q11   | Fatal by victim type and time   | WINDOW FUNCTION + RANK     |
| Q12   | County risk classification      | JOIN with cluster table    |
| Q13   | Accident trends by county/time  | CTE (WITH clause)          |
| Q14   | Cumulative accidents by hour    | WINDOW FUNCTION (SUM OVER) |
| Q15   | High risk accident combinations | CASE + HAVING + LIMIT      |

---

## Machine Learning Models

### Model Comparison Results

| Model               | Task           | Accuracy  | Precision | Recall    | F1 Score   | AUC-ROC   |
| ------------------- | -------------- | --------- | --------- | --------- | ---------- | --------- |
| Linear Regression   | Regression     | N/A       | N/A       | N/A       | MAE=0.352  | N/A       |
| Logistic Regression | Classification | 0.607     | 0.225     | **0.719** | 0.343      | 0.640     |
| Decision Tree (d=5) | Classification | 0.714     | 0.242     | 0.469     | **0.319**  | 0.664     |
| Random Forest (100) | Classification | **0.844** | **0.364** | 0.125     | 0.186      | **0.749** |
| K-Means (K=3)       | Clustering     | N/A       | N/A       | N/A       | Silhouette | N/A       |

### Best Model Selection

- **Best AUC-ROC:** Random Forest (0.749) — best overall discriminator
- **Best Recall:** Logistic Regression (0.719) — catches most fatal accidents
- **Best Interpretability:** Decision Tree — human-readable rules
- **Best for NTSA early warning:** Logistic Regression (highest recall)

### County Risk Tiers (K-Means)

| Risk Tier      | Counties                                                         | Count |
| -------------- | ---------------------------------------------------------------- | ----- |
| 🔴 High Risk   | Nairobi, Kiambu, Machakos, Kakamega, Kajiado, Nyeri, Uasin Gishu | 7     |
| 🟠 Medium Risk | Isiolo                                                           | 1     |
| 🟢 Low Risk    | All remaining counties                                           | 34    |

---

## Key Findings

### Accidents by County

- **Nairobi** recorded the most accidents: **183** (16.4% of total)
- Top 5 counties account for **41.8%** of all accidents
- High Risk counties: Nairobi, Kiambu, Machakos, Kakamega, Kajiado, Nyeri, Uasin Gishu

### Accidents by Time

- **Evening (17:00–21:00):** 341 accidents — most dangerous period
- **Night (21:00–06:00):** 292 accidents
- Evening + Night = **56.6%** of all accidents

### Victim Types

- **Pedestrians:** 455 (40.7%) — largest victim group
- **Motorcyclists:** 250 (22.3%)
- **Passengers:** 246 (22.0%) — highest fatality rate at 21.5%

### Top Accident Causes

1. Cause 98 — Other/Unknown: 224 (20.0%)
2. Cause 26 — Careless Driving: 164 (14.7%)
3. Cause 10 — Speeding: 97 (8.7%)
4. Cause 7 — Dangerous Overtaking: 68 (6.1%)
5. Cause 29 — Drunk Driving: 59 (5.3%)

### Most Dangerous Roads

- Nairobi-Mombasa Highway (multiple name variants) — most accidents
- Waiyaki Way — 17 accidents
- Thika Superhighway — 16 accidents

### Gender & Age

- **Male victims:** 84.2% of all accident records
- **Adults:** 48.7% of victims
- **Young Adults (20–34):** 19.7%
- **Juveniles:** 8.6%

---

## Power BI Dashboard

The dashboard (`dashboard/Kenya_Road_Safety.pbix`) contains 5 interactive pages:

| Page | Title               | Key Visuals                                                          |
| ---- | ------------------- | -------------------------------------------------------------------- |
| 1    | National Overview   | 4 KPI cards, Top 10 counties bar, Time of day donut, Victim type bar |
| 2    | Causes & Conditions | Top 10 causes, Victim pie, Gender bar, Age group bar                 |
| 3    | High Risk Analysis  | Dangerous roads, Fatality rate by county, Hour of day line           |
| 4    | County Risk Map     | Kenya map, Risk classification table, Risk tier bar                  |
| 5    | ML Insights         | Model comparison table, AUC chart, Feature importance                |

### Opening the Dashboard

1. Install Power BI Desktop from microsoft.com
2. Open `dashboard/Kenya_Road_Safety.pbix`
3. If prompted about data sources — update paths to your local CSV files
4. Use slicers on each page to filter by county, time of day or risk level

---

## Technologies Used

| Technology       | Version | Purpose                      |
| ---------------- | ------- | ---------------------------- |
| Python           | 3.11    | Primary programming language |
| PostgreSQL       | 15      | Relational database          |
| pgAdmin          | 4       | Database management GUI      |
| Pandas           | 2.x     | Data manipulation            |
| NumPy            | 1.x     | Numerical computation        |
| Matplotlib       | 3.x     | Data visualization           |
| Seaborn          | 0.12+   | Statistical charts           |
| Scikit-learn     | 1.3+    | Machine learning             |
| SQLAlchemy       | 2.x     | Python-PostgreSQL ORM        |
| python-dotenv    | 1.x     | Secure credential management |
| Jupyter Notebook | 7.x     | Development environment      |
| Power BI Desktop | 2026    | Interactive dashboard        |
| Git              | 2.51    | Version control              |
| GitHub           | —       | Remote repository            |

---

## Project Results

### Data Pipeline

```
Raw CSV (1,119 records, 15 cols)
    → PostgreSQL staging table
    → Data cleaning (20 cols, 9 steps)
    → Feature engineering (is_fatal, time_of_day, age_group etc.)
    → Cleaned CSV + PostgreSQL analytical table
```

### Charts Produced

```
EDA Charts          : 10
Linear Regression   :  3
Logistic Regression :  3
Decision Tree       :  5
Random Forest       :  4
K-Means Clustering  :  4
Model Comparison    :  5
────────────────────────
Total               : 34 charts
```

### Machine Learning Summary

```
Models trained      : 5
Best AUC-ROC        : 0.749 (Random Forest)
Best Recall         : 0.719 (Logistic Regression)
Counties clustered  : 42
High Risk counties  : 7
```

---

## Recommendations

Based on the analysis findings:

1. **Deploy traffic police** on Nairobi-Mombasa and Nakuru-Nairobi highways during **evening hours (17:00–23:00)**
2. **Prioritize speed enforcement** targeting cause codes 10 (Speeding) and 29 (Drunk Driving)
3. **Install pedestrian infrastructure** on Waiyaki Way, Thika Superhighway and Mombasa Road
4. **Mandate safety gear** for boda boda operators in 7 High Risk counties
5. **Invest in road lighting** on high-fatality rural roads in Uasin Gishu and Kajiado
6. **Deploy Logistic Regression** early warning model at accident response centres
7. **Expand NTSA data collection** to include weather, road surface and GPS coordinates
8. **School road safety education** in Nairobi and Kiambu — juveniles = 8.6% of victims

---

## Limitations

- **Single-month data:** Covers only June 2016 — seasonal trends cannot be analysed
- **Underreporting:** Rural accidents may not be officially recorded
- **Cause code ambiguity:** Code 98 (Unknown) = 20% of records
- **No weather data:** Weather conditions not in the NTSA dataset
- **Class imbalance:** 14.2% fatal rate — models may miss some fatalities
- **is_fatal engineering:** Based on keyword detection — some misclassification possible

---

## References

1. Delen, D., Sharda, R., & Bessonov, M. (2006). Identifying significant predictors of injury severity in traffic accidents. _Accident Analysis & Prevention_, 38(3), 434–444.
2. Wahab, L., & Jiang, H. (2019). Machine learning based algorithms for prediction of motorcycle crash severity. _PLOS ONE_, 14(4).
3. Mwangi, P., & Wambua, J. (2018). Analysis of road traffic accident patterns in Kenya. _East African Journal of Transport_, 4(1).
4. Odero, W., Khayesi, M., & Heda, P. M. (2003). Road traffic injuries in Kenya. _Injury Control and Safety Promotion_, 10(1–2).
5. WHO. (2023). _Global Status Report on Road Safety 2023_. World Health Organization.
6. NTSA. (2022). _Annual Road Crash Report 2022_. Government of Kenya.
7. KNBS. (2023). _Kenya Statistical Abstract 2023_. Government of Kenya.
8. Pedregosa, F. et al. (2011). Scikit-learn: Machine learning in Python. _JMLR_, 12, 2825–2830.

---

## License

This project was developed as an end-year Computer Science project.
The NTSA accident data is sourced from Kenya Open Data Portal and is
used for educational and research purposes.

---

_Kenya Road Accident Analytics & Risk Prediction System_
_Computer Science Department | End-Year Project | 2025/2026_
