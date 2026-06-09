

with actors_union as (

    select actor_id, actor_login from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__pull_request_events`
    union distinct
    select actor_id, actor_login from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__watch_events`
    union distinct
    select actor_id, actor_login from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__create_events`
    union distinct
    select actor_id, actor_login from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__delete_events`

),

deduped as (

    select
        actor_id,
        actor_login,
        row_number() over (
            partition by actor_id
            order by actor_login
        ) as rn
    from actors_union

),

final as (

    select
        actor_id,
        actor_login,
        concat('https://github.com/', actor_login)  as profile_url,
        current_timestamp()                         as dbt_updated_at
    from deduped
    where rn = 1

)

select * from final