-- the data is being sourced from the stg_job_skills model, which is a staging model that cleans and standardizes 
-- the job skills data. The intermediate model aggregates the data to provide insights into the number of job postings 
-- associated with each skill.
WITH job_skills AS (
    SELECT * FROM {{ ref('stg_job_skills')}}
    )

-- get the count of distinct job postings for each skill_id (aggregation layer)
SELECT 
    skill_id,
    COUNT(DISTINCT job_id) AS postings_with_skill
FROM job_skills
GROUP BY skill_id