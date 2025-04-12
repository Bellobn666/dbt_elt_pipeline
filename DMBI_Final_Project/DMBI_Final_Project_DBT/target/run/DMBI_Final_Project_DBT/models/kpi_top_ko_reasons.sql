
  
    

  create  table
    `dmbi_fa`.`kpi_top_ko_reasons__dbt_tmp`
    
    
      as
    
    (
      

-- Create a Common Table Expression (CTE) to calculate the count and percentage of each KO_REASON_ID in the sales fact table
WITH KO_REASONS AS (
    SELECT 
        KO_REASON_ID,  -- KO_REASON_ID from the sales fact table
        COUNT(KO_REASON_ID) AS KO_COUNT,  -- Count of occurrences for each KO_REASON_ID
        -- Calculate the percentage of each KO_REASON_ID as a proportion of the total number of KO_REASON_IDs in the entire sales fact table
        (COUNT(KO_REASON_ID) / (SELECT COUNT(KO_REASON_ID) FROM DMBI_FA.FACT_SALES) * 100) AS PERCENTAGE,
        -- Use DENSE_RANK to rank KO_REASON_IDs by the count, in descending order (more common reasons ranked higher)
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS DENSE_RANK_NUM
    FROM DMBI_FA.FACT_SALES
    GROUP BY KO_REASON_ID  -- Group by KO_REASON_ID to get counts for each unique reason
    ORDER BY KO_COUNT DESC  -- Order by the KO_COUNT to ensure the most common KO_REASON_IDs appear first
)
-- Final SELECT to pull the top 5 KO reasons and their associated counts and percentages
SELECT 
    DKR.KO_REASON AS ko_reason,  -- KO_REASON from the dimension table
    KR.KO_COUNT AS ko_count,  -- Count of occurrences of the KO_REASON_ID in the sales fact table
    CAST(KR.PERCENTAGE AS DECIMAL(10,2)) AS percentage  -- Convert percentage to a decimal with 2 decimal places
FROM KO_REASONS KR
    -- Left join to bring in the KO_REASON description from the dimension table
    LEFT JOIN DMBI_FA.DIM_KO_REASON DKR
        ON KR.KO_REASON_ID = DKR.KO_REASON_ID
-- Filter to only include the top 5 KO_REASON_IDs based on count
WHERE DENSE_RANK_NUM <= 5
    )

  