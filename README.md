
# NovelAssistEditor

小説執筆を支援するためのエディタアプリです。
このプロジェクトでは、保守性とテスト容易性を高めるため、**The Composable Architecture (TCA)** をベースに、役割ごとのマルチモジュール構成を採用しています。

---

## Architecture Overview

アプリの責務を明確に分離するため、以下の3つの主要レイヤー（Swift Package）に分割しています。

### 依存構造
依存関係は常に一方向（下向き）であり、上位レイヤーが下位レイヤーの具体的な実装詳細に依存しないように設計されています。

- **AppFeature** → **Persistence** & **AppCore**
- **Persistence** → **AppCore**
- **AppCore** → ❌ (どの層にも依存しない)

---

## 各レイヤーの詳細

### 1. AppCore
**役割：ドメインモデルとビジネスロジック**

アプリケーションの核心となるデータ構造やルールを定義する最下層のモジュールです。

- **特徴:**
  - SwiftUI や SwiftData に一切依存しない純粋な Swift コード。
  - 値オブジェクト、エンティティ、ビジネスロジックを保持。
  - 他すべてのモジュールから参照される「共通言語」。

### 2. Persistence
**役割：データの永続化と変換**

SwiftData を利用してデータの保存・取得を担当します。AppCore と AppFeature の橋渡し役となります。

- **主な機能:**
  - **スキーマ定義:** SwiftData の `@Model` を使用したエンティティ定義。
  - **データ変換（Mapping）:** 永続化用の `Entity` とドメイン用の `Model` を相互に変換します。
  - **PersistenceClient:** Feature 層へ公開するインターフェース（API）の定義。

#### 実装例：データ変換
```swift
import AppCore
import SwiftData

extension TaskEntity {
    // Entity から Domain Model への変換
    func toDomain() -> Task {
        Task(id: id, title: title, isDone: isDone)
    }
    
    // Domain Model から Entity への初期化
    convenience init(task: Task) {
        self.init(id: task.id, title: task.title, isDone: task.isDone)
    }
}
```

### 3. AppFeature役割
UI とユーザーインタラクションTCA (The Composable Architecture) を用いて、アプリの画面、状態管理、およびアクションを実装します。


#### 特徴
直接 SwiftData には触れず、PersistenceClient を介してデータを操作します。UI コンポーネントと Reducer (ビジネスロジックの受け皿) を含みます。


実装例 (TCA Reducer)Swiftimport ComposableArchitecture
```
import AppCore

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var tasks: [Task] = []
        public init() {}
    }

    public enum Action {
        case onAppear
        case tasksLoaded([Task])
    }

    @Dependency(\.persistenceClient) var persistence

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let tasks = try persistence.fetchTasks()
                    await send(.tasksLoaded(tasks))
                }
            case let .tasksLoaded(tasks):
                state.tasks = tasks
                return .none
            }
        }
    }
}
```

---

## CI/CD - Make Commands

このプロジェクトでは、コード品質の維持とビルドプロセスを自動化するために **Make** コマンドを提供しています。

### 利用可能なコマンド

#### 1. フォーマット（`make fmt`）
**目的:** コードスタイルを統一する

```bash
make fmt
```

- **ツール:** SwiftFormat
- **実行内容:** プロジェクト全体のコードを自動フォーマットします。
- **設定ファイル:** `.swiftformat`
  - インデント: 4 スペース
  - 最大幅: 120 文字
  - Swift バージョン: 6.0

#### 2. Lint（`make lint`）
**目的:** コード品質チェックと潜在的なバグの検出

```bash
make lint
```

- **ツール:** SwiftLint
- **実行内容:** コーディング規約の違反や潜在的な問題をチェックします。
- **設定ファイル:** `.swiftlint.yml`
  - 対象: AppCore、AppFeature、Persistance、NovelAssistEditor
  - 除外: .build、DerivedData

### 推奨使用フロー

1. **開発中:** コードを書く
2. **Commit 前:** 
   ```bash
   make fmt    # コードをフォーマット
   make lint   # 品質チェック
   ```
3. **確認:** エラーがなければ git add & commit

### CI/CD パイプラインでの活用

GitHub Actions や他の CI/CD ツールで以下のように設定できます：

```yaml
- name: Format Check
  run: make fmt
  
- name: Lint Check
  run: make lint
```

### トラブルシューティング

**SwiftLint のエラー:** "SourceKitdInProc failed"
- Xcode を起動してプロジェクトをビルドすることで解決する場合があります。
- または、Xcode 内蔵の静的解析を使用してください。

**SwiftFormat が実行されない:**
- Homebrew から再インストール：`brew reinstall swiftformat`
- PATH を確認：`which swiftformat`
