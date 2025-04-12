
  
    

  create  table
    `dmbi_fa`.`dim_finance_type__dbt_tmp`
    
    
      as
    
    (
      

WITH distinct_finance_types AS (
    -- Select distinct financing types from the 'sales_raw' table
    SELECT DISTINCT financing_type as finance_type
    FROM `dmbi_fa`.`sales_raw`
)

SELECT
    -- Assign a unique ID to each finance type using ROW_NUMBER()
    ROW_NUMBER() OVER (ORDER BY finance_type) AS finance_type_id,
    finance_type
FROM distinct_finance_types
    )

  