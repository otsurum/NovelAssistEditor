# AppFeature ルール

- TCAのFeatureはState・Action・Dependency・Reducerの責務を分け、Viewにビジネスロジックを置かない。
- 非同期処理や外部副作用はDependency経由のEffectで実行し、成功・失敗・キャンセルをActionとして扱う。
- Feature間の連携はscopeとdelegate actionを使い、親Reducerが状態の整合性を保つ。
- SwiftUI Viewは表示とユーザー入力の配線に集中させ、`ModelContext` や永続化Clientを直接生成しない。
- Viewで必要な状態はStoreから取得し、ローカルUI状態と永続化対象の状態を混同しない。
- 既存のFeature命名・ファイル構成・`public` APIの方針に従う。
- Reducerの分岐、非同期結果、キャンセル、delegate連携には必要なテストを追加・更新する。
- UI文言は既存の日本語UIに合わせ、アクセシビリティラベルと操作結果の表示を壊さない。
