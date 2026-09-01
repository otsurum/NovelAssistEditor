# Persistance ルール

- SwiftDataの具体的な実装はこのレイヤーに閉じ込める。
- `@Model` Entityは永続化の都合を表し、AppCoreのドメインモデルをそのままEntityにしない。
- EntityとDomain Modelの変換はMapperへ集約する。ViewやReducerからEntityを直接参照させない。
- Featureへ公開する操作はClientとして定義し、`ModelContext` を上位層へ漏らさない。
- 保存・取得・更新・削除の失敗は握りつぶさず、既存のエラー方針に合わせて呼び出し側へ返す。
- `@MainActor` や共有Containerが必要な場合は、SwiftDataの実行コンテキストを明示する。
- スキーマ変更では既存データとの互換性とMigrationの要否を確認する。
- 変更時は `Persistance/Tests` のテストを追加・更新する。
