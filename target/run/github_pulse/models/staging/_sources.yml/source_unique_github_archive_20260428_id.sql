
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from `github-pulse-jumpy`.`github_pulse_analytics_dev_dbt_test__audit`.`source_unique_github_archive_20260428_id`
    
      
    ) dbt_internal_test