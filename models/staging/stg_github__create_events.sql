{{
  config(
    materialized='view'
  )
}}

with source as (

    select *
    from {{ source('github_archive', var('default_event_date') | replace('-', '')) }}
    where type = 'CreateEvent'

),

deduplicated as (
    select *
    from source
    qualify row_number() over (partition by id order by created_at) = 1
),

renamed as (

    select
        id                                              as event_id,

        actor.id                                        as actor_id,
        actor.login                                     as actor_login,

        repo.id                                         as repo_id,
        repo.name                                       as repo_name,

        org.id                                          as org_id,
        org.login                                       as org_login,

        -- what was created: 'branch', 'tag', or 'repository'
        json_value(payload, '$.ref_type')               as ref_type,
        -- the name of the branch / tag (null for repository creation)
        json_value(payload, '$.ref')                    as ref_name,
        -- description of the repo when ref_type = 'repository'
        json_value(payload, '$.description')            as description,
        -- master_branch — typically only set for repo creation
        json_value(payload, '$.master_branch')          as master_branch,

        created_at                                      as event_at

    from deduplicated

)

select * from renamed