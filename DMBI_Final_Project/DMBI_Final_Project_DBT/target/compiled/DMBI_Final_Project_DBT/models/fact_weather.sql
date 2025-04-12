

-- Select and transform data from raw meteorological source table
SELECT
    CAST(date AS DATE) AS date,
    CAST(temperature AS DECIMAL(9,2)) AS temperature,
    CAST(relative_humidity AS DECIMAL(9,2)) AS relative_humidity,
    CAST(precipitation_rate AS DECIMAL(9,2)) AS precipitation_rate,
    CAST(wind_speed AS DECIMAL(9,2)) AS wind_speed,
    zipcode
FROM `dmbi_fa`.`meteo_raw`
WHERE date IS NOT NULL  -- Ensuring no null values in date column