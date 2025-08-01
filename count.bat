@echo off

for %%i in (25 30 35) do (
    echo # highest temperature ^>= %%i deg.
    sed -e "s/THRESHOLD/%%i/" count.sql | sqlite3 kitami_daily.db
    echo.
)