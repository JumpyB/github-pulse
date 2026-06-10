
  
    

    create or replace table `github-pulse-jumpy`.`github_pulse_analytics_dev_marts`.`fct_repo_lifecycle`
      
    
    

    
    OPTIONS()
    as (
      

with create_events as (

    select
        event_id,
        actor_id,
        actor_login,
        repo_id,
        repo_name,
        org_id,
        org_login,
        ref_type,
        ref_name,
        event_at,
        'created'   as lifecycle_action
    from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__create_events`

),

delete_events as (

    select
        event_id,
        actor_id,
        actor_login,
        repo_id,
        repo_name,
        org_id,
        org_login,
        ref_type,
        ref_name,
        event_at,
        'deleted'   as lifecycle_action
    from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__delete_events`

),

unioned as (

    select * from create_events
    union all
    select * from delete_events

),

dim_repo as (

    select repo_id, repo_sk, repo_name, repo_owner, repo_slug
    from `github-pulse-jumpy`.`github_pulse_analytics_dev_core`.`dim_repo`
    where is_current

),

dim_date as (

    select date_id, calendar_date
    from `github-pulse-jumpy`.`github_pulse_analytics_dev_core`.`dim_date`

),

final as (

    select
        to_hex(md5(cast(coalesce(cast(u.event_id as string), '_dbt_utils_surrogate_key_null_') as string)))      as lifecycle_sk,

        u.event_id,
        coalesce(r.repo_sk, 'unknown')                              as repo_sk,
        coalesce(
            d.date_id,
            cast(format_date('%Y%m%d', date(u.event_at)) as int64)
        )                                                           as date_id,

        u.actor_id,
        u.actor_login,

        -- repo (denormalized)
        coalesce(r.repo_name, u.repo_name)                          as repo_name,
        r.repo_owner,
        r.repo_slug,

        -- lifecycle details
        u.lifecycle_action,     -- 'created' or 'deleted'
        u.ref_type,             -- 'branch', 'tag', or 'repository'
        u.ref_name,

        -- derived
        u.ref_type = 'branch'   as is_branch_event,
        u.ref_type = 'tag'      as is_tag_event,

        u.event_at

    from unioned u
    left join dim_repo  r on u.repo_id = r.repo_id
    left join dim_date  d on date(u.event_at) = d.calendar_date

)

select * from final
    );
  