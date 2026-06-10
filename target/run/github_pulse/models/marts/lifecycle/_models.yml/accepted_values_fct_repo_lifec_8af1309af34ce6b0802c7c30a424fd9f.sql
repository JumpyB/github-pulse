
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        lifecycle_action as value_field,
        count(*) as n_records

    from `github-pulse-jumpy`.`github_pulse_analytics_dev_marts`.`fct_repo_lifecycle`
    group by lifecycle_action

)

select *
from all_values
where value_field not in (
    'created','deleted'
)



  
  
      
    ) dbt_internal_test