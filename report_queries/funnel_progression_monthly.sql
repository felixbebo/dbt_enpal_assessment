select
    month,
    sum(case when funnel_step = 'Step 1: Lead Generation' then deals_count else 0 end) as step_1_lead_generation,
    sum(case when funnel_step = 'Step 2: Qualified Lead' then deals_count else 0 end) as step_2_qualified_lead,
    sum(case when funnel_step = 'Step 2.1: Sales Call 1' then deals_count else 0 end) as step_2_1_sales_call_1,
    sum(case when funnel_step = 'Step 3: Needs Assessment' then deals_count else 0 end) as step_3_needs_assessment,
    sum(case when funnel_step = 'Step 3.1: Sales Call 2' then deals_count else 0 end) as step_3_1_sales_call_2,
    sum(case when funnel_step = 'Step 4: Proposal/Quote Preparation' then deals_count else 0 end) as step_4_proposal_quote_preparation,
    sum(case when funnel_step = 'Step 5: Negotiation' then deals_count else 0 end) as step_5_negotiation,
    sum(case when funnel_step = 'Step 6: Closing' then deals_count else 0 end) as step_6_closing,
    sum(case when funnel_step = 'Step 7: Implementation/Onboarding' then deals_count else 0 end) as step_7_implementation_onboarding,
    sum(case when funnel_step = 'Step 8: Follow-up/Customer Success' then deals_count else 0 end) as step_8_follow_up_customer_success,
    sum(case when funnel_step = 'Step 9: Renewal/Expansion' then deals_count else 0 end) as step_9_renewal_expansion
from rep_sales_funnel_monthly
where kpi_name = 'deals_entered_stage'
group by 1
order by 1;
