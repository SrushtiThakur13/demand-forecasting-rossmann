# Scalable Demand Forecasting System

Predicts weekly retail demand across 1,115 stores using XGBoost,
with automated ETL simulation and inventory impact analysis.

**Stack:** Python · XGBoost · SQL · Pandas · Scikit-learn · SQLite (Redshift sim)

---

## Results

| Metric | Value |
|---|---|
| XGBoost MAPE | **6.47%** |
| Accuracy improvement | **46%** over seasonal baseline |
| Inventory overstock reduction | **57%** |
| Retraining MAPE improvement | 12.13% → 6.62% across 4 cycles |
| Stores | 1,115 |
| Weekly records | 87,832 |
| Features engineered | 39 |

---

## Architecture
