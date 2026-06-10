
      
  
    

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

-- latest_per_repo as (

--     select
--         repo_id,
--         repo_name,
--         org_login,
--         max(event_at) as dbt_snapshot_at

--     from repos_union
--     group by repo_id, repo_name, org_login

-- )

-- 同一个 repo_id 可能在不同 staging model 里有不同的 org_login, group by repo_id, repo_name, org_login 
-- 把这两行当成两个不同的分组 → 产生 2 行输出 → snapshot 建了 2 条记录 → dim_repo join 时 1 变 2。
-- 只按 repo_id 分组后，SQL 要从多行里取一个值给 repo_name 和 org_login。
-- MAX(org_login) → facebook ✅ (NULL 被忽略了) 这正好解决了我们的问题 — 
-- 不同 staging model 里同一个 repo 的 org_login 有的是 NULL 有的有值，MAX() 自动帮我们选有值的那个。

latest_per_repo as (

    select
        repo_id,
        max(repo_name)          as repo_name,
        max(org_login)          as org_login,
        max(event_at)           as dbt_snapshot_at
    from repos_union
    group by repo_id

)

select * from latest_per_repo

    ) sbq



    );
  
  