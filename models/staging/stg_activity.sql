with ranked as (
    select
        activity_id,
        type as activity_type_code,
        assigned_to_user,
        deal_id,
        cast(done as boolean) as is_done,
        cast(due_to as timestamp) as due_at,
        row_number() over (
            partition by activity_id
            order by cast(due_to as timestamp) desc nulls last,
                     deal_id desc,
                     assigned_to_user desc,
                     type desc
        ) as rn
    from {{ source('postgres_public', 'activity') }}
)

select
    activity_id,
    activity_type_code,
    assigned_to_user,
    deal_id,
    is_done,
    due_at
from ranked
where rn = 1
