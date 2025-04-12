
  
    

  create  table
    `dmbi_fa`.`kpi_leads_province_analysis__dbt_tmp`
    
    
      as
    
    (
      

-- First, we calculate the number of leads, total peak power, and total installation price per ZIPCODE
WITH LEADS_COUNT AS (
    SELECT 
        ZIPCODE,  -- The ZIPCODE for each group of leads
        COUNT(LEAD_ID) AS LEADS_COUNT,  -- Total number of leads for the given ZIPCODE
        SUM(INSTALLATION_PEAK_POWER_KW) AS INSTALLATION_PEAK_POWER,  -- Total installation peak power for the given ZIPCODE
        SUM(INSTALLATION_PRICE) AS INSTALLATION_PRICE  -- Total installation price for the given ZIPCODE
    FROM DMBI_FA.FACT_SALES
    GROUP BY ZIPCODE
    HAVING COUNT(LEAD_ID) > 5  -- We only want ZIPCODEs with more than 5 leads
)

-- Then, we aggregate the results by province
SELECT 
    ZC.PROVINCE AS province,  -- The province associated with each ZIPCODE
    SUM(LC.LEADS_COUNT) AS num_leads_per_province,  -- The total number of leads per province
    ROUND(SUM(LC.INSTALLATION_PEAK_POWER) / SUM(LC.LEADS_COUNT), 2) AS avg_peal_power,  -- Average peak power per lead in the province
    ROUND(SUM(LC.INSTALLATION_PRICE) / SUM(LC.LEADS_COUNT), 2) AS avg_installation_price  -- Average installation price per lead in the province
FROM LEADS_COUNT LC
    -- Joining LEADS_COUNT with the DIM_ZIPCODE table to get the province information
    JOIN DMBI_FA.DIM_ZIPCODE ZC
        ON LC.ZIPCODE = ZC.ZIPCODE
GROUP BY ZC.province  -- Group by province to calculate the aggregates at the provincial level
ORDER BY num_leads_per_province DESC  -- Sorting the results by the number of leads in descending order
    )

  