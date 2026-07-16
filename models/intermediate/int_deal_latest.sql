{{ config(materialized='view') }}

select
    deal_id,
    created_at,
    owner_user_id,
    stage_id,
    lost_reason_id,
    valid_from
from {{ ref('int_deal_hist') }}
where is_latest = true
