
      
  
    

    create or replace table `github-pulse-jumpy`.`snapshots`.`snap_repos`
      
    
    

    
    OPTIONS()
    as (
      
    

    select *,
        to_hex(md5(concat(coalesce(cast(repo_id as string), ''), '|',coalesce(cast(dbt_snapshot_at as string), '')))) as dbt_scd_id,
        dbt_snapshot_at as dbt_updated_at,
        dbt_snapshot_at as dbt_valid_from,
        
  
  coalesce(nullif(dbt_snapshot_at, dbt_snapshot_at), null)
  as dbt_valid_to
from (
        



with repos_union as (

    select repo_id, repo_name, org_login, event_at
    from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__pull_request_events`
    union distinct
    select repo_id, repo_name, org_login, event_at
    from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__watch_events`
    union distinct
    select repo_id, repo_name, org_login, event_at
    from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__create_events`
    union distinct
    select repo_id, repo_name, org_login, event_at
    from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__delete_events`

),

latest_per_repo as (

    select
        repo_id,
        repo_name,
        org_login,
        max(event_at) as dbt_snapshot_at

    from repos_union
    group by repo_id, repo_name, org_login

)

select * from latest_per_repo

    ) sbq



    );
  
  