import pandas

df = pandas.read_csv(
    "kitami_daily.csv",
    parse_dates=[0])

df['year'] = df['date'].dt.year

for THRESHOLD in [25, 30, 35]:
    print(
        f"\n* highest temperature >= {THRESHOLD} deg.\n",
        df[df['temp_max'] >= THRESHOLD]\
        .groupby('year')['temp_max']\
        .count()
    )

"""
# highest temperature >= 35 deg.
 year
2023    7
2024    3
Name: temp_max, dtype: int64
"""