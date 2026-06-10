
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select event_at
from `github-pulse-jumpy`.`github_pulse_analytics_dev_marts`.`fct_repo_lifecycle`
where event_at is null



  
  
      
    ) dbt_internal_test