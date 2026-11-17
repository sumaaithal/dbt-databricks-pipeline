-- macrcos to parse salary from job_salary field 
-- logic: takes part as input, either 'min' or 'max', and returns the corresponding salary value after parsing the job_salary field. 

{% macro parse_salary(part) -%}

    {%- if part == 'min' -%}
    --If part is 'min', the segment is the first part of the job_salary field before the en-dash. 
        {%- set segment = "SPLIT(job_salary, '–')[0]" -%}

    {%- else -%}
    --If part is 'max', the segment is the last part of the job_salary field after the en-dash.
        {%- set segment = "ELEMENT_AT(SPLIT(job_salary, '–'), -1)" -%}

    {%- endif -%}

    -- inspects either of segment and extracts the numeric value, removes any commas, and converts it to a decimal.
    -- It then checks for a K or M suffix and multiplies the value accordingly to get the final salary value. 
    -- If no suffix is found, it returns the value as is.
    
    TRY_CAST(REPLACE(REGEXP_EXTRACT( {{segment}}, '([0-9][0-9,.]*)', 1), ',', '') AS DECIMAL(15, 2))
            * CASE UPPER(REGEXP_EXTRACT( {{segment}}, '[0-9][0-9,.]*([KkMm])', 1))
                WHEN 'K' THEN 1000
                WHEN 'M' THEN 1000000
                ELSE 1
              END

{%- endmacro %}
