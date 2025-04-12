
  
    

  create  table
    `dmbi_fa`.`kpi_avg_installation_price__dbt_tmp`
    
    
      as
    
    (
      

-- Selecting finance type and the average installation price for "Individual Household" customers
SELECT 
    fin.finance_type AS finance_type,  -- Finance type category
    ROUND(COALESCE(AVG(sales.installation_price), 0), 2) AS avg_installation_price  -- Average installation price rounded to 2 decimal places
FROM dmbi_fa.fact_sales sales

-- Joining with customer type dimension to filter only 'Individual Household' customers
JOIN dmbi_fa.dim_customer_type cust
    ON sales.customer_type_id = cust.customer_type_id

-- Joining with finance type dimension to get finance type names
JOIN dmbi_fa.dim_finance_type fin
    ON sales.finance_type_id = fin.finance_type_id

-- Filtering for only 'Individual Household' customers to ensure we analyze the right group
WHERE cust.customer_type = 'Individual Household'

-- Grouping by finance type to calculate the average installation price per finance type
GROUP BY fin.finance_type

-- Sorting the results in descending order to show the most expensive installations first
ORDER BY avg_installation_price DESC
    )

  