with dates as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2008-01-01' as date)",
        end_date="cast('2017-01-01' as date)"
    ) }}
)

select
    date_day,
    year(date_day) as year,
    month(date_day) as month_number,
    monthname(date_day) as month_name,
    quarter(date_day) as quarter_number,
    dayofweek(date_day) as day_of_week,
    dayname(date_day) as day_name,
    weekofyear(date_day) as week_of_year

from dates