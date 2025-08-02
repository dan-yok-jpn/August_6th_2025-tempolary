## Excel と Chrome によるウェブスクレーピングのための環境設定（手動）

### SeleniumVBA のインストール

1. [このページ](https://github.com/GCuser99/SeleniumVBA/blob/main/dist/SeleniumVBADLLSetup.exe)の「Raw」ボタンを右クリックして「名前を付けてリンク先を保存」。
表示されるダイヤログ中のファイル名（SeleniumVBADLLSetup.exe）の拡張子を **txt** に替えて保存

1. ダウンロードしたファイルの拡張子を **exe** に戻してダブルクリックすると「Windows によって PC が保護されました」と表示されるので「詳細情報」をクリックして新たに表示される「実行」ボタンをクリック

1. 起動後「Select Destination Location」は %LOCALAPPDATA%\SeleniumVBA（インストーラは %LOCALAPPDATA% を解さないので実際は C:\Users\\<span style="color:red"><i>your name</i></span>\AppData\Local\SeleniumVBA）を指定する。他は普通通り「OK」等で先に進める

1. インストーラを削除

### ChromeDriver のインストール

1. Google Chrome を起動して「chrome://settings/help」を検索。バージョンの文字列（例えば「138.0.7204.169」）をクリップボードにコピー

1. コマンドプロンプトを開いて以下の各行を実行。一行目は「set VER=」に続けて Cntrl+V をタイプ。上条の例の場合は「set VER=138.0.7204.169」となる

    ```bash
    set VER=Cntrl+V
    cd %LOCALAPPDATA%\SeleniumVBA
    curl https://storage.googleapis.com/chrome-for-testing-public/%VER%/win64/chromedriver-win64.zip -o chromedriver-win64.zip
    ```

1. ```chromedriver-win64.zip``` を解凍

    ```bash
    7z x chromedriver-win64.zip
    mv chromedriver-win64\chromedriver.exe .
    ```

1. 後始末

    ```bash
    del chromedriver-win64.zip
    rmdir /s /q chromedriver-win64
    ```

&emsp;以上で %LOCALAPPDATA%\SeleniumVBA の構成が以下のようであれば OK<br>
<!-- &emsp;**ただし、SeleniumVBA、ChromeDriver 共にしばしばアップデートされているので随時、上書きする** -->
&emsp;なお、[こちらのリポジトリ](https://github.com/dan-yok-jpn/SeleniumVBA)の ```sample.xlsm``` を流用すると、自動的に使用中の Chrome のバージョンに適合する ```chromedriver.exe``` がインストールされる。
また ```SeleniumVBA_win64.dll``` の更新がなされている場合はインストーラのダウンロードが行われ、インストールの実行が催促される。

```
%LOCALAPPDATA%\SeleniumVBA
│  chromedriver.exe
│  LICENSE.txt
│  readme.rtf
│  SeleniumVBA.ini
│  SeleniumVBA_win64.dll
│  unins000.dat
│  unins000.exe
│  wiki help documentation.url
│
├─examples
│      readme.txt
│      SeleniumVBA test subs for tB.accdb
│      SeleniumVBA test subs for tB.xlsm
│
└─utilities
        cleanup_drivers.ps1
        create_update_ini_file.ps1
        launch_chrome_in_debugger_mode.ps1
        launch_edge_in_debugger_mode.ps1
```

### 参照設定

&emsp;SeleniumVBA を利用するマクロ有効ワークブック（拡張子：xlsm）では「%LOCALAPPDATA%\SeleniumVBA\SeleniumVBA_win64.dll」への参照を設定する

----

### 参　考

* SeleniumVBA のチュートリアルは[ここ](https://github.com/GCuser99/SeleniumVBA/wiki)にある
* マクロのサンプルは %LOCALAPPDATA%\SeleniumVBA\examples\SeleniumVBA test subs for tB.xlsm 内にある