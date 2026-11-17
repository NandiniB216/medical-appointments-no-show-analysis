-- =====================================================================
-- Medical Appointments No-Show Analysis — my SQL queries
-- Tool: DB Browser for SQLite · Table: appointments (49,593 rows)
-- Data: Medical Appointments No-Show (Salazar, Mendeley Data v1), 20 Jun 2016 – 25 Feb 2022
-- Typed and run by me while learning SQL (7–13 Nov 2026) with an AI tutor.
-- Not every query is independent work. Written with guidance so far:
--   * every no-show rate query in section 7 (no solo pass on rates yet)
--   * the IS NOT NULL query in section 8 (fixed after a hint)
--   * the full YYYY-MM-DD date queries in section 9 (built with a skeleton)
--   * the no-reason check in section 8 (given by my tutor)
-- From section 10 on, each query is tagged [solo] or [guided] and has its tracker ID (EX-0xx).
-- The README's SQL progress table shows which concepts I've passed on my own.
-- Corrections on 8 Nov came from an AI review.
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

-- Appointments and no-show rate (%) for each specialty, highest rate first.
-- physiotherapy 10.4% (9,074) · no specialty 12.1% (7,454) · 'sem especialidade' 22.8% is only 57 appointments
SELECT specialty,
       COUNT(*) AS total_appointments,
       SUM(CASE WHEN no_show = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS no_show_rate
FROM appointments
GROUP BY specialty
ORDER BY no_show_rate DESC;


-- ---------- 8. Missing data and filters (IS NULL, AND, OR, IN, LIKE, BETWEEN, COUNT variants) ----------

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

-- All appointments vs appointments with a city recorded.  -- 49,593 vs 44,412
-- (COUNT(city) skips NULLs, so 5,181 appointments have no city.)
SELECT COUNT(*), COUNT(city)
FROM appointments;

-- Number of different no-show reasons recorded.           -- 341
SELECT COUNT(DISTINCT no_show_reason)
FROM appointments;

-- Number of different cities recorded (NULL not counted). -- 13
SELECT COUNT(DISTINCT city)
FROM appointments;


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


-- ---------- 10. Duplicate checks (GROUP BY several columns + HAVING) ----------

-- EX-073 · Appointments for each appointment_shift + no_show combination [solo]
-- afternoon 25,103 no / 2,762 yes · morning 19,658 no / 2,070 yes (adds to 49,593)
SELECT appointment_shift, no_show, COUNT(*)
FROM appointments
GROUP BY appointment_shift, no_show;

-- EX-075 · City + no_show combinations with more than 2,000 appointments [solo]  -- 6 rows, all 'no'
SELECT city, no_show, COUNT(*) AS total_appointments
FROM appointments
GROUP BY city, no_show
HAVING COUNT(*) > 2000;

-- EX-074 · Rows identical in all 26 columns (possible duplicate records) [guided]  -- 2,297 groups
-- (No patient ID, and GROUP BY treats NULLs as equal, so not all are true duplicates.)
SELECT COUNT(*)
FROM appointments
GROUP BY specialty, appointment_time, gender, appointment_date, no_show,
         no_show_reason, disability, date_of_birth, entry_service_date, city,
         icd, appointment_month, appointment_year, appointment_shift, age,
         under_12_years_old, over_60_years_old, patient_needs_companion,
         average_temp_day, average_rain_day, max_temp_day, max_rain_day,
         rainy_day_before, storm_day_before, rain_intensity, heat_intensity
HAVING COUNT(*) > 1;

-- EX-076 · Possible double bookings: same date_of_birth, specialty, date and time [solo]  -- 3,368 groups
SELECT COUNT(*)
FROM appointments
GROUP BY date_of_birth, specialty, appointment_date, appointment_time
HAVING COUNT(*) > 1;

-- EX-077 · Same check, leaving out appointments with no date_of_birth [guided]  -- 1,506 groups
-- (1,862 of the 3,368 came only from missing birth dates.)
SELECT COUNT(*)
FROM appointments
WHERE date_of_birth IS NOT NULL
GROUP BY date_of_birth, specialty, appointment_date, appointment_time
HAVING COUNT(*) > 1;


-- ---------- 11. Cleaning text and missing values (TRIM, LOWER, REPLACE, COALESCE, CASE recoding) ----------

-- EX-078 · Different no-show reasons before and after TRIM [solo]  -- 341 · 341
select count(distinct no_show_reason) as original_no_show_reason,
count(distinct trim(no_show_reason)) as trimmed_no_show_reason
from appointments;

-- EX-079 · Add a third column: different reasons after LOWER [solo]  -- 341 · 341 · 341
-- (So the 341 spellings are not caused by extra spaces or capital letters.)
select count(distinct no_show_reason) as original_no_show_reason,
count(distinct trim(no_show_reason)) as trimmed_no_show_reason,
COUNT(DISTINCT LOWER(NO_SHOW_REASON)) AS lowered_no_show_reason
from appointments;

-- EX-080 · Each city next to a cleaned name with 'BALN.' replaced by 'BALNEARIO' [guided]  -- 14 rows
-- BALN. PIÇARRAS → BALNEARIO PIÇARRAS; all other cities unchanged.
select DISTINCT city as original_city_name,
replace (city,'BALN.', 'BALNEARIO') as cleaned_city
from appointments;

-- EX-081 · Same-day repeats: date_of_birth + gender + appointment_date more than once, missing birth dates left out [solo]  -- 11,057 groups
-- (EX-082: same query, logged for IS NOT NULL.) Probably normal multi-therapy days, not errors.
select count(*)
from appointments
where date_of_birth is not NULL
group by date_of_birth,gender,appointment_date
having count(*)>1;

-- EX-083 · Each city next to a cleaned name with 'B.' replaced by 'BALNEARIO' [solo]  -- 14 rows
-- B. CAMBORIU → BALNEARIO CAMBORIU; all other cities unchanged.
select distinct city as original_city,
replace (city,'B.','BALNEARIO' ) AS CLEANED_CITY
FROM appointments;

-- EX-084 · Appointments per specialty, empty specialty shown as 'no specialty' (COALESCE) [guided]  -- 9 rows · no specialty 7,454
SELECT COALESCE(specialty, 'no specialty') AS specialty_clean,
       COUNT(*) AS no_of_appointments
FROM appointments
GROUP BY COALESCE(specialty, 'no specialty');

-- EX-085 · Appointments per specialty, NULL and 'sem especialidade' both shown as 'no specialty' (CASE + IS NULL + OR) [guided]  -- 8 rows · no specialty 7,511
select case when specialty is null or specialty='sem especialidade' then  'no specialty'
else specialty
end as specialty_group,
count(*) as appointment_count
from appointments
group by specialty_group;

-- EX-086 · Each city next to a cleaned city, empty city shown as 'unknown' (COALESCE), 10 rows [solo]  -- 10 rows
select city, coalesce(city,'unknown') as cleaned_city
from appointments
limit 10;

-- EX-087 · Appointments per city, no city recorded as its own group (COALESCE + GROUP BY) [solo]  -- 14 rows · no city recorded 5,181 · adds to 49,593
select coalesce(city,'no city recorded') as city_group,
count(*) as appointment_count
from appointments
group by coalesce(city,'no city recorded')
order by appointment_count desc;


-- ---------- 12. Flag checks and grouping free text (CASE recoding, AND/OR with brackets, CASE + LIKE, NOT LIKE) ----------

-- EX-088 · No-shows per specialty group, NULL and 'sem especialidade' both shown as 'no specialty' [guided]  -- 8 rows · no specialty 914 · adds to 4,832
-- (CASE logic right first time; WHERE and GROUP BY added after hints.)
SELECT case when specialty is null or specialty='sem especialidade' then 'no specialty'
else specialty
end as specialty_group,
count(*) as no_shows
from appointments 
where no_show='yes'
group by specialty_group;

-- EX-089 · Flag check step 1: values of over_60_years_old [solo]  -- 0 = 46,033 · 1 = 3,560
select over_60_years_old, count(*) as no_of_appointments
from appointments
group by over_60_years_old;

-- EX-090 · Flag check step 2: does over_60_years_old agree with age? [solo]
-- 0 / under 60 = 35,683 · 0 / unknown = 10,350 · 1 / 60 or more = 3,560 (adds to 49,593)
-- (No disagreement where age is known; every missing age is flagged 0.)
select over_60_years_old,
	case when age is null then 'unknown'
when CAST(age as real)<60 then  'under 60'
else '60 or more'
end as age_label, 
count(*) as appointments
from appointments
group by over_60_years_old,age_label;

-- EX-091 · Flag check step 3: appointments where over_60_years_old contradicts age (AND + OR with brackets) [guided]  -- 0
-- (Signs were reversed first, which counted the agreeing rows: 39,243; fixed after a hint.)
select count(*)
from appointments 
where (over_60_years_old=1 and CAST(age as real)<60)
or (over_60_years_old=0 and cast(age as REAL)>=60);

-- EX-092 · No-shows labelled 'transport' if the reason contains 'transporte', otherwise 'other' (CASE + LIKE) [solo]  -- transport 205 · other 4,627
select case when no_show_reason like '%transporte%' then 'transport'
else 'other'
end as reason_category,
count(*) as appointment_count
from appointments
where no_show='yes'
group by reason_category;

-- EX-093 · No-shows in 4 reason groups (transport, sick, no reason, other) [solo]  -- no reason 3,155 · other 1,217 · sick 255 · transport 205
-- (NOTE: TRIM(no_show_reason) = ' ' can never match, it should be = ''. No effect here, because every
--  missing reason is NULL. The label should read 'no reason recorded'. Both fixed in EX-096.)
select case 
	when no_show_reason like '%transporte%' then 'transport'
	when no_show_reason like '%doente%' then 'sick'
	when no_show_reason is null or trim(no_show_reason)=' ' then 'no_show_recorded'
else 'other'
end as reason_category,
count(*) as appointment_count
from appointments
where no_show='yes'
group by reason_category;

-- EX-094 · The 10 most common 'other' no-show reasons (NOT LIKE) [solo]  -- 10 rows
-- gripe 78 · desmarcado 78 · cancelado atendimento sexta feira 55 · atestado 49 · doença 47 ·
-- remarcado 41 · yes atendeu 22 · febre 22 · viajando 17 · sem carro 17
SELECT no_show_reason,
COUNT(*) as reason_count
from appointments
where no_show='yes'
and no_show_reason is not null
and no_show_reason not like '%transporte%'
and no_show_reason not like '%doente%'
group by no_show_reason
order by reason_count desc
limit 10;

-- EX-096 · Final reason groups with full keyword lists [guided]
-- no reason 3,155 · other 753 · sick 471 · transport 244 · cancelled 209 (adds to 4,832)
-- (My own first version is EX-095; the extra keywords and the '%remarc%' fix came from hints.
--  'desmarcado' / 'remarcado' don't say who cancelled, so 'clinic cancelled' may include patients.)
select case 
	when no_show_reason like '%transporte%' or no_show_reason like '%transport%' or no_show_reason like '%carro%' then 'transport'
	when no_show_reason like '%doente%' or no_show_reason  like '%doença%' or no_show_reason like '%gripe%' or no_show_reason like '%febre%' or no_show_reason like '%atestado%' then 'sick'
	when no_show_reason is null or trim(no_show_reason)= '' then 'no_reason_recorded'
	when no_show_reason like '%cancelado%' or no_show_reason like '%cancelada%' or no_show_reason like '%desmarc%' or no_show_reason like '%remarc%' then 'clinic cancelled'
else 'other'
end as reason_category,
count(*) as appointment_count
from appointments
where no_show='yes'
group by reason_category
ORDER by appointment_count desc;

-- EX-097 · Retry of EX-088 (cold, no example): ATTENDED appointments per specialty group,
-- NULL and 'sem especialidade' both shown as 'no specialty' [solo]  -- 8 rows · no specialty 6,597 · adds to 44,761
select case when specialty is null or specialty ='sem especialidade' then 'no specialty'
else specialty
end as speciality_group,
count(*) as appointments
from appointments
where no_show='no'
group by speciality_group
order by appointments desc;

-- EX-098 · Retry of EX-096 (cold, typed from memory ~40 min later): the 5 reason groups [solo]
-- no reason 3,155 · other 753 · sick 471 · transport 244 · cancelled/rescheduled 209 (adds to 4,832)
select case 
	when no_show_reason like '%transporte%' or no_show_reason like '%transport%' or no_show_reason like '%carro%' then 'transport'
	when no_show_reason like '%doente%' or no_show_reason  like '%doença%' or no_show_reason like '%gripe%' or no_show_reason like '%febre%' or no_show_reason like '%atestado%' then 'sick'
	when no_show_reason is null or trim(no_show_reason) = '' then 'no_reason_recorded'
	when no_show_reason like '%cancelado%' or no_show_reason like '%cancelada%' or no_show_reason like '%desmarc%' or no_show_reason like '%remarc%' then 'cancelled/rescheduled'
else 'other'
end as reason_category,
count(*) as appointment_count
from appointments
where no_show='yes'
group by reason_category
order by appointment_count desc;


-- ---------- 13. Lookup tables and JOINs (CREATE TABLE AS SELECT, INNER JOIN) ----------
-- NOTE: the two CREATE TABLE queries add new tables to the database, so each one works only once.
-- Running it again stops with "table already exists". To rebuild a table, first run: DROP TABLE table_name;

-- EX-107 · Lookup table: each real specialty once ('sem especialidade' left out on purpose,
-- because it means "no specialty") [solo]  -- 7 rows
create table specialty_lookup as 
select DISTINCT specialty
from appointments
where specialty is not null 
and trim(specialty) <> ''
and specialty <>'sem especialidade';

-- Check the lookup table.  -- 7 rows
select * from specialty_lookup;


-- EX-108 · Lookup table: each month name with its month number, cut from appointment_date [guided]  -- 12 rows
-- (First tries typed the numbers by hand and missed 'april', 'june', 'july'; fixed after hints.)
create table month_lookup as
select DISTINCT appointment_month,
cast(substr(appointment_date,4,2)as INTEGER) as month_number
from appointments
where appointment_month is not null
order by month_number asc;

-- Check the lookup table in calendar order.  -- jan 1 ... dec 12
select * from month_lookup
order by month_number;

-- EX-109 · First INNER JOIN: no-shows per month in calendar order [guided]  -- 12 rows · adds to 4,832
-- jan 161 · feb 475 · mar 362 · april 426 · may 400 · june 659 · july 359 · aug 437 · sept 412 · oct 540 · nov 395 · dec 206
-- (Counts, not rates: months have different numbers of appointments.)
select month_lookup.appointment_month,
month_lookup.month_number,
count(*) as no_shows
from appointments
inner join month_lookup
on appointments.appointment_month = month_lookup.appointment_month
where no_show='yes'
group by month_lookup.appointment_month,month_lookup.month_number
order by month_lookup.month_number;

-- EX-110 · Appointments and no-show rate (%) per month, using the same JOIN [solo; decimals fixed after a hint]
-- jan 12.4 · feb 12.7 · mar 9.1 · april 10.8 · may 10.8 · june 13.2 · july 7.1 · aug 7.3 · sept 8.8 · oct 8.6 · nov 10.0 · dec 10.8
-- (Totals add to 49,593. Preliminary: months mix years, e.g. jan/feb include 2022, jul-dec include 2016.)
select month_lookup.appointment_month,
month_lookup.month_number,
count(*) as total_appointments,
sum (case when no_show='yes' then 1 else 0  END)*100.0/count(*) as no_show_rate
from appointments
inner join month_lookup
on appointments.appointment_month=month_lookup.appointment_month
group by month_lookup.appointment_month,month_lookup.month_number
order by month_lookup.month_number;
