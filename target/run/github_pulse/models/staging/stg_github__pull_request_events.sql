

  create or replace view `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__pull_request_events`
  OPTIONS()
  as 

with source as (

    select *
    from `githubarchive`.`day`.`20260428`
    where type = 'PullRequestEvent'

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
        -- identifiers
        id                                                                  as event_id,
        cast(json_value(payload, '$.pull_request.id') as int64)             as pr_id,
        cast(json_value(payload, '$.number') as int64)                      as pr_number,

        -- actor (the user performing the action)
        actor.id                                                            as actor_id,
        actor.login                                                         as actor_login,

        -- repo
        repo.id                                                             as repo_id,
        repo.name                                                           as repo_name,

        -- org (nullable — only set when repo is in an org)
        org.id                                                              as org_id,
        org.login                                                           as org_login,

        -- action: what happened to the PR
        -- (opened / closed / merged / reopened / labeled / assigned / etc.)
        json_value(payload, '$.action')                                     as pr_action,

        -- convenience flags derived from action
        case when json_value(payload, '$.action') = 'opened'   then true else false end as is_opened,
        case when json_value(payload, '$.action') = 'closed'   then true else false end as is_closed,
        case when json_value(payload, '$.action') = 'merged'   then true else false end as is_merged,
        case when json_value(payload, '$.action') = 'reopened' then true else false end as is_reopened,
        case when json_value(payload, '$.action') = 'labeled'  then true else false end as is_labeled,

        -- timestamp
        created_at                                                          as event_at

    from deduplicated

)

select * from renamed;

