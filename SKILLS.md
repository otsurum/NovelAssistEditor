# SKILLS - 実装ガイド

このドキュメントは、NovelAssistEditor プロジェクトでの機能実装フローを説明します。
**AppCore** → **Persistence** → **AppFeature** の順序に従い、各レイヤーの実装方法と職務分離を明確にしています。

---

## Table of Contents

1. [概要](#概要)
2. [実装フロー](#実装フロー)
3. [AppCore - ドメインモデル層](#appcore---ドメインモデル層)
4. [Persistence - データ永続化層](#persistence---データ永続化層)
5. [AppFeature - UI/UX層](#appfeature---uiux層)
6. [実装例：Workモデル](#実装例workモデル)
7. [テスト戦略](#テスト戦略)
8. [ベストプラクティス](#ベストプラクティス)

---

## 概要

このプロジェクトは **3層アーキテクチャ** を採用しています：

```
┌─────────────────────────────────┐
│      AppFeature (UI/UX)         │
│  View, Reducer, State, Action   │
└────────────────┬────────────────┘
                 │
┌────────────────▼────────────────┐
│  Persistence (Data Layer)       │
│  Entity, Mapper, Client         │
└────────────────┬────────────────┘
                 │
┌────────────────▼────────────────┐
│   AppCore (Domain Model)        │
│  Model, VO, FailureReason       │
└─────────────────────────────────┘
```

**依存関係：** AppFeature → Persistence → AppCore

---

## 実装フロー

新機能を実装する際は、**下層から上層へ** という順序で進めます：

### ステップ 1: AppCore でドメインモデルを定義
```
新機能の要件
    ↓
[AppCore] モデルを定義
    ↓
値オブジェクト・エンティティ・ビジネスロジック
```

### ステップ 2: Persistence でデータ永続化を実装
```
[AppCore] モデル定義完了
    ↓
[Persistence] SwiftData Entity を定義
    ↓
[Persistence] Mapper で変換ロジック実装
    ↓
[Persistence] Client でインターフェース定義
```

### ステップ 3: AppFeature で UI/UX を実装
```
[Persistence] Client インターフェース完成
    ↓
[AppFeature] Reducer で状態管理を実装
    ↓
[AppFeature] View でUI表示を実装
```

---

## AppCore - ドメインモデル層

**責務：** ビジネスロジック、データ構造、ルール定義

### 特徴
- ❌ SwiftUI に依存しない
- ❌ SwiftData に依存しない
- ✅ 純粋な Swift コード
- ✅ ドメイン知識を集約

### 実装パターン

#### 1. ドメインモデル（Value Object / Entity）

```swift
// AppCore/Sources/AppCore/Models/Work.swift
import Foundation

public struct Work: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var summary: String?
    public var styleMemo: String?
    public var theme: String?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        summary: String? = nil,
        styleMemo: String? = nil,
        theme: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.styleMemo = styleMemo
        self.theme = theme
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // ビジネスロジック例
    public func isRecent(days: Int = 7) -> Bool {
        Date.now.timeIntervalSince(updatedAt) < TimeInterval(days * 86400)
    }
}
```

#### 2. エラー定義

```swift
// AppCore/Sources/AppCore/Models/FailureReason.swift
public struct FailureReason: Error, Equatable, Sendable {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }
}
```

### チェックリスト
- [ ] モデルに `Identifiable` を実装
- [ ] `Equatable` と `Sendable` に準拠
- [ ] 初期化メソッドをカスタマイズ
- [ ] ビジネスロジックメソッドを追加

---

## Persistence - データ永続化層

**責務：** データ保存・取得、AppCore と AppFeature の仲介

### 構成

```
Persistence/
├── Sources/Persistance/
│   ├── Clients/
│   │   ├── ModelContainerFactory.swift    # SwiftData 初期化
│   │   └── WorkClient.swift               # インターフェース
│   ├── Models/
│   │   ├── WorkEntity.swift               # SwiftData @Model
│   │   └── WorkMapper.swift               # 変換ロジック
│   ├── Schema/
│   │   └── AppSchema.swift                # スキーマ定義
│   └── Persistance.swift
└── Tests/
```

### 実装パターン

#### 1. SwiftData Entity 定義

```swift
// Persistance/Sources/Persistance/Models/WorkEntity.swift
import Foundation
import SwiftData

@Model
final class WorkEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String?
    var styleMemo: String?
    var theme: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        summary: String? = nil,
        styleMemo: String? = nil,
        theme: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.styleMemo = styleMemo
        self.theme = theme
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
```

#### 2. Mapper（変換ロジック）

```swift
// Persistance/Sources/Persistance/Models/WorkMapper.swift
import AppCore
import Foundation

extension WorkEntity {
    // Entity → Domain Model
    func toDomain() -> Work {
        Work(
            id: id,
            title: title,
            summary: summary,
            styleMemo: styleMemo,
            theme: theme,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // Domain Model → Entity
    convenience init(from work: Work) {
        self.init(
            id: work.id,
            title: work.title,
            summary: work.summary,
            styleMemo: work.styleMemo,
            theme: work.theme,
            createdAt: work.createdAt,
            updatedAt: work.updatedAt
        )
    }
}

extension Array where Element == WorkEntity {
    func toDomain() -> [Work] {
        map { $0.toDomain() }
    }
}
```

#### 3. Client インターフェース

```swift
// Persistance/Sources/Persistance/Clients/WorkClient.swift
import AppCore
import ComposableArchitecture
import Foundation

public struct WorkClient {
    public var fetchWorks: () async throws -> [Work]
    public var createWork: (Work) async throws -> Void
    public var updateWork: (Work) async throws -> Void
    public var deleteWork: (UUID) async throws -> Void

    public init(
        fetchWorks: @escaping () async throws -> [Work],
        createWork: @escaping (Work) async throws -> Void,
        updateWork: @escaping (Work) async throws -> Void,
        deleteWork: @escaping (UUID) async throws -> Void
    ) {
        self.fetchWorks = fetchWorks
        self.createWork = createWork
        self.updateWork = updateWork
        self.deleteWork = deleteWork
    }
}

// Dependency Extension
extension DependencyValues {
    public var workClient: WorkClient {
        get { self[WorkClient.self] }
        set { self[WorkClient.self] = newValue }
    }
}

// Live Implementation
extension WorkClient: DependencyKey {
    public static let liveValue: WorkClient = {
        let container = ModelContainerFactory.shared.container

        return WorkClient(
            fetchWorks: {
                let descriptor = FetchDescriptor<WorkEntity>()
                let entities = try container.mainContext.fetch(descriptor)
                return entities.toDomain()
            },
            createWork: { work in
                let entity = WorkEntity(from: work)
                container.mainContext.insert(entity)
                try container.mainContext.save()
            },
            updateWork: { work in
                let entity = WorkEntity(from: work)
                container.mainContext.insert(entity)
                try container.mainContext.save()
            },
            deleteWork: { id in
                var descriptor = FetchDescriptor<WorkEntity>()
                descriptor.predicate = #Predicate { $0.id == id }
                try container.mainContext.delete(model: WorkEntity.self, where: #Predicate { $0.id == id })
                try container.mainContext.save()
            }
        )
    }()
}
```

### チェックリスト
- [ ] Entity に `@Model` と `@Attribute` を正しく指定
- [ ] `toDomain()` メソッド実装
- [ ] 初期化メソッド `init(from:)` 実装
- [ ] Client のすべてのメソッドを実装
- [ ] DependencyKey に準拠
- [ ] Live Implementation を提供

---

## AppFeature - UI/UX層

**責務：** 画面表示、ユーザーインタラクション、状態管理（TCA）

### 構成

```
AppFeature/
├── Sources/AppFeature/
│   ├── WorkListFeature/
│   │   ├── WorkListFeature.swift       # Reducer
│   │   ├── WorkListView.swift          # 親View
│   │   └── Components/
│   │       ├── WorkList.swift          # 一覧表示
│   │       └── CreateWorkModal.swift   # 作成画面
│   └── AppView.swift
└── Tests/
```

### 実装パターン

#### 1. Reducer（状態管理）

```swift
// AppFeature/Sources/WorkListFeature/WorkListFeature.swift
import AppCore
import ComposableArchitecture
import Foundation

@Reducer
public struct WorkListFeature {
    @ObservableState
    public struct State: Equatable {
        public var works: [Work] = []
        public var isLoading = false
        public var isShowingCreateModal = false
        public var createModalForm = CreateModalFormState()

        public init() {}
    }

    public struct CreateModalFormState: Equatable {
        public var title: String = ""
        public var summary: String = ""
        public var styleMemo: String = ""
        public var theme: String = ""

        public init() {}
    }

    public enum Action: Equatable {
        case showCreateModal
        case hideCreateModal
        case task
        case retryButtonTapped
        case createWork
        case worksResponse(Result<[Work], FailureReason>)
        case updateFormTitle(String)
        case updateFormSummary(String)
        case updateFormStyleMemo(String)
        case updateFormTheme(String)
    }

    public struct FailureReason: Error, Equatable, Sendable {
        public let message: String

        public init(_ message: String) {
            self.message = message
        }
    }

    @Dependency(\.workListClient) var workListClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showCreateModal:
                state.isShowingCreateModal = true
                return .none

            case .hideCreateModal:
                state.isShowingCreateModal = false
                state.createModalForm = CreateModalFormState()
                return .none

            case .task, .retryButtonTapped:
                state.isLoading = true

                return .run { [workListClient] send in
                    do {
                        let works = try await workListClient.fetchWorks()
                        await send(.worksResponse(.success(works)))
                    } catch {
                        await send(.worksResponse(.failure(FailureReason(error.localizedDescription))))
                    }
                }

            case let .worksResponse(.success(works)):
                state.isLoading = false
                state.works = works
                return .none

            case let .worksResponse(.failure(error)):
                state.isLoading = false
                // TODO: エラーハンドリング
                return .none

            case .createWork:
                let work = Work(
                    title: state.createModalForm.title,
                    summary: state.createModalForm.summary.isEmpty ? nil : state.createModalForm.summary,
                    styleMemo: state.createModalForm.styleMemo.isEmpty ? nil : state.createModalForm.styleMemo,
                    theme: state.createModalForm.theme.isEmpty ? nil : state.createModalForm.theme
                )
                state.works.append(work)
                state.isShowingCreateModal = false
                state.createModalForm = CreateModalFormState()
                return .none

            case let .updateFormTitle(title):
                state.createModalForm.title = title
                return .none

            case let .updateFormSummary(summary):
                state.createModalForm.summary = summary
                return .none

            case let .updateFormStyleMemo(styleMemo):
                state.createModalForm.styleMemo = styleMemo
                return .none

            case let .updateFormTheme(theme):
                state.createModalForm.theme = theme
                return .none
            }
        }
    }
}
```

#### 2. View（UI表示）

```swift
// AppFeature/Sources/WorkListFeature/WorkListView.swift
import ComposableArchitecture
import SwiftUI

public struct WorkListView: View {
    let store: StoreOf<WorkListFeature>

    public init(store: StoreOf<WorkListFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            WorkList(store: store)
                .navigationTitle("作品")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            store.send(.showCreateModal)
                        } label: {
                            Label("新規作成", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: .constant(store.isShowingCreateModal)) {
                    CreateWorkModal(store: store)
                        .presentationDetents([.medium, .large])
                }
        }
    }
}
```

#### 3. Component（詳細UI）

```swift
// AppFeature/Sources/WorkListFeature/Components/WorkList.swift
import AppCore
import SwiftUI

public struct WorkList: View {
    let store: StoreOf<WorkListFeature>

    public var body: some View {
        Group {
            if store.isLoading {
                ProgressView()
            } else if store.works.isEmpty {
                ContentUnavailableView(
                    "作品がありません",
                    systemImage: "book.closed"
                )
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(store.works) { work in
                            WorkCard(work: work)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct WorkCard: View {
    let work: Work

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(work.title)
                .font(.headline)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}
```

### チェックリスト
- [ ] `@Reducer` マクロを適用
- [ ] `@ObservableState` で State を定義
- [ ] `Action` enum をすべてのユーザーアクション用に定義
- [ ] `@Dependency` で外部サービスを注入
- [ ] 全ての Action case を `switch` で処理
- [ ] 非同期処理は `.run` で実装
- [ ] View で `store.send(_:)` を呼び出し

---

## 実装例：Workモデル

### フルフロー実装

#### Step 1: AppCore で Work を定義

```swift
// ✅ AppCore/Sources/AppCore/Models/Work.swift
public struct Work: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    // ...
}
```

#### Step 2: Persistence で Entity・Mapper・Client を実装

```swift
// ✅ Persistance/Sources/Persistance/Models/WorkEntity.swift
@Model final class WorkEntity { /* ... */ }

// ✅ Persistance/Sources/Persistance/Models/WorkMapper.swift
extension WorkEntity {
    func toDomain() -> Work { /* ... */ }
}

// ✅ Persistance/Sources/Persistance/Clients/WorkClient.swift
public struct WorkClient {
    public var fetchWorks: () async throws -> [Work]
}
```

#### Step 3: AppFeature で Reducer・View を実装

```swift
// ✅ AppFeature/Sources/WorkListFeature/WorkListFeature.swift
@Reducer public struct WorkListFeature { /* ... */ }

// ✅ AppFeature/Sources/WorkListFeature/WorkListView.swift
public struct WorkListView: View { /* ... */ }
```

---

## テスト戦略

### 1. AppCore テスト
```swift
// AppCore/Tests/AppCoreTests/WorkTests.swift
import XCTest
import AppCore

final class WorkTests: XCTestCase {
    func testIsRecentWorks() {
        let recentWork = Work(title: "Recent", createdAt: .now)
        XCTAssertTrue(recentWork.isRecent())
    }
}
```

### 2. Persistence テスト
```swift
// Persistance/Tests/PersistanceTests/WorkMapperTests.swift
import XCTest
import AppCore

final class WorkMapperTests: XCTestCase {
    func testEntityToDomainConversion() {
        let entity = WorkEntity(title: "Test")
        let domain = entity.toDomain()
        XCTAssertEqual(domain.title, "Test")
    }
}
```

### 3. AppFeature テスト
```swift
// AppFeature/Tests/AppFeatureTests/WorkListFeatureTests.swift
import ComposableArchitecture
import XCTest

final class WorkListFeatureTests: XCTestCase {
    @MainActor
    func testShowCreateModal() async {
        let store = TestStore(
            initialState: WorkListFeature.State(),
            reducer: { WorkListFeature() }
        )

        await store.send(.showCreateModal) {
            $0.isShowingCreateModal = true
        }
    }
}
```

---

## ベストプラクティス

### 1. 命名規約
- **Entity:** `{名詞}Entity` (e.g., `WorkEntity`)
- **Mapper:** `{Entity}Mapper` 拡張 (e.g., `extension WorkEntity`)
- **Client:** `{名詞}Client` (e.g., `WorkClient`)
- **Feature Reducer:** `{名詞}Feature` (e.g., `WorkListFeature`)
- **View:** `{名詞}View` (e.g., `WorkListView`)

### 2. 依存性注入
```swift
// ❌ NG: 直接初期化
let client = WorkClient()

// ✅ OK: Dependency で注入
@Dependency(\.workListClient) var workListClient
```

### 3. エラーハンドリング
```swift
// ✅ OK: FailureReason で統一
case let .worksResponse(.failure(reason)):
    state.error = reason.message
```

### 4. 状態管理
```swift
// ✅ OK: 状態の副作用は Reducer で管理
case .hideCreateModal:
    state.isShowingCreateModal = false
    state.createModalForm = CreateModalFormState()  // リセット
    return .none
```

### 5. 非同期処理
```swift
// ✅ OK: .run を使って非同期実行
return .run { send in
    let result = try await workListClient.fetchWorks()
    await send(.worksResponse(.success(result)))
}
```

---

## トラブルシューティング

| 問題 | 原因 | 解決方法 |
|------|------|--------|
| `Cannot find type in scope` | import 忘れ | 必要な import を追加 |
| `Type does not conform to Sendable` | Thread-safe でない | `Sendable` に準拠させる |
| `Dependency not found` | DependencyKey 登録忘れ | `extension DependencyValues` で登録 |
| `SwiftData 保存失敗` | Context 操作ミス | `container.mainContext.save()` を呼び出し |

---

## まとめ

### 実装順序
1. **AppCore**: ドメインモデル定義
2. **Persistence**: Entity・Mapper・Client 実装
3. **AppFeature**: Reducer・View 実装

### 各層の職責
| 層 | 責務 | 依存 |
|----|------|-----|
| **AppCore** | ドメインモデル | なし |
| **Persistence** | データ永続化 | AppCore |
| **AppFeature** | UI/UX | Persistence, AppCore |

このガイドに従うことで、保守性の高い、テスト容易な実装が実現できます。
