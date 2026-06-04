-- ================================================================
-- ETL Queries — Demand Forecasting Pipeline
-- Simulates Redshift SQL used in the automated retraining workflow
-- ================================================================


-- 1. EXTRACT: Pull recent sales data for retraining window
SELECT
    Store,
    Date,
    WeeklySales,
    lag_1w,
    lag_4w,
    lag_52w,
    rolling_mean_4w,
    rolling_std_4w,
    WeekOfYear,
    Month,
    is_christmas_week,
    PromoWeeks,
    StoreType,
    store_avg_sales
FROM sales_features
WHERE Date >= DATE('now', '-52 weeks')
ORDER BY Store, Date;


-- 2. AGGREGATE: Build weekly sales summary from raw daily data
SELECT
    Store,
    DATE(Date)          AS week_start,
    SUM(WeeklySales)    AS total_sales,
    AVG(WeeklySales)    AS avg_sales,
    MAX(WeeklySales)    AS max_sales,
    MIN(WeeklySales)    AS min_sales,
    SUM(PromoWeeks)     AS promo_days,
    MAX(SchoolHoliday)  AS has_school_holiday,
    MAX(StateHoliday)   AS has_state_holiday,
    StoreType,
    Assortment
FROM raw_sales
GROUP BY Store, DATE(Date), StoreType, Assortment
ORDER BY Store, week_start;


-- 3. QUALITY CHECK: Validate incoming data before retraining
SELECT
    COUNT(*)                                            AS total_rows,
    SUM(CASE WHEN WeeklySales IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN WeeklySales <= 0    THEN 1 ELSE 0 END) AS zero_or_neg_sales,
    MIN(WeeklySales)                                    AS min_sales,
    MAX(WeeklySales)                                    AS max_sales,
    ROUND(AVG(WeeklySales), 2)                          AS avg_sales,
    COUNT(DISTINCT Store)                               AS unique_stores
FROM raw_sales;


-- 4. MODEL PERFORMANCE LOG: Track MAPE across retraining versions
SELECT
    version,
    cutoff,
    training_rows,
    mape,
    ROUND(mape - LAG(mape) OVER (ORDER BY cutoff), 2) AS mape_delta
FROM retraining_log
ORDER BY cutoff;


-- 5. OVERSTOCK ANALYSIS: Identify stores with highest overstock risk
SELECT
    Store,
    ROUND(AVG(predicted_sales), 0)  AS avg_predicted,
    ROUND(AVG(WeeklySales), 0)      AS avg_actual,
    ROUND(AVG(predicted_sales - WeeklySales), 0) AS avg_overstock,
    COUNT(*)                         AS weeks_evaluated
FROM test_predictions
WHERE predicted_sales > WeeklySales
GROUP BY Store
ORDER BY avg_overstock DESC
LIMIT 20;