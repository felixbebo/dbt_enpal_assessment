select
    deal_id,
    valid_from,
    count(*) as row_count
from {{ ref('int_deal_hist') }}
group by 1, 2
having count(*) > 1
