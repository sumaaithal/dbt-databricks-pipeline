-- tests whether the specified column contains any negative values
{% test not_negative(model, column_name) %}
    select *
    from {{ model }}
    where {{ column_name }} < 0
{% endtest %}