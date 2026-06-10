
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select lifecycle_action
from `github-pulse-jumpy`.`github_pulse_analytics_dev_marts`.`fct_repo_lifecycle`
where lifecycle_action is null



  
  
      
    ) dbt_internal_test