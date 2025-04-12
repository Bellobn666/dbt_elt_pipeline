{{ config(
    materialized='table',
    post_hook=[
        "ALTER TABLE {{ this }} MODIFY COLUMN finance_type_id INT AUTO_INCREMENT PRIMARY KEY;",
        "ALTER TABLE {{ this }} MODIFY COLUMN finance_type VARCHAR(255);"
    ]
) }}

WITH distinct_finance_types AS (
    -- Select distinct financing types from the 'sales_raw' table
    SELECT DISTINCT financing_type as finance_type
    FROM {{ ref('sales_raw') }}
)

SELECT
    -- Assign a unique ID to each finance type using ROW_NUMBER()
    ROW_NUMBER() OVER (ORDER BY finance_type) AS finance_type_id,
    finance_type
FROM distinct_finance_types
