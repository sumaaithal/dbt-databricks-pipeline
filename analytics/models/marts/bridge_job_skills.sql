-- create CTEs for job skills and job postings
WITH job_skills AS (
    SELECT * FROM {{ ref('stg_job_skills') }}
),

job_postings AS (
    SELECT * FROM {{ ref('fct_job_postings') }}
)

-- select job skills that have corresponding job postings
SELECT 
    job_id,
    skill_id,
    skill_keyword
FROM job_skills
JOIN job_postings USING(job_id)