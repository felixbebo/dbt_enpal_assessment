{{ config(materialized='view') }}

with lost_reason_field as (
    select
        field_value_options
    from {{ ref('stg_fields') }}
    where field_key = 'lost_reason'
)

select distinct
    cast(option->>'id' as integer) as lost_reason_id,
    option->>'label' as lost_reason_name
from lost_reason_field,
     jsonb_array_elements(field_value_options) as option
