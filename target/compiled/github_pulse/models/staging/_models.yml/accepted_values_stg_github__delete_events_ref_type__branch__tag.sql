
    
    

with all_values as (

    select
        ref_type as value_field,
        count(*) as n_records

    from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__delete_events`
    group by ref_type

)

select *
from all_values
where value_field not in (
    'branch','tag'
)


