

  create or replace view `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__watch_events`
  OPTIONS()
  as 

with source as (

    select *
    from `githubarchive`.`day`.`20260428`
    where type = 'WatchEvent'

),

renamed as (

    select
        id                  as event_id,

        actor.id            as actor_id,
        actor.login         as actor_login,

        repo.id             as repo_id,
        repo.name           as repo_name,

        org.id              as org_id,
        org.login           as org_login,

        -- WatchEvent always means "started watching" (= starred)
        -- The `action` field exists but is always 'started'
        json_value(payload, '$.action')   as engagement_action,

        created_at          as event_at

    from source

)

select * from renamed;

