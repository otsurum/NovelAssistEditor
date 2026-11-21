# Step 4: 状況別の復旧手順

SKILL.md の Step 2 で分類した**該当節だけ**を読む。Step 3 の退避が済んでいることが前提。

## 4-A: 未コミットの変更を取り消す

`git restore` / `git checkout -- .` は使わない（hook でブロック済み）。

```shell
git stash push -u -m "壊れた変更の退避 $(date +%Y-%m-%d)"
git stash push -- AppFeature/Sources/StoryListFeature   # 特定パスだけ戻すとき
```

stash は消さない。戻したくなったら `git stash apply stash@{N}`。

## 4-B: コミット済み（未push）を取り消す

```shell
git revert <コミット>
git revert --no-commit <古い方>..HEAD   # まとめて戻して1コミットにする
```

`git reset` は使わない。revert は履歴を残したまま打ち消すので、後から見直せる。

## 4-C: push済みを取り消す

ローカルで `git revert` してから通常の `git push origin <ブランチ>`。force push はしない。
`main` は PR 経由でマージされている（Copilot レビューあり）ので、revert も同じく PR で出す。

## 4-D: SwiftData のスキーマ変更でストアが開けない（最重要・その1）

**症状**: 起動直後にクラッシュ／`ModelContainerFactory.makeShared()` が throw／作品一覧が空。

**原因の特定**:

```shell
git diff <動いていたコミット>..HEAD -- Persistance/Sources/Persistance/Models Persistance/Sources/Persistance/Schema/AppSchema.swift
```

軽量移行で吸収**できない**変更: プロパティのリネーム、型変更、非オプショナルの追加、
リレーションの変更、`AppSchema.models` からの Entity 削除。

**前提確認**: Step 3 のストア 3 ファイルのコピーが取れていること。
無ければ**ここで止めて**、先にコピーを取る。

**最も安全な復旧は「コードを元のスキーマに戻すこと」**（4-A / 4-B）。
SwiftData はコード側の Entity 定義とストアを突き合わせるので、
コードを戻せばストアはそのまま開ける。**ストア側は触らない。**

> **やってはいけないこと: `default.store` を消して作り直す。**
> 「SwiftData のクラッシュはストアを消せば直る」という一般的な対処は、
> このプロジェクトでは**全作品の消失**を意味する。hook でもブロックしている。

破壊的なスキーマ変更を**意図して**入れたい場合は、ここでは実行しない。
`AppSchema.swift` に `VersionedSchema` + `SchemaMigrationPlan` を導入するタスクとして
別途起票する（github-task-intake スキルへ）。

検証は `ModelContainerFactory.makeShared(inMemoryOnly: true)` を使う
`Persistance/Tests` で行い、実ストアでは試さない。

## 4-E: 依存関係を戻す

```shell
git diff -- AppCore/Package.swift Persistance/Package.swift AppFeature/Package.swift
cat AppFeature/Package.resolved      # 現在のピンを報告に残す（Gitに無いため）
git stash push -- AppFeature/Package.swift
swift build --package-path AppFeature
```

* `Package.resolved` は gitignore されているので git では戻らない。
  Step 3 のコピーがあればそれを書き戻す。
* `swift package update` は使わない（上限まで上げてしまう）。
  特定バージョンに戻したいときは一時的に `.package(url: ..., exact: "1.25.5")` と書いて
  `swift package resolve`。
* `.build` を消したくなったら `swift package clean --package-path <pkg>`。

## 4-F: ビルド成果物が古い

```shell
xcodebuild -project NovelAssistEditor.xcodeproj clean
swift package clean --package-path AppCore     # 必要なパッケージについて
```

**ここで失われるものは無い**（再ビルドで復元できる）。だから、これに該当すると分かって
いるなら他の手段より先に試してよい——このスキルで唯一そう言える分岐。

`~/Library/Caches/org.swift.swiftpm` の削除は影響範囲が広いので、実行せずユーザーに確認する。
`~/Library/Developer/Xcode/DerivedData` の再帰削除は使わない（hook でブロック。上の clean で足りる）。

## 4-G: 作品データが消えた・ストアが壊れた（最重要・その2）

1. **まずアプリを起動しない。** 起動すると空のストアが作り直され、上書きされうる。
   ユーザーにアプリの終了を依頼する。
2. **退避コピーがある場合**: 現在のファイル群を別名でコピーして残してから、
   **3 ファイルすべて**を書き戻す（`-wal` だけ世代の違うものを混ぜると破損する）。
   **コンテナへの書き戻しは hook でブロックしている**ので、
   Claude はコマンドを提示し、実行はユーザー自身が行う。
3. **退避コピーが無い場合**: Time Machine、同ディレクトリの残骸、その他のバックアップの
   有無をユーザーに確認する。**空のストアを作り直せば「動く」ようにはなるが、作品は戻らない**
   ことを明示し、承認を得るまで何もしない。
4. `sqlite3` でのストアの中身確認は hook でブロックしている
   （破損リスクと原稿本文の流出防止）。必要ならユーザーがコピーに対して行う。
