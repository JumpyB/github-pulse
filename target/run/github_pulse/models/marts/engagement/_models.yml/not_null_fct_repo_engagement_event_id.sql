
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select event_id
from `github-pulse-jumpy`.`github_pulse_analytics_dev_marts`.`fct_repo_engagement`
where event_id is null



  
  
      
    ) dbt_internal_test