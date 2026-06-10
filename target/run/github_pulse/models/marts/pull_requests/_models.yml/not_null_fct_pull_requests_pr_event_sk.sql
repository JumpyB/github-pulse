
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select pr_event_sk
from `github-pulse-jumpy`.`github_pulse_analytics_dev_marts`.`fct_pull_requests`
where pr_event_sk is null



  
  
      
    ) dbt_internal_test