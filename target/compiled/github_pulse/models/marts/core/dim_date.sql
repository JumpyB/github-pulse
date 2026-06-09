

with date_spine as (

    select
        date_add(date('2024-01-01'), interval cast(n as int64) day) as calendar_date
    from unnest(
        generate_array(0, date_diff(date('2027-12-31'), date('2024-01-01'), day))
    ) as n

),

final as (

    select
        cast(format_date('%Y%m%d', calendar_date) as int64)     as date_id,
        calendar_date,
        extract(year  from calendar_date)                        as year,
        extract(month from calendar_date)                        as month,
        extract(day   from calendar_date)                        as day,
        extract(week  from calendar_date)                        as week_of_year,
        extract(dayofweek from calendar_date)                    as day_of_week,
        format_date('%B', calendar_date)                         as month_name,
        format_date('%A', calendar_date)                         as day_name,
        format_date('%Y-%m', calendar_date)                      as year_month,
        format_date('%Y-W%W', calendar_date)                     as year_week,
        extract(dayofweek from calendar_date) in (1, 7)          as is_weekend,
        extract(dayofweek from calendar_date) not in (1, 7)      as is_weekday,
        extract(quarter from calendar_date)                      as quarter,
        concat('Q', cast(extract(quarter from calendar_date) as string)) as quarter_label
    from date_spine

)

select * from final