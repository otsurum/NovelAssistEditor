---
name: safe-rollback
description: 壊れたときの安全な復旧手順（macOS NovelAssistEditor / SwiftData + TCA、作品データは Git 管理外）。「壊れた」「動かない」「起動しない」「クラッシュする」「作品が消えた」「エピソードが表示されない」「ビルドが通らない」「SwiftDataのエラー」「元に戻したい」「昨日まで動いてた」「依存を更新したら壊れた」に該当したら、原因調査や破壊的操作（rm、履歴を壊す git 操作、default.store 削除、DerivedData 削除）より先に必ずこのスキルを使う。
---

# 壊れたときに安全に戻す

最優先は「元に戻すこと」ではなく「**これ以上悪化させないこと**」。
このプロジェクトでは**ユーザー本人が書いた作品が Git 管理外にあり、失うと二度と戻らない**。

## 大原則

1. **消さない・上書きしない。** 使ってよいのは「追加する」操作だけ（ブランチを切る、stash する、
   コピーする、revert を積む）。`rm` / `git reset --hard` / `git clean` / `git restore` /
   `git checkout -- .` / force push / `default.store` の削除は使わない。
   **削除・書き戻しが必要と判断したら、自分で実行せず手順を示してユーザーに依頼する。**
   `.claude/settings.json` の deny と `deny_dangerous_bash.py` で主要な操作はブロック済みだが、
   **deny に頼らずこのルールで判断する。**
2. **作業前に必ず退避する**（backup ブランチ、stash、**ストア 3 ファイルのコピー**）。
3. **1 操作ごとに平易な言葉で説明する。** 何をするか／何が起きるか／取り消せるか。
4. **2 回試して直らなかったら手を止めて報告する**（`AGENTS.md` の完了条件より厳しく運用）。
5. **「アプリを起動して確かめる」も変更操作。** Step 3 の退避が済むまで行わない。

## このプロジェクト固有の注意点

1. **作品データは 3 ファイルセット、かつ Git 管理外。**
   `~/Library/Containers/sample.NovelAssistEditor/Data/Library/Application Support/` の
   `default.store` / `-shm` / `-wal`。実測で **`-wal` が `.store` より大きく新しい**
   （2.0 MB / 3 か月新しい）= WAL に未チェックポイントの書き込みが溜まっている。
   **`.store` 1 つだけコピーしても最新の原稿は救えない。必ず 3 つまとめて扱う。**
2. **バックアップはリポジトリの外（`~/Desktop/...`）に置く。** ルート `.gitignore` は
   `*.sqlite` / `-shm` / `-wal` で **`default.store` にマッチしない**ため、
   リポジトリ内にコピーすると未追跡ファイルとして現れ、作品本文を誤ってコミットしうる。
3. **調査目的でアプリを起動しない。** `Persistance/Sources/Persistance/Schema/AppSchema.swift` は
   素の `Schema(models)` で `VersionedSchema` / `SchemaMigrationPlan` を持たない。
   起動＝ストアを開く＝軽量移行が走りうる。退避が済むまでユーザーにもアプリを終了してもらう。
4. **`xcodebuild test -scheme NovelAssistEditor` は使わない。** 共有 Scheme の TestAction に
   `NovelAssistEditorUITests` が含まれ `XCUIApplication().launch()` で実アプリを起動する
   （hook でもブロック済み）。パッケージのテストは実ストアに触らない。
5. **`make fmt`（= `swiftformat .`）は全ファイルを書き換える。調査中に実行しない。**
   読み取り確認は `swiftformat --lint .`（現状 0/77 files require formatting）。
   `make lint`（= `swiftlint --no-cache`）は読み取りのみで安全（現状 50 violations /
   0 serious → exit 0。**この既存警告を「今壊れた」と誤読しない**）。
6. **`Package.resolved` は `.gitignore` 済みで未追跡。** TCA は `from: "1.10.0"` の範囲指定で
   たまたま 1.25.5 が入っているだけ。`swift package resolve` / `update` をやり直すと
   別バージョンが入りうる。壊れたときに飛びつかない。
7. **`.build/` と `DerivedData/` は再生成できる**ので失うものは無い。ただし再帰削除は hook で
   ブロック。`swift package clean --package-path <pkg>` /
   `xcodebuild -project NovelAssistEditor.xcodeproj clean` を使う。
