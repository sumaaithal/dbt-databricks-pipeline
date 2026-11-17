--macro for slugifying text, dynamically creating column names based on the keywords in the extensions_keywords list
{% macro slugify(text) -%}
    {{ text | lower | replace(' ', '_') }}
{%- endmacro %}