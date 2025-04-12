

WITH RECURSIVE date_range AS (
    -- Generate a sequence of numbers from 0 up to the difference in days between the start and end dates
    SELECT 0 AS day_sequence
    UNION ALL
    SELECT day_sequence + 1
    FROM date_range
    WHERE day_sequence + 1 <= DATEDIFF('2024-12-31', '2020-01-01')
)
SELECT
    -- Generate a unique key for each date using ROW_NUMBER()
    ROW_NUMBER() OVER (ORDER BY day_sequence) AS date_key,

    -- Calculate the actual date by adding the sequence number to the start date
    CAST(DATE_ADD('2020-01-01', INTERVAL day_sequence DAY) AS DATE) AS full_date,
    
    -- Extract various date components for easier analysis
    DAY(DATE_ADD('2020-01-01', INTERVAL day_sequence DAY)) AS day_of_month,
    MONTH(DATE_ADD('2020-01-01', INTERVAL day_sequence DAY)) AS month,
    QUARTER(DATE_ADD('2020-01-01', INTERVAL day_sequence DAY)) AS quarter,
    YEAR(DATE_ADD('2020-01-01', INTERVAL day_sequence DAY)) AS year,
    DAYNAME(DATE_ADD('2020-01-01', INTERVAL day_sequence DAY)) AS day_name,
    DAYOFWEEK(DATE_ADD('2020-01-01', INTERVAL day_sequence DAY)) AS weekday
FROM date_range
ORDER BY full_date