8. **remote は `origin` ひとつ**（`git@github.com:otsurum/NovelAssistEditor.git`）。fork ではないので
   誤爆先は無い。それでも force push はしない（Copilot レビュー済み PR を含む履歴が壊れる）。

## Step 1: 現状を凍結して把握する

読み取りだけ。まだ何も変えない。

```shell
git status -sb && git log --oneline -15 && git diff && git stash list
ls -l ~/Library/Containers/sample.NovelAssistEditor/Data/Library/Application\ Support/
# スキーマ・依存に触ったか
git diff --stat -- Persistance/Sources/Persistance/Models Persistance/Sources/Persistance/Schema
git log --oneline -10 -- Persistance/Sources/Persistance
git diff -- AppCore/Package.swift Persistance/Package.swift AppFeature/Package.swift
```

壊れ方の確認（**アプリを起動しないものだけ**。`.build` / DerivedData に書くだけ）:

```shell
swift build --package-path AppCore
swift build --package-path Persistance
swift build --package-path AppFeature
swift test  --package-path AppCore          # Swift Testing
swift test  --package-path Persistance      # Swift Testing / inMemoryOnly
swift test  --package-path AppFeature       # XCTest + TestStore
swiftformat --lint . && make lint
xcodebuild -project NovelAssistEditor.xcodeproj -scheme NovelAssistEditor -destination 'platform=macOS' build
```

ユーザーに聞く: いつまで動いていたか / 直前に何をしたか（Entity を変えた・依存を足した・
Xcode を更新した・アプリを起動した）/ エラー文とスクリーンショット。

## Step 2: 切り分ける

対応列の手順は `references/branches.md` の該当節**だけ**を読む（全文は読まない）。

| 状況 | 見分け方 | 対応 |
|---|---|---|
| 未コミットの変更で壊れた | `git status` に変更があり、直前コミットでは動いていた | 4-A |
| コミット済み（未push） | `git status -sb` が `ahead` | 4-B |
| push済み | `origin` にも上がっている | 4-C |
| ビルドは通るが起動しない／作品一覧が空 | SwiftData・`ModelContainer` のエラー、Entity や `AppSchema` に差分 | **4-D** |
| 依存の解決で壊れた | TCA の API が見つからない等、`Package.swift` を触った後 | 4-E |
| ソースは正しいのにビルドが通らない | "Module compiled with Swift ..." 系、Xcode でだけ再現 | 4-F |
| 作品データが消えた・ストアが壊れた | `default.store` が無い／SwiftData が open に失敗 | **4-G** |

## Step 3: 現状を退避する

```shell
git branch backup/before-rollback-$(date +%Y%m%d-%H%M)
git stash push -u -m "rollback前の未コミット退避 $(date +%Y-%m-%d)"
git stash apply    # pop ではなく apply（stashを残す）
```

ストアの退避。**先にユーザーにアプリを終了してもらう**（WAL が書き込み途中だとコピーが不整合になる）:

```shell
mkdir -p ~/Desktop/NovelAssistEditor-backup-$(date +%Y%m%d-%H%M)
cp ~/Library/Containers/sample.NovelAssistEditor/Data/Library/Application\ Support/default.store* \
   ~/Desktop/NovelAssistEditor-backup-$(date +%Y%m%d-%H%M)/
ls -l ~/Desktop/NovelAssistEditor-backup-*/     # 3ファイル揃っているか必ず確認
```

依存を触った疑いがあるなら `AppFeature/Package.resolved` も同じ場所へコピーする
（Git に入っていないため、これを逃すと現在のバージョン構成が復元できない）。

ユーザーへの一言: 「今の状態は `backup/...` ブランチと
`~/Desktop/NovelAssistEditor-backup-.../` に保存したので、この後で何が起きても今に戻せます」

## Step 4

`references/branches.md` の該当節へ。

## Step 5: 報告する

* 症状と Step 2 の分類
* 退避先（backup ブランチ名／stash メッセージ／`~/Desktop/NovelAssistEditor-backup-.../`）
* 実行したコマンドと結果 / 直っていない場合に残る選択肢
* `AGENTS.md` の「完了条件」に沿って検証結果（`swift test` / `make lint` /
  `swiftformat --lint .`）も添える。実行できなかったものは理由を明記する。
