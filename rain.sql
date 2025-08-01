.header on
.mode column

select
    T.year as year,
    max(T.d1) as max_d1,
    max(T.d2) as max_d2,
    max(T.d3) as max_d3
from (  -- サブクエリ
    select
        strftime('%Y', date) as year,
        rain_24h as d1, -- 日雨量
        sum(rain_24h) over (
            rows between 1 preceding and current row
        ) as d2,     -- ２日雨量
        sum(rain_24h) over (
            rows between 2 preceding and current row
        ) as d3      -- ３日雨量
    from daily
) as T
group by year;
