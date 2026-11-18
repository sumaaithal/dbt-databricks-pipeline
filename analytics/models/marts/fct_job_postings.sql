--dim_company -> one to many  -> fact_job_postings -> one to many -> bridge job skills (job can have many skills )-> many to one -> dim skill

-- fetch the data from stg_job_postings view
WITH job_postings AS (
    SELECT * FROM {{ ref('stg_job_postings') }}
)

--select all the required columns for job_posting fact table
SELECT 
    job_id, 
    job_title,
    search_term,
    company_name,
    job_location,
    source_platform,
    job_schedule_type,
    job_work_from_home,
    search_date,
    salary_min,
    salary_max,
    job_salary_avg,
    salary_period,
    salary_currency,
    has_health_insurance,
    has_dental_insurance,
    has_paid_time_off,
    has_no_degree_mentioned
FROM job_postings
--handling the duplicates values
QUALIFY ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY search_date DESC) = 1