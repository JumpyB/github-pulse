{% snapshot snap_repos %}

{{
  config(
    target_schema='snapshots',
    unique_key='repo_id',
    strategy='timestamp',
    updated_at='dbt_snapshot_at'
  )
}}

with repos_union as (

    select repo_id, repo_name, org_login, event_at
    from {{ ref('stg_github__pull_request_events') }}
    union distinct
    select repo_id, repo_name, org_login, event_at
    from {{ ref('stg_github__watch_events') }}
    union distinct
    select repo_id, repo_name, org_login, event_at
    from {{ ref('stg_github__create_events') }}
    union distinct
    select repo_id, repo_name, org_login, event_at
    from {{ ref('stg_github__delete_events') }}

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

{% endsnapshot %}