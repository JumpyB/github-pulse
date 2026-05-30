
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from `github-pulse-jumpy`.`github_pulse_analytics_dev_dbt_test__audit`.`not_null_stg_github__pull_request_events_pr_action`
    
      
    ) dbt_internal_test