{{ config(materialized='ephemeral') }}

-- It selects the most recent job posting for each job_id up to the specified 'as_of' date.
SELECT 
   *
FROM {{ ref('stg_job_postings') }}
 -- run_started at is a default value for the 'as_of' variable if not provided
WHERE search_date <= CAST('{{ var('as_of', run_started_at)}}' AS DATE)
QUALIFY ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY searched_at DESC) = 1


-- old query used to build a final logic

-- SELECT 
--     job_id,
--     job_title,
--     company_name,
--     salary_min,
--     salary_max,
--     searched_at
-- FROM {{ ref('stg_job_postings') }}
-- WHERE job_title = 'Senior Data Engineer'
--     AND company_name = 'Fraser Health'
--     -- run_started at is a default value for the 'as_of' variable if not provided
--     AND search_date <= CAST('{{ var('as_of', run_started_at)}}' AS DATE)
-- QUALIFY ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY searched_at DESC) = 1
