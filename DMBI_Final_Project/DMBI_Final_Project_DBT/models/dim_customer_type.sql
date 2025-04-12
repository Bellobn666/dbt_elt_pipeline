{{ config(
    materialized='table',
    post_hook=[ 
        "ALTER TABLE {{ this }} MODIFY COLUMN customer_type_id INT AUTO_INCREMENT PRIMARY KEY;", 
        "ALTER TABLE {{ this }} MODIFY COLUMN customer_type VARCHAR(255);"
    ]
) }}

-- Create a Common Table Expression (CTE) to select distinct customer types from the 'sales_raw' table
WITH distinct_customer_types AS (
    SELECT DISTINCT cusomer_type as customer_type  -- Select unique customer types and rename 'cusomer_type' to 'customer_type'
    FROM {{ ref('sales_raw') }}  -- Reference the 'sales_raw' table in the model
)

-- Select the distinct customer types and assign a unique customer_type_id to each using ROW_NUMBER()
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_type) AS customer_type_id,  -- Assign a unique customer_type_id using ROW_NUMBER()
    customer_type  -- Select the customer type
FROM distinct_customer_types  -- Use the CTE that contains the distinct customer types
