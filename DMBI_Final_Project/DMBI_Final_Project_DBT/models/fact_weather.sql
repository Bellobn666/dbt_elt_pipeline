{{ config(
    materialized='table',
    post_hook=[
        "ALTER TABLE {{ this }} MODIFY COLUMN zipcode VARCHAR(10) NOT NULL;",
        
        "CREATE INDEX idx_weather_date ON {{ this }}(date);",
        "CREATE INDEX idx_weather_zipcode ON {{ this }}(zipcode);",

        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_weather PRIMARY KEY (date, zipcode);"
    ]
) }}

-- Select and transform data from raw meteorological source table
SELECT
    CAST(date AS DATE) AS date,
    CAST(temperature AS DECIMAL(9,2)) AS temperature,
    CAST(relative_humidity AS DECIMAL(9,2)) AS relative_humidity,
    CAST(precipitation_rate AS DECIMAL(9,2)) AS precipitation_rate,
    CAST(wind_speed AS DECIMAL(9,2)) AS wind_speed,
    zipcode
FROM {{ ref('meteo_raw') }}
WHERE date IS NOT NULL  -- Ensuring no null values in date column
