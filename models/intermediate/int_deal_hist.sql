{{ config(
    materialized='incremental',
    unique_key='deal_id',
    incremental_strategy='delete+insert'
) }}

with deal_scope as (
    select distinct
        deal_id
    from {{ ref('stg_deal_changes') }}
    {% if is_incremental() %}
    where change_at > (
        select coalesce(max(valid_from), timestamp '1900-01-01')
        from {{ this }}
    )
    {% endif %}
),

events as (
    select
        deal_id,
        change_at,
        changed_field_key,
        new_value,
        row_number() over (
            partition by deal_id
            order by change_at, changed_field_key, new_value
        ) as event_order,
        sum(case when changed_field_key = 'add_time' then 1 else 0 end) over (
            partition by deal_id
            order by change_at, changed_field_key, new_value
        ) as created_at_grp,
        sum(case when changed_field_key = 'user_id' then 1 else 0 end) over (
            partition by deal_id
            order by change_at, changed_field_key, new_value
        ) as owner_grp,
        sum(case when changed_field_key = 'stage_id' then 1 else 0 end) over (
            partition by deal_id
            order by change_at, changed_field_key, new_value
        ) as stage_grp,
        sum(case when changed_field_key = 'lost_reason' then 1 else 0 end) over (
            partition by deal_id
            order by change_at, changed_field_key, new_value
        ) as lost_reason_grp
    from {{ ref('stg_deal_changes') }}
    where deal_id in (select deal_id from deal_scope)
),

state as (
    select
        deal_id,
        change_at,
        event_order,
        changed_field_key,
        first_value(case when changed_field_key = 'add_time' then cast(new_value as timestamp) end) over (
            partition by deal_id, created_at_grp
            order by event_order
        ) as created_at,
        first_value(case when changed_field_key = 'user_id' then cast(new_value as integer) end) over (
            partition by deal_id, owner_grp
            order by event_order
        ) as owner_user_id,
        first_value(case when changed_field_key = 'stage_id' then cast(new_value as integer) end) over (
            partition by deal_id, stage_grp
            order by event_order
        ) as stage_id,
        first_value(case when changed_field_key = 'lost_reason' then cast(new_value as integer) end) over (
            partition by deal_id, lost_reason_grp
            order by event_order
        ) as lost_reason_id
    from events
)

select
    deal_id,
    created_at,
    owner_user_id,
    stage_id,
    lost_reason_id,
    change_at as valid_from,
    lead(change_at) over (
        partition by deal_id
        order by event_order
    ) as valid_to,
    case
        when lead(change_at) over (
            partition by deal_id
            order by event_order
        ) is null then true
        else false
    end as is_latest
from state
