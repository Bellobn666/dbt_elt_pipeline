

-- Create a Common Table Expression (CTE) to rank sales by month based on the total number of sales for 'cash' finance type
WITH RANKED_SALES AS (
    SELECT 
        DATE_FORMAT(project_validation_date, '%Y-%m') AS SALES_MONTH,  -- Format the project_validation_date to year-month format
        COUNT(*) AS TOTAL_SALES,  -- Count the total number of sales for each month
        -- Use DENSE_RANK to assign ranks to months based on the total number of sales, in descending order
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS DENSE_RANK_NUM
    FROM DMBI_FA.FACT_SALES SF
    LEFT JOIN DMBI_FA.DIM_FINANCE_TYPE FT  -- Join with DIM_FINANCE_TYPE to filter on 'cash' finance type
        ON SF.FINANCE_TYPE_ID = FT.FINANCE_TYPE_ID
    WHERE FT.FINANCE_TYPE = 'cash'  -- Filter to include only sales with 'cash' as the finance type
    GROUP BY SALES_MONTH  -- Group by the formatted sales month to calculate monthly sales count
    HAVING SALES_MONTH IS NOT NULL  -- Ensure that only valid (non-null) months are included
)
-- Final SELECT to retrieve the top-ranked sales months based on total sales for 'cash' finance type
SELECT 
    sales_month,  -- The sales month (year-month format)
    total_sales  -- The total number of sales for the given month
FROM RANKED_SALES
-- Filter to only include the top sales month(s) (adjust the condition to return top N months)
WHERE DENSE_RANK_NUM <= 1