{{
  config(
    materialized='table'
  )
}}

with watch_events as (

    select * from {{ ref('stg_github__watch_events') }}

),

dim_repo as (

    select repo_id, repo_sk, repo_name, repo_owner, repo_slug, repo_url
    from {{ ref('dim_repo') }}
    where is_current

),

dim_actor as (

    select actor_id, actor_login
    from {{ ref('dim_actor') }}

),

dim_date as (

    select date_id, calendar_date
    from {{ ref('dim_date') }}

),

final as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['w.event_id']) }}      as engagement_sk,

        -- foreign keys
        w.event_id,
        coalesce(r.repo_sk, 'unknown')                              as repo_sk,
        coalesce(
            d.date_id,
            cast(format_date('%Y%m%d', date(w.event_at)) as int64)
        )                                                           as date_id,

        -- actor
        w.actor_id,
        coalesce(a.actor_login, w.actor_login)                      as actor_login,

        -- repo (denormalized)
        coalesce(r.repo_name, w.repo_name)                          as repo_name,
        r.repo_owner,
        r.repo_slug,
        r.repo_url,

        -- engagement type (always 'started' = starred for WatchEvent)
        w.engagement_action,

        -- timestamp
        w.event_at

    from watch_events w
    left join dim_repo   r on w.repo_id  = r.repo_id
    left join dim_actor  a on w.actor_id = a.actor_id
    left join dim_date   d on date(w.event_at) = d.calendar_date

)

select * from final