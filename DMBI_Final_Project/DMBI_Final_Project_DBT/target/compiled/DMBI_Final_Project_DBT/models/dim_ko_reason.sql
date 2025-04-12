

WITH distinct_ko_reason_types AS (
    -- Select distinct KO reasons from 'sales_raw', replacing NULL values with 'Unknown'
    SELECT DISTINCT COALESCE(ko_reason, "Unknown") AS ko_reason
    FROM `dmbi_fa`.`sales_raw`
)
-- Assign a unique ID to each KO reason using ROW_NUMBER()
SELECT
    ROW_NUMBER() OVER (ORDER BY ko_reason) AS ko_reason_id,
    ko_reason
FROM distinct_ko_reason_types