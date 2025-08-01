.header on
.mode column

select
    strftime('%Y', date) as year,
    count(temp_max)      as days
from daily
where temp_max >= THRESHOLD
group by year;