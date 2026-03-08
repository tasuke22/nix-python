# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Development Environment

Nix flake で開発環境を管理している。`cd` するだけで direnv 経由で自動的に有効化される。

### 開発ツール（Nix が提供）

| ツール   | 用途                        |
| -------- | --------------------------- |
| uv       | Python パッケージマネージャ |
| ty       | 型チェッカー                |
| just     | タスクランナー              |
| ruff     | リンター＆フォーマッター    |
| gitleaks | 秘密情報漏洩チェック        |

Python 自体は uv が管理するので Nix には含めていない。

### Treefmt（`nix fmt`）

| フォーマッター | 対象          |
| -------------- | ------------- |
| nixfmt         | .nix ファイル |
| ruff-check     | Python lint   |
| ruff-format    | Python format |
| oxfmt          | Markdown      |

### Pre-commit Hooks（git-hooks.nix）

| フック   | 内容                                         |
| -------- | -------------------------------------------- |
| gitleaks | ステージングされたファイルの秘密情報チェック |
| treefmt  | 自動フォーマット                             |
| ty       | `src/` の型チェック                          |

`nix develop` 時に自動インストールされる。`.pre-commit-config.yaml` は自動生成されるので手動編集しない。

## コマンド

```bash
just check      # ty check + ruff check --fix
just test       # pytest 実行
just coverage   # テスト + カバレッジ
just lint       # nix fmt --fail-on-change（チェックのみ）
just fix        # ruff check --fix + nix fmt
just format     # nix fmt
just ty         # ty check src
just build      # uv build
just install    # uv sync
```

## パッケージ管理

- `uv add <package>` で依存を追加する
- `uv add --dev <package>` で開発依存を追加する
- `uv pip install` は使わない

## プロジェクト構造

- `src/` — ソースコード
- `tests/` — テスト（pytest）
- `flake.nix` — Nix 開発環境の定義
- `pyproject.toml` — Python プロジェクト設定
- `.envrc` — direnv 設定（`watch_file uv.lock` + `use flake`）
- `.gitleaks.toml` — gitleaks 設定

## コードスタイル

- ruff でリント・フォーマット（行幅 110）
- ty で型チェック（Python 3.12+）
- snake_case でファイル命名
- 絶対 import を使用する
