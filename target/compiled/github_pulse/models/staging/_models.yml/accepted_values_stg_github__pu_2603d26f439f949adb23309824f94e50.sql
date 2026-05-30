
    
    

with all_values as (

    select
        pr_action as value_field,
        count(*) as n_records

    from `github-pulse-jumpy`.`github_pulse_analytics_dev_staging`.`stg_github__pull_request_events`
    group by pr_action

)

select *
from all_values
where value_field not in (
    'opened','closed','merged','reopened','labeled','unlabeled','assigned','unassigned','review_requested','review_request_removed','synchronize','edited','ready_for_review','converted_to_draft','auto_merge_enabled','auto_merge_disabled'
)


