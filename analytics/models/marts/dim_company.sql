WITH job_postings AS (
    SELECT * FROM {{ ref('fct_job_postings')}}
)