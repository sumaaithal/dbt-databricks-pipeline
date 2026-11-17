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

cleaned AS (
    SELECT 
        job_id,
        job_title,
        TRIM(company_name) as company_name,
        job_location,
        REGEXP_REPLACE(job_via, '^via ', '') as job_via,
        job_posted_at,
        job_schedule_type,
        job_work_from_home,
        --job_extensions_raw,
        search_time AS searched_at,
        search_date,
        search_term,
        search_location,
        job_salary,

        -- START OF SALARY PARSING--

         -- lower bound: the number before the en-dash, times its K or M suffix
        {{ parse_salary('min') }} AS salary_min,

        -- upper bound: the same parse on the LAST segment, so a single value is its own range
        {{ parse_salary('max') }} AS salary_max,

        -- avg value: the average of the two bounds, if both are present, else the one that is present
        ({{ parse_salary('min') }} + {{ parse_salary('max') }}) / 2 AS job_salary_avg,

        -- pay period, read off the end of the text: 'a year', 'an hour'
        NULLIF(REGEXP_EXTRACT(job_salary, 'an? (year|hour|month|day|week)$', 1), '') AS salary_period,
        -- currency marker; a salaried row with no marker is stamped USD on purpose
        CASE
            WHEN job_salary IS NOT NULL
            THEN COALESCE(NULLIF(TRIM(REGEXP_EXTRACT(job_salary, '^([^0-9]+)', 1)), ''), 'USD')
        END AS salary_currency,

        --END OF SALARY PARSING--

        {% for keyword in extensions_keywords -%}
        ARRAY_CONTAINS(
            --FROM_JSON(job_extensions_raw, 'ARRAY<STRING>'),'{{ keyword }}'
            job_extensions,'{{ keyword }}'
            ) 
        --AS has_{{ keyword | lower | replace(' ', '_') }}
        AS has_{{ slugify(keyword) }}
            {{- ","  if not loop.last }}
        {% endfor -%}
    FROM parsed
)

--select all the rows from cleaned data
SELECT * FROM cleaned