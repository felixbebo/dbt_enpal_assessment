select distinct
    deal_id,
    cast(change_time as timestamp) as change_at,
    changed_field_key,
    new_value
from {{ source('postgres_public', 'deal_changes') }}
