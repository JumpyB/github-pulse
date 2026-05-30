
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from `github-pulse-jumpy`.`github_pulse_analytics_dev_dbt_test__audit`.`accepted_values_stg_github__pu_2603d26f439f949adb23309824f94e50`
    
      
    ) dbt_internal_test