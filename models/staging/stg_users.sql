select
    id as user_id,
    name as user_name,
    email,
    cast(modified as timestamp) as modified_at
from {{ source('postgres_public', 'users') }}
