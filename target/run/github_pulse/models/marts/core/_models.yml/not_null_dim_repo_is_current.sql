
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_current
from `github-pulse-jumpy`.`github_pulse_analytics_dev_core`.`dim_repo`
where is_current is null



  
  
      
    ) dbt_internal_test