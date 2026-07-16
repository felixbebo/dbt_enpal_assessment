with deal_created as (
    select
        date_trunc('month', created_at)::date as month,
        'deals_created' as kpi_name,
        'Step 0: Deal Created' as funnel_step,
        count(distinct deal_id) as deals_count
    from {{ ref('int_deal_latest') }}
    group by 1, 2, 3
),

hist as (
    select
        deal_id,
        stage_id,
        valid_from,
        lag(stage_id) over (
            partition by deal_id
            order by valid_from
        ) as prev_stage_id
    from {{ ref('int_deal_hist') }}
),

deal_stage_entries as (
    select
        date_trunc('month', valid_from)::date as month,
        'deals_entered_stage' as kpi_name,
        case
            when h.stage_id = 1 then 'Step 1: Lead Generation'
            when h.stage_id = 2 then 'Step 2: Qualified Lead'
            when h.stage_id = 3 then 'Step 3: Needs Assessment'
            when h.stage_id = 4 then 'Step 4: Proposal/Quote Preparation'
            when h.stage_id = 5 then 'Step 5: Negotiation'
            when h.stage_id = 6 then 'Step 6: Closing'
            when h.stage_id = 7 then 'Step 7: Implementation/Onboarding'
            when h.stage_id = 8 then 'Step 8: Follow-up/Customer Success'
            when h.stage_id = 9 then 'Step 9: Renewal/Expansion'
            else coalesce(h.stage_id::text || ' - ' || s.stage_name, h.stage_id::text, s.stage_name)
        end as funnel_step,
        count(distinct deal_id) as deals_count
    from hist h
    left join {{ ref('stg_stages') }} s
        on h.stage_id = s.stage_id
    where h.stage_id is distinct from h.prev_stage_id
    group by 1, 2, 3
),

activity_steps as (
    select
        date_trunc('month', due_at)::date as month,
        'deals_entered_stage' as kpi_name,
        case
            when activity_type_code = 'meeting' then 'Step 2.1: Sales Call 1'
            when activity_type_code = 'sc_2' then 'Step 3.1: Sales Call 2'
        end as funnel_step,
        count(distinct deal_id) as deals_count
    from {{ ref('int_deal_activity') }}
    where activity_type_code in ('meeting', 'sc_2')
    group by 1, 2, 3
)

select * from deal_created
union all
select * from deal_stage_entries
union all
select * from activity_steps
