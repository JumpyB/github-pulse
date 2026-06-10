
  
    

    create or replace table `github-pulse-jumpy`.`github_pulse_analytics_dev_marts`.`fct_pull_requests`
      
    
    

    
    OPTIONS()
    as (
      

with pr_events as (

    select * from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__pull_request_events`

),

dim_repo as (

    select repo_id, repo_sk, repo_name, repo_owner, repo_slug, repo_url
    from `github-pulse-jumpy`.`github_pulse_analytics_dev_core`.`dim_repo`
    where is_current

),

dim_actor as (

    select actor_id, actor_login, profile_url
    from `github-pulse-jumpy`.`github_pulse_analytics_dev_core`.`dim_actor`

),

dim_date as (

    select date_id, calendar_date
    from `github-pulse-jumpy`.`github_pulse_analytics_dev_core`.`dim_date`

),

final as (

    select
        -- surrogate key
        to_hex(md5(cast(coalesce(cast(pr.event_id as string), '_dbt_utils_surrogate_key_null_') as string)))     as pr_event_sk,

        -- foreign keys
        pr.event_id,
        pr.pr_id,
        pr.pr_number,
        coalesce(r.repo_sk, 'unknown')                              as repo_sk,
        coalesce(
            d.date_id,
            cast(format_date('%Y%m%d', date(pr.event_at)) as int64)
        )                                                           as date_id,

        -- actor info (denormalized for query convenience)
        pr.actor_id,
        coalesce(a.actor_login, pr.actor_login)                     as actor_login,

        -- repo info (denormalized)
        coalesce(r.repo_name, pr.repo_name)                         as repo_name,
        r.repo_owner,
        r.repo_slug,

        -- event details
        pr.pr_action,
        pr.is_opened,
        pr.is_closed,
        pr.is_merged,
        pr.is_reopened,
        pr.is_labeled,

        -- timestamp
        pr.event_at

    from pr_events pr
    left join dim_repo   r on pr.repo_id  = r.repo_id
    left join dim_actor  a on pr.actor_id = a.actor_id
    left join dim_date   d on date(pr.event_at) = d.calendar_date

)

select * from final
    );
  