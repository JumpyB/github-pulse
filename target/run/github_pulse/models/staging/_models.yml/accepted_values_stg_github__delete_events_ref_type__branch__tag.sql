
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from `github-pulse-jumpy`.`github_pulse_analytics_dev_dbt_test__audit`.`accepted_values_stg_github__delete_events_ref_type__branch__tag`
    
      
    ) dbt_internal_test