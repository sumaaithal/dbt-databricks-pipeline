-- select all columns from the raw_job_skills table

WITH source AS (
    SELECT * FROM {{ source('jobs', 'raw_job_skills') }}    
),

--clean the skill_keyword column by trimming whitespace
cleaned AS (
    SELECT 
        job_id,
        skill_id,
        TRIM(skill_keyword) AS skill_keyword
    FROM source
)

SELECT * FROM cleaned