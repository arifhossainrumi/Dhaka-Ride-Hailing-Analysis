-- ===================================================
-- 13 BUSINESS QUESTIONS – Ranked by Strategic Impact
-- Dhaka Ride-Hailing | 2021–2025
-- ===================================================

-- 1. Surge Effectiveness: % of Revenue from Surge (THE #1 profit driver)
SELECT
    ROUND(SUM(CASE WHEN is_surge THEN trip_revenue ELSE 0 END) * 100.0 / NULLIF(SUM(trip_revenue),0), 2) AS surge_revenue_pct
FROM trips WHERE cancelled = 0;

-- 2. Monthly Trip & Revenue Growth + Monsoon Impact
SELECT year, month,
       COUNT(*) AS trips,
       SUM(trip_revenue) AS revenue_bdt,
       ROUND(AVG(speed_kmh)::numeric, 1) AS avg_speed_kmh
FROM trips
WHERE cancelled = 0
GROUP BY year, month
ORDER BY year,
    CASE month
        WHEN 'January' THEN 1 WHEN 'February' THEN 2 WHEN 'March' THEN 3 WHEN 'April' THEN 4
        WHEN 'May' THEN 5 WHEN 'June' THEN 6 WHEN 'July' THEN 7 WHEN 'August' THEN 8
        WHEN 'September' THEN 9 WHEN 'October' THEN 10 WHEN 'November' THEN 11 WHEN 'December' THEN 12
    END;

-- 3. Monsoon Season Deep Dive (Speed & Surge)
SELECT
    CASE WHEN is_monsoon THEN 'Monsoon (Jun–Sep)' ELSE 'Dry Season (Oct–May)' END AS season,
    COUNT(*) AS trips,
    ROUND(AVG(speed_kmh)::numeric, 1) AS avg_speed_kmh,
    ROUND(AVG(surge_multiplier)::numeric, 2) AS avg_surge
FROM trips WHERE cancelled = 0
GROUP BY is_monsoon;

-- 4. Peak vs Off-Peak Performance (Revenue concentration)
SELECT
    CASE WHEN is_peak_hour THEN 'Peak Hours' ELSE 'Off-Peak' END AS period,
    COUNT(*) AS trips,
    SUM(trip_revenue) AS revenue_bdt,
    ROUND(AVG(surge_multiplier)::numeric, 2) AS avg_surge,
    ROUND(AVG(speed_kmh)::numeric, 1) AS avg_speed_kmh
FROM trips WHERE cancelled = 0
GROUP BY is_peak_hour;

-- 5. Top 10 Most Profitable Routes (Supply positioning gold)
SELECT pickup_area || ' → ' || dropoff_area AS route,
       COUNT(*) AS trips,
       SUM(trip_revenue) AS total_revenue_bdt,
       ROUND(AVG(trip_revenue), 0) AS avg_fare
FROM trips WHERE cancelled = 0
GROUP BY route
ORDER BY total_revenue_bdt DESC LIMIT 10;

-- 6. Vehicle Type Market Share Evolution (Fleet strategy)
SELECT year, vehicle_type,
       COUNT(*) AS trips,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY year), 1) AS market_share_pct
FROM trips WHERE cancelled = 0
GROUP BY year, vehicle_type
ORDER BY year, market_share_pct DESC;

-- 7. Peak-Hour Vehicle Preference Shift
SELECT
    CASE WHEN is_peak_hour THEN 'Peak Hours' ELSE 'Off-Peak' END AS period,
    vehicle_type,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY is_peak_hour), 1) AS share_pct
FROM trips WHERE cancelled = 0
GROUP BY is_peak_hour, vehicle_type
ORDER BY is_peak_hour DESC, share_pct DESC;

-- 8. Weather Impact on Vehicle Choice (Monsoon behavior)
SELECT
    CASE WHEN is_monsoon THEN 'Monsoon Season' ELSE 'Dry Season' END AS weather,
    vehicle_type,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY is_monsoon), 1) AS share_pct
FROM trips WHERE cancelled = 0
GROUP BY is_monsoon, vehicle_type
ORDER BY is_monsoon DESC, share_pct DESC;

-- 9. Fare Inflation by Vehicle Type (Pricing health check)
SELECT vehicle_type, year,
       ROUND(AVG(fare_bdt / NULLIF(distance_km,0))::numeric, 1) AS avg_per_km_rate
FROM trips WHERE cancelled = 0 AND distance_km > 0
GROUP BY vehicle_type, year
ORDER BY vehicle_type, year;

-- 10. Payment Method Adoption Trend (Cash → Digital shift)
SELECT year, payment_method,
       COUNT(*) AS trips,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY year), 1) AS share_pct
FROM trips WHERE cancelled = 0
GROUP BY year, payment_method
ORDER BY year, share_pct DESC;

-- 11. Cancellation Rate Trend (Operational health)
SELECT year,
       ROUND(AVG(cancelled)::numeric * 100, 2) AS cancellation_rate_pct
FROM trips
GROUP BY year ORDER BY year;

-- 12. Top 5 Drivers by Revenue (Driver loyalty insights)
SELECT driver_id,
       COUNT(*) AS total_trips,
       SUM(trip_revenue) AS total_revenue_bdt,
       ROUND(AVG(rider_rating)::numeric, 2) AS avg_rating
FROM trips WHERE cancelled = 0
GROUP BY driver_id
ORDER BY total_revenue_bdt DESC LIMIT 5;

-- 13. Weekend vs Weekday Behavior (Demand pattern)
SELECT
    CASE WHEN is_weekend THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    ROUND(AVG(distance_km)::numeric, 2) AS avg_distance_km,
    ROUND(AVG(fare_bdt)::numeric, 0) AS avg_fare_bdt
FROM trips WHERE cancelled = 0
GROUP BY is_weekend;