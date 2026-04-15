# CLAUDE.md

## 開発環境

Nix flake + direnv で管理。`cd` するだけで有効化される。
Nix が uv, ty, just, ruff, gitleaks を提供し、Python 自体は uv が管理する。

## コマンド

```bash
just fix        # ruff check --fix + ty check src
just test       # pytest 実行
just check      # fix + test をまとめて実行
nix fmt         # フォーマット（nixfmt + ruff + oxfmt）
```

## パッケージ管理

- `uv add <package>` で依存を追加（`uv pip install` は使わない）

## コードスタイル

- ruff でリント・フォーマット（行幅 110）
- ty で型チェック（Python 3.12+）
- snake_case でファイル命名
- 絶対 import を使用する
