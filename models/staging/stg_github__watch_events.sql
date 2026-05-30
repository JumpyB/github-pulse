{{
  config(
    materialized='view'
  )
}}

with source as (

    select *
    from {{ source('github_archive', '20260428') }}
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

select * from renamed