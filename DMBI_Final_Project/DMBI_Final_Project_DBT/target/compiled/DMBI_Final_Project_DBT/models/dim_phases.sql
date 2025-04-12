

WITH distinct_phase_types AS (
    -- Select distinct values from 'phase_pre_ko' column in 'sales_raw'
    SELECT phase_pre_ko AS phase_name
    FROM `dmbi_fa`.`sales_raw`
    UNION
    -- Select distinct values from 'current_phase' column in 'sales_raw'
    SELECT current_phase AS phase_name
    FROM `dmbi_fa`.`sales_raw`
    -- Ensure ordered output for consistency
    ORDER BY phase_name

)
-- Assign a unique ID to each phase name using ROW_NUMBER()
SELECT
    ROW_NUMBER() OVER (ORDER BY phase_name) AS phase_id,
    phase_name
FROM distinct_phase_types