-- =====================================================================
-- Medical Appointments No-Show Analysis — my SQL queries
-- Tool: DB Browser for SQLite · Table: appointments (49,593 rows)
-- Data: Medical Appointments No-Show (Salazar, Mendeley Data v1), 20 Jun 2016 – 25 Feb 2022
-- Written by me while learning SQL (7–8 Nov 2026) with an AI tutor.
-- Some queries were guided. Corrections on 8 Nov came from an AI review.
-- =====================================================================


-- ---------- 1. Exploring the data ----------

-- Show me the specialty column from the appointments table.
SELECT specialty
FROM appointments;

-- List every different city in the appointments table, with no repeats.
SELECT DISTINCT city
FROM appointments;

-- List each different no-show reason once.
SELECT DISTINCT no_show_reason
FROM appointments;

-- Show each different value in the no_show column.
SELECT DISTINCT no_show
FROM appointments;


-- ---------- 2. Filtering and sorting ----------

-- Show the no_show_reason for appointments where no_show is 'yes'.
-- (Values are case-sensitive: 'YES' returns nothing, 'yes' works.)
SELECT no_show_reason
FROM appointments
WHERE no_show = 'yes';

-- Show the specialty for appointments where the reason is 'sem transporte' (no transport).
SELECT specialty
FROM appointments
WHERE no_show_reason = 'sem transporte';

-- List each different specialty once, in alphabetical order.
SELECT DISTINCT specialty
FROM appointments
ORDER BY specialty;

-- List each different appointment_year once, newest year first.
SELECT DISTINCT appointment_year
FROM appointments
ORDER BY appointment_year DESC;

-- Show the 5 latest different appointment dates.
-- NOTE: this gives the WRONG order, because dates are stored as TEXT (DD/MM/YYYY),
-- so SQL sorts by the day first. The fix is in section 9.
SELECT DISTINCT appointment_date
FROM appointments
ORDER BY appointment_date DESC
LIMIT 5;


-- ---------- 3. Counting and grouping ----------

-- Count how many appointments were no-shows.            -- 4,832
SELECT COUNT(*)
FROM appointments
WHERE no_show = 'yes';

-- Count the appointments where no_show is 'no'.          -- 44,761
SELECT COUNT(*)
FROM appointments
WHERE no_show = 'no';

-- Each specialty with its number of appointments.
SELECT specialty, COUNT(*)
FROM appointments
GROUP BY specialty;

-- Each specialty with its number of no-shows, most no-shows first.
SELECT specialty, COUNT(*)
FROM appointments
WHERE no_show = 'yes'
GROUP BY specialty
ORDER BY COUNT(*) DESC;

-- Each appointment_year with its number of appointments, oldest year first.
SELECT appointment_year, COUNT(*)
FROM appointments
GROUP BY appointment_year
ORDER BY appointment_year ASC;

-- Each appointment_shift with its number of no-shows, biggest number first.
SELECT appointment_shift, COUNT(*)
FROM appointments
WHERE no_show = 'yes'
GROUP BY appointment_shift
ORDER BY COUNT(*) DESC;

-- Each appointment_shift with its total number of appointments.
SELECT appointment_shift, COUNT(*) AS total_appointments
FROM appointments
GROUP BY appointment_shift;

-- Each gender with its number of appointments, biggest number first.
SELECT gender, COUNT(*)
FROM appointments
GROUP BY gender
ORDER BY COUNT(*) DESC;


-- ---------- 4. HAVING (conditions on a count) ----------

-- Specialties with more than 5,000 appointments.
SELECT specialty, COUNT(*)
FROM appointments
GROUP BY specialty
HAVING COUNT(*) > 5000;

-- Specialties with more than 500 no-shows.
SELECT specialty, COUNT(*)
FROM appointments
WHERE no_show = 'yes'
GROUP BY specialty
HAVING COUNT(*) > 500;

-- Cities with more than 2,000 appointments, biggest first.
SELECT city, COUNT(*)
FROM appointments
GROUP BY city
HAVING COUNT(*) > 2000
ORDER BY COUNT(*) DESC;

-- No-show reasons that appear more than 50 times, most common first.
SELECT no_show_reason, COUNT(*)
FROM appointments
GROUP BY no_show_reason
HAVING COUNT(*) > 50
ORDER BY COUNT(*) DESC;


