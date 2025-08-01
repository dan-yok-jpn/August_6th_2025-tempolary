VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Sheet1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True

Const DRIVER_PATH = "%LOCALAPPDATA%\SeleniumVBA\chromedriver.exe"
Const URL_DAILY = "https://www.data.jma.go.jp/stats/etrn/view/daily_a1.php?"
Const INVALID = -999
'

Private Sub CommandButton1_Click()

    Dim Caps As Object, row As Object, col As Object

    fname = "kitami_daily.csv"
    URL_PREFIX = URL_DAILY & "prec_no=17&block_no=0074" '–kŒ©

    dt_init = #1/1/2023# 'Žæ“¾ŠJŽn“ú
    dt_exit = #1/1/2025# 'Žæ“¾I—¹‚Ì—‚“ú

    Open ThisWorkbook.Path & "\" & fname For Output As #1

    Print #1, "date,rain_24h,rain_60m,rain_10m,temp_ave,temp_max,temp_min"

    With New SeleniumVBA.WebDriver

        .StartChrome DRIVER_PATH
        Set Caps = .CreateCapabilities
        Caps.RunInvisible

        .OpenBrowser Caps

        days = dt_exit - dt_init
        dt = dt_init
        Do
            Application.StatusBar = "Progress : " & _
                                    Format(100 * (dt - dt_init) / days, "0.0") & " %"

            .NavigateTo URL_PREFIX & "&year=" & Year(dt) & "&month=" & Month(dt)
            .Wait 200

            With .FindElementByID("tablefix1")

                row_no = 1
                For Each row In .FindElementsByTagName("tr")

                    If row_no > 3 Then
                        
                        col_no = 1
                        For Each col In row.FindElementsByTagName("td")

                            If col_no = 1 Then

                                buf = Format(dt, "yyyy-mm-dd") 'ISO-8601
                                
                            Else

                                data = col.GetInnerHTML

                                If IsNumeric(data) Then
                                    buf = buf & Format(Val(data), ",0.0")
                                Else
                                    buf = buf & Format(INVALID, ",#")
                                End If

                                If col_no = 7 Then Exit For
                            End If

                            col_no = col_no + 1
                        Next col

                        Print #1, buf

                        dt = dt + 1
                        If dt = dt_exit Then Exit Do
                    End If

                    row_no = row_no + 1
                Next row

            End With
        Loop

        .CloseBrowser
        .Shutdown

    End With

    Close #1
    Set Caps = Nothing

    Application.StatusBar = ""

End Sub
