
    
    

with dbt_test__target as (

  select event_id as unique_field
  from `github-pulse-jumpy`.`github_pulse_analytics_dev_marts`.`fct_pull_requests`
  where event_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


