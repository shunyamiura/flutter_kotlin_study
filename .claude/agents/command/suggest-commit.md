---
description: GitHub コミットメッセージ作成
allowed-tools: Bash(git add:*), Bash(git commit:*), Bash(git status:*)
---

# プロンプト

1. 先に `security-checker` サブエージェントを実行し、個人PCのパス・ユーザー名・メールアドレス・秘密情報が差分に混入していないか確認してください(`CLAUDE.md`の「コミット時のルール」)。
   判定が「NG」の場合は、指摘内容を報告して中断し、コミットメッセージは提案しないでください。
2. 「OK」なら、mainブランチとの差分を確認し、適切なコミットメッセージを提案してください。
