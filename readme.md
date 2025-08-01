## Web Scraping の実践

&emsp;[VBA](file:///C:/Users/dan_y/Documents/repositories/WIS/readme.md#%E3%83%87%E3%83%BC%E3%82%BF%E5%8F%96%E5%BE%97) で記述された Selenium 言語バインディング（[SeleniumVBA](https://github.com/GCuser99/SeleniumVBA)）と [ChromeDriver](https://developer.chrome.com/docs/chromedriver?hl=ja) を用いて[気象庁のウェブページ](https://www.data.jma.go.jp/stats/etrn/index.php)から[北見観測所](https://www.data.jma.go.jp/stats/etrn/view/daily_a1.php?prec_no=17&block_no=0074&year=2025&month=7)のデータをスクレーピングする。実行環境の設定方法は[こちら](Install_SeleniumVBA.md)を参照

<div style="text-align: center">
<img src="https://s3-ap-northeast-1.amazonaws.com/codegrid/2014-selenium/img/selenium-2.png" width="60%">
</div>

### 2025 年 7 月のデータを表示する URL

<p style="margin-left:20px">
https://www.data.jma.go.jp/stats/etrn/view/daily_a1.php<br>
<span style="color:red">?</span>prec_no=17<br>
<span style="color:red">&</span>block_no=0074<br>
<span style="color:red">&</span>year=2025<br>
<span style="color:red">&</span>month=7
</p>

### HTML（抜粋）

```html
  1	
  2	<!doctype html>
  3	<html lang="ja">
  4	<head>
            :
 19	</head>
 20	<body>
            :
 77	<table id="tablefix1" class="data2_s">
 78	<tr class="mtx">
            :   1 行目（項目名）
 86	</tr>
 87	<tr class="mtx">
            :   2 行目（同）
 93	</tr>
 94	<tr class="mtx">
            :   3 行目（同）
 97	</tr>
 98	<tr class="mtx" style="text-align:right;"><td style="white-space:nowrap"><div clas
s="a_print"><a href="hourly_a1.php?prec_no=17&block_no=0074&year=2025&month=07&day=1&view=
p1">1</a></div></td><td class=data_0_0>2.0</td><td class=data_0_0>2.0</td><td class=data_0
_0>1.5</td><td class=data_0_0>23.8</td><td class=data_0_0>30.6</td><td class=data_0_0>19.9
</td><td class=data_0_0>81</td><td class=data_0_0>54</td><td class=data_0_0>2.3</td><td cl
ass=data_0_0>5.3</td><td class=data_0_0 style="text-align:center">北東</td><td class=dat
a_0_0>8.5</td><td class=data_0_0 style="text-align:center">北東</td><td class=data_0_0 s
tyle="text-align:center">南西</td><td class=data_0_0>4.9</td><td class=data_0_0>0</td><t
d class=data_0_0>0</td></tr>
    :   5 行目以降
129	</table>
    :
150	....... </body>
151	</html>
```

### VBA

```vb
 1	
 2	Const DRIVER_PATH = "%LOCALAPPDATA%\SeleniumVBA\chromedriver.exe"
 3	Const URL_DAILY = "https://www.data.jma.go.jp/stats/etrn/view/daily_a1.php?"
 4	Const INVALID = -999
 5	'
 6	
 7	Private Sub CommandButton1_Click()
 8	
 9	    Dim Caps As Object, row As Object, col As Object
10	
11	    fname = "kitami_daily.csv"
12	    URL_PREFIX = URL_DAILY & "prec_no=17&block_no=0074" '北見
13	
14	    dt_init = #1/1/2023# '取得開始日
15	    dt_exit = #1/1/2025# '取得終了の翌日
16	
17	    Open ThisWorkbook.Path & "\" & fname For Output As #1
18	
19	    Print #1, "date,rain_24h,rain_60m,rain_10m,temp_ave,temp_max,temp_min"
20	
21	    With New SeleniumVBA.WebDriver
22	
23	        .StartChrome DRIVER_PATH
24	        Set Caps = .CreateCapabilities
25	        Caps.RunInvisible
26	
27	        .OpenBrowser Caps
28	
29	        days = dt_exit - dt_init
30	        dt = dt_init
31	        Do
32	            Application.StatusBar = "Progress : " & _
33	                                    Format(100 * (dt - dt_init) / days, "0.0") & " %"
34	
35	            .NavigateTo URL_PREFIX & "&year=" & Year(dt) & "&month=" & Month(dt)
36	            .Wait 200
37	
38	            With .FindElementByID("tablefix1")
39	
40	                row_no = 1
41	                For Each row In .FindElementsByTagName("tr")
42	
43	                    If row_no > 3 Then
44	                        
45	                        col_no = 1
46	                        For Each col In row.FindElementsByTagName("td")
47	
48	                            If col_no = 1 Then
49	
50	                                buf = Format(dt, "yyyy-mm-dd") 'ISO-8601
51	                                
52	                            Else
53	
54	                                data = col.GetInnerHTML
55	
56	                                If IsNumeric(data) Then
57	                                    buf = buf & Format(Val(data), ",0.0")
58	                                Else
59	                                    buf = buf & Format(INVALID, ",#")
60	                                End If
61	
62	                                If col_no = 7 Then Exit For
63	                            End If
64	
65	                            col_no = col_no + 1
66	                        Next col
67	
68	                        Print #1, buf
69	
70	                        dt = dt + 1
71	                        If dt = dt_exit Then Exit Do
72	                    End If
73	
74	                    row_no = row_no + 1
75	                Next row
76	
77	            End With
78	        Loop
79	
80	        .CloseBrowser
81	        .Shutdown
82	
83	    End With
84	
85	    Close #1
86	    Set Caps = Nothing
87	
88	    Application.StatusBar = ""
89	
90	End Sub
```

## kitami_daily.csv

<p style="margin-left:20px">
date,rain_24h,rain_60m,rain_10m,temp_ave,temp_max,temp_min<br>
2023-01-01,0.0,0.0,0.0,-11.1,-1.9,-18.2<br>
2023-01-02,0.0,0.0,0.0,-13.3,-7.5,-20.9<br>
2023-01-03,0.0,0.0,0.0,-17.7,-9.5,-24.5<br>
2023-01-04,0.0,0.0,0.0,-16.3,-7.6,-22.2<br>
&emsp;&emsp;&emsp;:<br>
2024-12-27,0.0,0.0,0.0,-7.4,-4.0,-14.4<br>
2024-12-28,0.0,0.0,0.0,-5.6,-1.7,-16.0<br>
2024-12-29,0.0,0.0,0.0,-8.0,-1.2,-13.5<br>
2024-12-30,0.0,0.0,0.0,-10.3,-5.2,-16.8<br>
2024-12-31,4.5,1.0,0.5,-9.7,-4.3,-18.4
</p>

----

## 各年の夏日・真夏日・猛暑日の日数をカウント（昭和人の処方）

### create.sql の編集

```sql
 1	create table daily(
 2	    date     text,
 3	    rain_24h real,
 4	    rain_60m real,
 5	    rain_10m real,
 6	    temp_ave real,
 7	    temp_max real,
 8	    temp_min real
 9	);
10	
11	.mode csv
12	.import -skip 1 kitami_daily.csv daily
13
```

### データベースに変換

```bash
sqlite3 kitami.db < create.sql
```

&emsp;&emsp;※ sqlite3.exe は QGIS 同梱。私の場合 ```C:\OSGeo4W\bin\sqlite3.exe```

### count.sql（最高気温 が THRESHOLD を超える日数をカウント）を編集

```sql
 1	.header on
 2	.mode column
 3	
 4	select
 5	    strftime('%Y', date) as year,
 6	    count(temp_max)      as days
 7	from daily
 8	where temp_max >= THRESHOLD
 9	group by year;
```

### 夏日（25° 以上）の発生日数の検索

```bash
sed -e "s/THRESHOLD/25/" count.sql | sqlite3 kitami_daily.db
```

&emsp;&emsp;※ [sed.exe](https://ja.wikipedia.org/wiki/Sed_(%E3%82%B3%E3%83%B3%E3%83%94%E3%83%A5%E3%83%BC%E3%82%BF)) は ```winget install --id=mbuilov.sed  -e``` でインストールできる（知らんけど）

#### 実行結果

<p style="margin-left:20px">
year  days<br>
----  ----<br>
2023  79<br>
2024  80
</p>

### count.bat の編集

```bash
1	@echo off
2	
3	for %%i in (25 30 35) do (
4	    echo # highest temperature ^>= %%i deg.
5	    sed -e "s/THRESHOLD/%%i/" count.sql | sqlite3 kitami_daily.db
6	    echo.
7	)
```

#### 実行結果

<p style="margin-left:20px">
# highest temperature >= 25 deg.<br>
year  days<br>
----  ----<br>
2023  79  <br>
2024  80  <br>
<br>
# highest temperature >= 30 deg.<br>
year  days<br>
----  ----<br>
2023  35  <br>
2024  25  <br>
<br>
# highest temperature >= 35 deg.<br>
year  days<br>
----  ----<br>
2023  7   <br>
2024  3
</p>

<br>

### 現代人なら・・・（？）

```python
 1	import pandas
 2	
 3	df = pandas.read_csv(
 4	    "kitami_daily.csv",
 5	    parse_dates=[0])
 6	
 7	df['year'] = df['date'].dt.year
 8	
 9	for THRESHOLD in [25, 30, 35]:
10	    print(
11	        f"\n# days highest temperature >= {THRESHOLD} deg.\n",
12	        df[df['temp_max'] >= THRESHOLD]\
13	        .groupby('year')['temp_max']\
14	        .count()
15	    )
16	
17	"""
18	# days highest temperature >= 35 deg.
19	 year
20	2023    7
21	2024    3
22	Name: temp_max, dtype: int64
23	"""
```

&emsp;&emsp;※ Python には SQLite データベースを操作するためのライブラリ sqlite3 が標準で組み込まれている

<br>

### rain.sql：年最大の日雨量・２日雨量・３日雨量の抽出する場合の SQL

```sql
 1	.header on
 2	.mode column
   
 3	select
 4	    T.year as year,
 5	    max(T.d1) as max_d1,
 6	    max(T.d2) as max_d2,
 7	    max(T.d3) as max_d3
 8	from (
 9	    select
10	        strftime('%Y', date) as year,
11	        rain_24h as d1, -- dulattion : 1 day
12	        sum(rain_24h) over (
13	            rows between 1 preceding and current row
14	        ) as d2,        --    do.    : 2 days
15	        sum(rain_24h) over (
16	            rows between 2 preceding and current row
17	        ) as d3         --    do.    : 3 days
18	    from daily
19	) as T
20	group by year;
```

#### コマンドライン

```bash
sqlite3 kitami_daily.db < rain.sql
```

&emsp;あるいは、インメモリデータベース（```:memory:```）を使う場合

```bash
type create.sql rain.sql 2> nul | sqlite3 :memory:
```

----

## GIS でも CUI、GIS でも SQL

&emsp;次のバッチファイルを実行すると、四国４県の地理情報が shikoku.sqlite に収納される<br>
&emsp;QGIS 同梱の [ogr2ogr.exe](https://gdal.org/en/stable/programs/ogr2ogr.html) は [OSGeo 財団](https://www.osgeo.org/) がオープンソースで公開している [GDAL](https://gdal.org/)（**G**eospatial **D**ata **A**bstraction **L**ibrary）を用いて作成されたベクターデータ用のプログラム。
GDAL は **i-RIC**, QGIS, Google Earth, ArcGIS 等々、様々なソフトウエアで利用されている<br>
&emsp;クエリ文字列 %SQL% に標準 SQL では非対応の ST_Union 関数（ここでは同一県内の市町村のポリゴンをマージする）を含むので dialect（方言）引数に sqlite を指定。nln は **n**ew **l**ayer **n**ame<br>
&emsp;入力ファイル [japan_ver84.zip](https://www.esrij.com/products/japan-shp/) は ESRI JAPAN が公開している全国**市区町村界**データ（ESRI ShapeFile）。
GDAL では <span style="color:red">/vsizip/</span>foo.zip とすると仮想的に foo.zip をディレクトリとみなす

```bash
 1	@echo off
 2	setlocal
 3	set OSGEO4W=C:\OSGeo4W
 4	set PATH=%OSGEO4W%\bin;%PATH%
 5	call %OSGEO4W%\etc\ini\gdal.bat
 6	
 7	if exist *.sqlite del *.sqlite
 8	
 9	set SQL=SELECT
10	set SQL=%SQL% ST_Union(ST_buffer(geometry, 0.0001)) AS geometry,
11	set SQL=%SQL% SUBSTR(JCODE, 1, 2) AS pref_code,
12	set SQL=%SQL% KEN AS pref_name
13	set SQL=%SQL% FROM japan_ver84
14	set SQL=%SQL% WHERE pref_code BETWEEN '36' AND '39'
15	set SQL=%SQL% GROUP BY pref_code
16	
17	ogr2ogr ^
18	    -nln     prefs ^
19	    -dialect sqlite ^
20	    -sql     "%SQL%" ^
21	    shikoku.sqlite /vsizip/japan_ver84.zip
```

<div style="text-align: center">
<img src="https://www.flumen-jp.com/wordpress/wp-content/uploads/2024/04/shikoku.png" width="80%">
</div>