
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select engagement_sk
from `github-pulse-jumpy`.`github_pulse_analytics_dev_marts`.`fct_repo_engagement`
where engagement_sk is null



  
  
      
    ) dbt_internal_test