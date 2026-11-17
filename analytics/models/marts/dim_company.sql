-- fetch data from fact tables
WITH job_postings AS (
    SELECT * FROM {{ ref('fct_job_postings')}}
)

-- calculate job postings count and average yearly salary in USD per company
SELECT 
    company_name,
    COUNT(*) AS job_postings_count,
    AVG(CASE 
            WHEN salary_currency = 'USD' and salary_period = 'year' 
            THEN job_salary_avg
        END) AS salary_avg_year
FROM job_postings
WHERE company_name IS NOT NULL
GROUP BY company_name