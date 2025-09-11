# Neovim キーバインド一覧

## 基本操作
- `<Space>` - リーダーキー

## ファイル・ディレクトリ検索
- `<Space>sf` - ファイル検索
- `<Space>sg` - ファイル内容をGrep検索
- `<Space>s.` - 最近使用したファイル
- `<Space><Space>` - 開いているバッファ一覧
- `<Cmd-p>` または `<D-p>` - ファイル検索（macOS）
- `<Space>si` - 現在のドキュメント内のシンボル検索
- `<Space>sI` - ワークスペース全体のシンボル検索

## ヘルプ・情報検索
- `<Space>sh` - ヘルプ検索
- `<Space>sk` - キーマップ検索
- `<Space>ss` - Telescopeの機能一覧
- `<Space>sw` - カーソル下の単語を検索
- `<Space>sd` - 診断情報の検索
- `<Space>sr` - 前回の検索を再開
- `<Space>sn` - Neovim設定ファイルを検索
- `<Space>/` - 現在のバッファ内でファジー検索
- `<Space>s/` - 開いているファイル内でGrep検索

## LSP機能
- `grn` - 変数名の変更（リネーム）
- `gra` - コードアクション
- `grr` - 参照の検索
- `gri` - 実装へジャンプ
- `grd` - 定義へジャンプ
- `grD` - 宣言へジャンプ
- `gO` - ドキュメントのシンボル一覧
- `gW` - ワークスペースのシンボル一覧
- `grt` - 型定義へジャンプ
- `<Space>th` - インレイヒントの切り替え
- `[d` - 前の診断へ移動
- `]d` - 次の診断へ移動

## Git操作
- `<Space>lg` - LazyGit起動
- `<Space>gs` - Git Status
- `<Space>gb` - Git Blame
- `<Space>gd` - Git Diff Split
- `<Space>gc` - Git Commit
- `<Space>gp` - Git Push
- `<Space>hD` - Git Hunk Diff
- `<Space>hd` - Git Hunk Delete
- `[c` - 前の変更へ移動
- `]c` - 次の変更へ移動

## フォーマット・リント
- `<Space>f` - バッファをフォーマット
- `<Space>q` - 診断情報をQuickfixリストで開く

## ウィンドウ操作
- `<Ctrl-h>` - 左のウィンドウへ移動
- `<Ctrl-l>` - 右のウィンドウへ移動
- `<Ctrl-j>` - 下のウィンドウへ移動
- `<Ctrl-k>` - 上のウィンドウへ移動

## ファイルツリー（Neo-tree）
- `\\` - ファイルツリーの表示/非表示
- `<Space>be` - バッファエクスプローラー

## 編集補助
- `gc` - 選択範囲をコメントアウト（Visual mode）
- `gcc` - 行をコメントアウト（Normal mode）
- `<Space>rn` - インクリメンタルリネーム（変数名の変更）
- `<Alt-h/j/k/l>` - 選択テキストまたは行の移動

## パッケージ管理（package.json）
- `<Space>nu` - パッケージを更新
- `<Space>nd` - パッケージを削除
- `<Space>ni` - パッケージをインストール
- `<Space>nc` - パッケージのバージョンを変更

## その他
- `<Esc>` - 検索ハイライトをクリア
- `<Esc><Esc>` - ターミナルモードを終了

## ナビゲーション
- `<Ctrl-o>` - 前の位置へ戻る
- `<Ctrl-i>` - 次の位置へ進む

## プラグイン管理
- `:Lazy` - プラグインマネージャーを開く
- `:Mason` - LSP/ツールインストーラーを開く
- `:ConformInfo` - フォーマッター情報を表示