{{
  config(
    materialized='view'
  )
}}

with source as (

    select *
    from {{ source('github_archive', '20260428') }}
    where type = 'DeleteEvent'

),

deduplicated as (

    select *
    from source
    qualify row_number() over (
        partition by id
        order by created_at
    ) = 1

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

        -- what was deleted: 'branch' or 'tag' (repos don't generate DeleteEvent)
        json_value(payload, '$.ref_type')               as ref_type,
        json_value(payload, '$.ref')                    as ref_name,

        created_at                                      as event_at

    from deduplicated

)

select * from renamed