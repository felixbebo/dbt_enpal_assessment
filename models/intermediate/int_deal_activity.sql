select
    a.activity_id,
    a.deal_id,
    a.activity_type_code,
    t.activity_type_name,
    a.assigned_to_user,
    a.due_at,
    a.is_done
from {{ ref('stg_activity') }} a
left join {{ ref('stg_activity_types') }} t
    on a.activity_type_code = t.activity_type_code
