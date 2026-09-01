# AppCore ルール

- SwiftUI、SwiftData、ComposableArchitecture、`Persistance`、`AppFeature` をimportしない。
- Foundationを使う場合も、UIや保存方式の詳細をドメインモデルへ持ち込まない。
- モデルは値型を基本とし、識別子・不変条件・ドメイン上の振る舞いをここに置く。
- 公開モデルは既存の方針に従い、`Equatable`、`Sendable`、`Identifiable` を必要に応じて付ける。
- 日付やUUIDを初期化時に注入できる設計を優先し、テストを不安定にする隠れた現在時刻依存を増やさない。
- ドメインエラーは呼び出し側が扱える型で表現し、表示文言をUI専用の形で固定しない。
- 変更時は `AppCore/Tests` のユニットテストを追加・更新する。
