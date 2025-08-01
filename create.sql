create table daily(
    date     text,
    rain_24h real,
    rain_60m real,
    rain_10m real,
    temp_ave real,
    temp_max real,
    temp_min real
);

.mode csv
.import -skip 1 kitami_daily.csv daily
