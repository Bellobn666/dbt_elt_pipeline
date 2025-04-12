{{ config(
    materialized='table',
    post_hook=[
        "ALTER TABLE {{ this }} MODIFY COLUMN autonomous_community VARCHAR(255) NOT NULL;",
        "ALTER TABLE {{ this }} MODIFY COLUMN autonomous_community_nk VARCHAR(255) NOT NULL;",
        "ALTER TABLE {{ this }} MODIFY COLUMN province VARCHAR(255) NOT NULL;",
        "ALTER TABLE {{ this }} MODIFY COLUMN zipcode VARCHAR(10) NOT NULL;",
        "ALTER TABLE {{ this }} ADD PRIMARY KEY (zipcode);"
    ]
) }}

-- Select distinct zip codes along with relevant geographical data
SELECT
    zipcode,  -- Ensure proper data type handling if necessary
    COALESCE(ZC_LATITUDE, 0) AS zc_latitude,  -- Replace NULL latitudes with 0
    COALESCE(ZC_LONGITUDE, 0) AS zc_longitude,  -- Replace NULL longitudes with 0
    COALESCE(AUTONOMOUS_COMMUNITY, 'N/A') AS autonomous_community,  -- Default 'N/A' for missing community data
    COALESCE(AUTONOMOUS_COMMUNITY_NK, 'N/A') AS autonomous_community_nk,  -- Default 'N/A' for missing community NK
    COALESCE(PROVINCE, 'N/A') AS province  -- Default 'N/A' for missing province data
FROM {{ ref('zipcode_raw') }}
