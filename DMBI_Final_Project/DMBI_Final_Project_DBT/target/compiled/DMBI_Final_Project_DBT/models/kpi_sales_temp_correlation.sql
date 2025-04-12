

-- Calculate sales_done and leads count per ZIPCODE in the 'sales_fact' table
WITH sales_done AS (
    SELECT
        zipcode,
        COUNT(CASE WHEN project_validation_date IS NOT NULL THEN 1 END) AS sales_done,  -- Count of completed sales (i.e., sales with a validated project)
        COUNT(LEAD_ID) AS LEADS_COUNT  -- Total number of leads per ZIPCODE
    FROM DMBI_FA.fact_sales
    JOIN DMBI_FA.dim_phases
		ON fact_sales.current_phase_id = dim_phases.phase_id
    WHERE dim_phases.phase_name = "Validated project"  -- Filter for sales in the "Validated project" phase
    GROUP BY zipcode  -- Group by ZIPCODE to calculate aggregates per ZIPCODE
),

-- Calculate total leads count per ZIPCODE in the 'fact_sales' table
lead_count AS (
    SELECT 
        zipcode,
        COUNT(lead_id) AS lead_count  -- Total number of leads per ZIPCODE
    FROM DMBI_FA.fact_sales
    GROUP BY zipcode  -- Group by ZIPCODE to calculate the total leads count
),

-- Calculate average temperature per ZIPCODE in the 'fact_weather' table
weather AS (
    SELECT 
        zipcode,
        AVG(temperature) AS avg_temperature  -- Average temperature per ZIPCODE
    FROM DMBI_FA.fact_weather
    GROUP BY zipcode  -- Group by ZIPCODE to calculate the average temperature
)

-- Final SELECT to combine the results from the previous CTEs
SELECT 
    sd.zipcode,
    sd.sales_done,  -- The number of completed sales per ZIPCODE
    lc.lead_count,  -- The total number of leads per ZIPCODE
    ROUND(CASE  -- Calculate the sales conversion percentage
        WHEN lc.lead_count > 0 THEN (sd.sales_done / lc.lead_count) * 100  -- Sales conversion formula
        ELSE 0  -- If no leads exist, sales conversion is 0
    END, 2) AS sales_conversion,  -- Round the conversion to 2 decimal places
    ROUND(w.avg_temperature, 2) AS avg_temperature  -- Round the average temperature to 2 decimal places
FROM sales_done sd
    -- Left join to bring in the lead count for each ZIPCODE
    LEFT JOIN lead_count lc
        ON sd.zipcode = lc.zipcode
    -- Left join to bring in the average temperature for each ZIPCODE
    LEFT JOIN weather w
        ON sd.zipcode = w.zipcode
-- Only include ZIPCODEs with results (non-null)
HAVING sd.zipcode IS NOT NULL
-- Sort by the number of completed sales in descending order
ORDER BY sd.sales_done DESC