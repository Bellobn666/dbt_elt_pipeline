{{ config(
    materialized='table',
    post_hook=[
        "ALTER TABLE {{ this }} MODIFY COLUMN lead_id VARCHAR(255);",
        "ALTER TABLE {{ this }} MODIFY COLUMN current_phase_id INT NULL;",
        "ALTER TABLE {{ this }} MODIFY COLUMN phase_pre_ko_id INT NULL;",
        "ALTER TABLE {{ this }} MODIFY COLUMN is_modified TINYINT NULL;",
        "ALTER TABLE {{ this }} MODIFY COLUMN zipcode VARCHAR(10) NULL;",
        "ALTER TABLE {{ this }} MODIFY COLUMN visiting_company VARCHAR(255) NULL;",
        "ALTER TABLE {{ this }} MODIFY COLUMN ko_reason_id INT NULL;",
        "ALTER TABLE {{ this }} MODIFY COLUMN n_panels INT NULL;",
        "ALTER TABLE {{ this }} MODIFY COLUMN customer_type_id INT NULL;",
        
        "ALTER TABLE {{ this }} ADD PRIMARY KEY (lead_id);",

        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_customer_type_id FOREIGN KEY (customer_type_id) REFERENCES dmbi_fa.dim_customer_type(customer_type_id) ON DELETE CASCADE;",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_finance_type_id FOREIGN KEY (finance_type_id) REFERENCES dmbi_fa.dim_finance_type(finance_type_id) ON DELETE CASCADE;",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_current_phase_id FOREIGN KEY (current_phase_id) REFERENCES dmbi_fa.dim_phases(phase_id) ON DELETE CASCADE;",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_phase_pre_ko_id FOREIGN KEY (phase_pre_ko_id) REFERENCES dmbi_fa.dim_phases(phase_id) ON DELETE CASCADE;",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_ko_reason_id FOREIGN KEY (ko_reason_id) REFERENCES dmbi_fa.dim_ko_reason(ko_reason_id) ON DELETE CASCADE;",

        "CREATE INDEX idx_fact_sales_zipcode ON {{ this }}(zipcode);",
        "CREATE INDEX idx_fact_sales_lead_id ON {{ this }}(lead_id);"
    ]
) }}

WITH transformed_sales AS (
    -- Perform initial transformations on raw sales data
    SELECT
        LEAD_ID,
        FINANCING_TYPE AS FINANCE_TYPE,
        CURRENT_PHASE,
        PHASE_PRE_KO,
        IS_MODIFIED,
        
        -- Convert date columns to standard DATE format
        CAST(OFFER_SENT_DATE AS DATE) AS OFFER_SENT_DATE,
        CAST(CONTRACT_1_DISPATCH_DATE AS DATE) AS CONTRACT_1_DISPATCH_DATE,
        CAST(CONTRACT_2_DISPATCH_DATE AS DATE) AS CONTRACT_2_DISPATCH_DATE,
        CAST(CONTRACT_1_SIGNATURE_DATE AS DATE) AS CONTRACT_1_SIGNATURE_DATE,
        CAST(CONTRACT_2_SIGNATURE_DATE AS DATE) AS CONTRACT_2_SIGNATURE_DATE,
        CAST(VISIT_DATE AS DATE) AS VISIT_DATE,
        CAST(TECHNICAL_REVIEW_DATE AS DATE) AS TECHNICAL_REVIEW_DATE,
        CAST(PROJECT_VALIDATION_DATE AS DATE) AS PROJECT_VALIDATION_DATE,
        CAST(SALE_DISMISSAL_DATE AS DATE) AS SALE_DISMISSAL_DATE,
        CAST(KO_DATE AS DATE) AS KO_DATE,

        -- Ensure ZIPCODE is not NULL by replacing NULL values with '0'
        COALESCE(zipcode, "0") AS ZIPCODE,
        
        VISITING_COMPANY,
        
        -- Handle NULL KO_REASON values by replacing them with "Unknown"
        COALESCE(KO_REASON, "Unknown") AS KO_REASON,
        
        -- Convert numeric values to appropriate data types
        CAST(INSTALLATION_PEAK_POWER_KW AS DOUBLE) AS INSTALLATION_PEAK_POWER_KW,
        CAST(INSTALLATION_PRICE AS DOUBLE) AS INSTALLATION_PRICE,
        
        N_PANELS,
        CUSOMER_TYPE AS CUSTOMER_TYPE
    FROM {{ ref("sales_raw") }}
),

sales AS (
    -- Enrich sales data with dimension table lookups
    SELECT
        ts.*,
        cust.customer_type_id AS CUSTOMER_TYPE_ID,
        fin.finance_type_id AS FINANCE_TYPE_ID,
        ko.ko_reason_id AS KO_REASON_ID,
        phases1.phase_id AS CURRENT_PHASE_ID,
        phases2.phase_id AS PHASE_PRE_KO_ID
    FROM transformed_sales ts
    LEFT JOIN dmbi_fa.dim_customer_type cust
        ON ts.customer_type = cust.customer_type
    LEFT JOIN dmbi_fa.dim_finance_type fin
        ON ts.finance_type = fin.finance_type
    LEFT JOIN dmbi_fa.dim_phases phases1
        ON ts.current_phase = phases1.phase_name
    LEFT JOIN dmbi_fa.dim_phases phases2
        ON ts.phase_pre_ko = phases2.phase_name
    LEFT JOIN dmbi_fa.dim_ko_reason ko
        ON ts.ko_reason = ko.ko_reason
)

-- Final selection of columns for the output table
SELECT 
    lead_id,
    customer_type_id,
    finance_type_id,
    ko_reason_id,
    current_phase_id,
    phase_pre_ko_id,
    is_modified,
    offer_sent_date,
    contract_1_dispatch_date,
    contract_2_dispatch_date,
    contract_1_signature_date,
    contract_2_signature_date,
    visit_date,
    technical_review_date,
    project_validation_date,
    sale_dismissal_date,
    ko_date,
    zipcode,
    visiting_company,
    installation_peak_power_kw,
    installation_price,
    n_panels
FROM sales
