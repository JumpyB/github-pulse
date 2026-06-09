
    
    

with dbt_test__target as (

  select repo_sk as unique_field
  from `github-pulse-jumpy`.`github_pulse_analytics_dev_core`.`dim_repo`
  where repo_sk is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


