{% set extensions_keywords = 
    [
        "No degree mentioned", 
        "Paid time off", 
        "Dental insurance", 
        "Health insurance"] 
%}

--select only the rows where the error is not true
WITH source AS (
    SELECT * 
    FROM {{ source('jobs', 'raw_job_postings') }}
    WHERE error IS NOT TRUE

),

parsed AS (
    SELECT 
        *,
        FROM_JSON(job_extensions_raw, 'ARRAY<STRING>') AS job_extensions
    FROM source
),

--clean the data by removing any leading or trailing whitespace from the company name and 
--removing the "via" prefix from the job_via column.

cleaned (
    SELECT 
        job_id,
        job_title,
        TRIM(company_name) as company_name,
        job_location,
        REGEXP_REPLACE(job_via, '^via ', '') as job_via,
        job_posted_at,
        job_salary,
        job_schedule_type,
        job_work_from_home,
        --job_extensions_raw,
        search_time AS searched_at,
        search_date,
        search_term,
        search_location,
        {% for keyword in extensions_keywords -%}
        ARRAY_CONTAINS(
            --FROM_JSON(job_extensions_raw, 'ARRAY<STRING>'),'{{ keyword }}'
            job_extensions,'{{ keyword }}'
            ) AS has_{{ keyword | lower | replace(' ', '_') }}
            {{- ","  if not loop.last }}
        {% endfor -%}
    FROM parsed
)

--select all the rows from cleaned data
SELECT * FROM cleaned