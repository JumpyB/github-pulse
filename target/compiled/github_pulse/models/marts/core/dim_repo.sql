

with snapshot_current as (

    select
        dbt_scd_id                                      as repo_sk,
        repo_id,
        repo_name,
        org_login,
        dbt_valid_from                                  as valid_from,
        dbt_valid_to,
        dbt_valid_to is null                            as is_current,
        split(repo_name, '/')[safe_offset(0)]           as repo_owner,
        split(repo_name, '/')[safe_offset(1)]           as repo_slug,
        concat('https://github.com/', repo_name)        as repo_url
    from `github-pulse-jumpy`.`snapshots`.`snap_repos`

)

select * from snapshot_current