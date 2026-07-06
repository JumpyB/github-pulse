{{
    config(
        materialized='table'
    )
}}

select
    calendar_date as date_day
from {{ ref('dim_date') }}