# 2026-11-15 skills/CLAUDE.md のトークン軽量化

## やったこと
- 4 skill の description を圧縮（1,548B → 1,019B）。safe-rollback はトリガー語 10 個を意図的に厚めに残した。
- safe-rollback を分割: SKILL.md（大原則・固有の注意点・Step 1〜3・切り分け表）＋ `references/branches.md`（Step 4-A〜4-G）。
- CLAUDE.md の 5 つの完了条件とループ上限の再掲をフェーズ表に統合（4,524B → 3,916B）。
- 検証: 旧ファイルの shell コマンド 33 件すべてが新構成に残存することを `grep -F` で機械確認。

## 詰まった点 / 解決方法
- **hook は heredoc の中身にも反応する。** `cat > SKILL.md` のヒアドキュメント本文に
  「禁止コマンドを説明する文字列」（履歴を消す git 操作の例）が含まれていたため
  deny_dangerous_bash.py にブロックされた。2 回踏んだ。
  → safe-rollback 系のドキュメントを書くときは Bash heredoc ではなく Write ツールを使う。
- 数値目標 2 件（description 合計 500B 以下 / SKILL.md 6KB 以下）は未達。前者は「トリガー語を厚めに」
  という指示変更、後者は「固有の注意点は行動前に必ず読ませる」判断で SKILL.md 側に残したため。

## 次回への申し送り・知見
- 常時プロンプトに載るのは **description と CLAUDE.md だけ**。本体の肥大より description の肥大が高くつく。
- 分量の多い skill は「判断に必要な情報＝SKILL.md / 分岐ごとの手順＝references」で分けると発動時も軽い。
- `.claude/settings.local.json` はセッション固有パスを含むのでコミット対象外（`.gitignore` に追加済み）。
