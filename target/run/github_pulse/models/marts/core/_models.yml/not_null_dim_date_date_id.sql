
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select date_id
from `github-pulse-jumpy`.`github_pulse_analytics_dev_core`.`dim_date`
where date_id is null



  
  
      
    ) dbt_internal_test