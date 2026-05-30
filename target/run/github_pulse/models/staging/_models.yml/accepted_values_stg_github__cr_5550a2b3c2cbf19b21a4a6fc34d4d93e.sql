
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from `github-pulse-jumpy`.`github_pulse_analytics_dev_dbt_test__audit`.`accepted_values_stg_github__cr_5550a2b3c2cbf19b21a4a6fc34d4d93e`
    
      
    ) dbt_internal_test