-- ---------- 5. AVG, MIN, MAX and CAST (age is stored as TEXT) ----------

-- Average age.                                           -- 18.5
SELECT AVG(CAST(age AS REAL))
FROM appointments;

-- Youngest and oldest age WITHOUT CAST.
-- NOTE: wrong (gave 10 and 91), because TEXT is compared letter by letter.
SELECT MIN(age), MAX(age)
FROM appointments;

-- Youngest and oldest age WITH CAST.                     -- 2 and 110
SELECT MIN(CAST(age AS REAL)), MAX(CAST(age AS REAL))
FROM appointments;

-- Count the appointments where age is greater than 100.  -- 84
SELECT COUNT(*)
FROM appointments
WHERE CAST(age AS REAL) > 100;

-- Average age for no-show vs attended appointments.      -- 19.4 vs 18.4
SELECT no_show, AVG(CAST(age AS REAL))
FROM appointments
GROUP BY no_show;


-- ---------- 6. CASE WHEN (labels and groups) ----------

-- Show age and a label: 'senior' if 60 or more, otherwise 'under 60'.
SELECT age,
       CASE WHEN CAST(age AS REAL) >= 60 THEN 'senior'
            ELSE 'under 60'
       END AS age_label
FROM appointments
LIMIT 10;

-- Same, but empty ages show 'unknown'.
SELECT age,
       CASE WHEN age IS NULL THEN 'unknown'
            WHEN CAST(age AS REAL) >= 60 THEN 'senior'
            ELSE 'under 60'
       END AS age_label
FROM appointments
LIMIT 10;

-- Each age group with its number of appointments.
SELECT CASE WHEN age IS NULL THEN 'unknown'
            WHEN CAST(age AS REAL) >= 60 THEN 'senior'
            ELSE 'under 60'
       END AS age_group,
       COUNT(*)
FROM appointments
GROUP BY age_group;

-- Appointments and no-shows in each age group.
SELECT CASE WHEN age IS NULL THEN 'unknown'
            WHEN CAST(age AS REAL) >= 60 THEN 'senior'
            ELSE 'under 60'
       END AS age_group,
       COUNT(*),
       SUM(CASE WHEN no_show = 'yes' THEN 1 ELSE 0 END)
FROM appointments
GROUP BY age_group;


-- ---------- 7. Rates (no-shows ÷ appointments × 100) ----------

-- For each age group: total, no-shows and no-show rate (%).
-- unknown 12.9% · senior 10.0% · under 60 8.8%
SELECT CASE WHEN age IS NULL THEN 'unknown'
            WHEN CAST(age AS REAL) >= 60 THEN 'senior'
            ELSE 'under 60'
       END AS age_group,
       COUNT(*) AS total,
       SUM(CASE WHEN no_show = 'yes' THEN 1 ELSE 0 END) AS no_shows,
       SUM(CASE WHEN no_show = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS no_show_rate
FROM appointments
GROUP BY age_group;

-- Lowest, highest and average value of average_temp_day.  -- 8.94 · 28.01 · 19.75
SELECT MIN(average_temp_day), MAX(average_temp_day), AVG(average_temp_day)
FROM appointments;

-- Label each appointment 'hot' (25 or more) or 'not hot', with counts.  -- hot 1,963 · not hot 47,630
SELECT CASE WHEN average_temp_day >= 25 THEN 'hot'
            ELSE 'not hot'
       END AS label,
       COUNT(*) AS total_appointments
FROM appointments
GROUP BY label;

-- No-show rate (%) for 'hot' vs 'not hot' days.           -- 10.0% vs 9.7%
SELECT CASE WHEN average_temp_day >= 25 THEN 'hot'
            ELSE 'not hot'
       END AS label,
       SUM(CASE WHEN no_show = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS no_show_rate
FROM appointments
GROUP BY label;

-- No-show rate (%) for each gender.                       -- F 10.3% · M 9.6%
SELECT gender,
       SUM(CASE WHEN no_show = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS no_show_rate
FROM appointments
GROUP BY gender;

-- Appointments and no-show rate (%) for each year, oldest first.
-- 2016 and 2022 are partial years.
SELECT appointment_year,
       COUNT(*) AS appointments,
       SUM(CASE WHEN no_show = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS no_show_rate
FROM appointments
GROUP BY appointment_year
ORDER BY appointment_year ASC;

-- Appointments and no-show rate (%) for each city, highest rate first.
-- 5,181 appointments have no city (15.1% no-show rate).
SELECT city,
       COUNT(*) AS appointments,
       SUM(CASE WHEN no_show = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS no_show_rate
FROM appointments
GROUP BY city
ORDER BY no_show_rate DESC;


-- ---------- 8. Missing data and filters (IS NULL, AND, OR, IN, LIKE, BETWEEN) ----------

-- Count the appointments where specialty is empty (NULL). -- 7,454
SELECT COUNT(*)
FROM appointments
WHERE specialty IS NULL;

-- Missing BOTH specialty and age.                         -- 2,934
SELECT COUNT(*)
FROM appointments
WHERE specialty IS NULL AND age IS NULL;

-- Missing specialty OR age (or both).                     -- 14,870
SELECT COUNT(*)
FROM appointments
WHERE specialty IS NULL OR age IS NULL;

-- Complete rows: both specialty and age present.          -- 34,723
SELECT COUNT(*)
FROM appointments
WHERE specialty IS NOT NULL AND age IS NOT NULL;

-- Reason is 'doente' or 'sem transporte' (IN).            -- 388
SELECT COUNT(*)
FROM appointments
WHERE no_show_reason IN ('doente', 'sem transporte');

-- Reason contains 'transporte' (LIKE).                    -- 205
SELECT COUNT(*)
FROM appointments
WHERE no_show_reason LIKE '%transporte%';

-- Reason contains 'doente' (sick).                        -- 257
SELECT COUNT(*)
FROM appointments
WHERE no_show_reason LIKE '%doente%';

-- Age between 60 and 100.                                 -- 3,476
SELECT COUNT(*)
FROM appointments
WHERE CAST(age AS REAL) BETWEEN 60 AND 100;

-- No-shows with no reason recorded (empty or only spaces). -- 3,155 of 4,832 (65.3%)
-- (Check query given by my tutor on 8 Nov, not yet written on my own.)
SELECT COUNT(*)
FROM appointments
WHERE no_show = 'yes'
  AND (no_show_reason IS NULL OR TRIM(no_show_reason) = '');


-- ---------- 9. Fixing TEXT dates (substr and ||) ----------

-- Cut the year out of appointment_date (start 7, take 4).
SELECT appointment_date,
       substr(appointment_date, 7, 4) AS year_from_date
FROM appointments
LIMIT 5;

-- Cut out the month (start 4, take 2).
SELECT appointment_date,
       substr(appointment_date, 4, 2) AS month_from_date
FROM appointments
LIMIT 5;

-- Cut out the day (start 1, take 2).
SELECT appointment_date,
       substr(appointment_date, 1, 2) AS day_from_date
FROM appointments
LIMIT 5;

-- Month and year in one query.
SELECT appointment_date,
       substr(appointment_date, 4, 2) AS month_from_date,
       substr(appointment_date, 7, 4) AS year_from_date
FROM appointments
LIMIT 5;

-- Glue appointment_shift and no_show with a dash.
SELECT appointment_shift || ' - ' || no_show AS shift_status
FROM appointments
LIMIT 5;

-- Glue year and month: YYYY-MM.
SELECT substr(appointment_date, 7, 4) || '-' || substr(appointment_date, 4, 2) AS year_month
FROM appointments
LIMIT 5;

-- Full sortable date: YYYY-MM-DD.
SELECT substr(appointment_date, 7, 4) || '-' ||
       substr(appointment_date, 4, 2) || '-' ||
       substr(appointment_date, 1, 2) AS sortable_date
FROM appointments
LIMIT 5;

-- The 5 latest different dates, newest first.             -- last date: 2022-02-25
SELECT DISTINCT
       substr(appointment_date, 7, 4) || '-' ||
       substr(appointment_date, 4, 2) || '-' ||
       substr(appointment_date, 1, 2) AS sortable_date
FROM appointments
ORDER BY sortable_date DESC
LIMIT 5;

-- The 5 earliest different dates, oldest first.           -- first date: 2016-06-20
SELECT DISTINCT
       substr(appointment_date, 7, 4) || '-' ||
       substr(appointment_date, 4, 2) || '-' ||
       substr(appointment_date, 1, 2) AS sortable_date
FROM appointments
ORDER BY sortable_date ASC
LIMIT 5;
