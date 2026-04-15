# nix-python プロジェクト構成

## ディレクトリ構造

```
nix-python/
├── flake.nix          # Nix 開発環境の定義
├── flake.lock         # Nix 依存のロックファイル
├── .envrc             # direnv 設定
├── pyproject.toml     # Python プロジェクト設定
├── uv.lock            # Python 依存のロックファイル
├── justfile           # タスクランナー
├── actrun.toml        # actrun ローカル CI 設定
├── .gitignore         # Git 除外設定
├── src/
│   └── __init__.py    # ソースコード置き場
└── tests/
    └── __init__.py    # テスト置き場
```

---

## Nix と Python の責任分担

```
Nix（flake.nix + flake.lock）
  → 開発ツール（uv, ty, just, ruff）
  → フォーマッター設定（treefmt）
  → pre-commit フック

Python（pyproject.toml + uv.lock）
  → Python ランタイム
  → ライブラリ依存（pytest など）
  → .venv 内のすべて
```

Nix は「開発環境の箱」を提供し、Python の依存管理は uv に任せる。

---

## 各ファイルの詳細

### flake.nix

このファイル1つに4つの役割が集約されている。

#### inputs — Nix 側の依存

| input       | 役割                                             |
| ----------- | ------------------------------------------------ |
| nixpkgs     | uv, ty, just, ruff など全パッケージの供給元      |
| flake-parts | flake の構造化（perSystem で OS ごとに自動分岐） |
| git-hooks   | pre-commit フックの Nix 管理                     |
| treefmt-nix | 複数言語のフォーマッターを統合                   |

#### devShell — 開発ツールの提供

| ツール | 役割                        |
| ------ | --------------------------- |
| uv     | Python パッケージマネージャ |
| ty     | 型チェッカー                |
| just   | タスクランナー              |
| ruff   | リンター＆フォーマッター    |

`cd` するだけでこの4つが使える。Python 自体は uv が管理するので Nix には含めていない。

#### treefmt — フォーマッター

| プログラム  | 対象                  |
| ----------- | --------------------- |
| nixfmt      | .nix ファイル         |
| ruff-check  | Python の lint        |
| ruff-format | Python のフォーマット |
| oxfmt       | Markdown（\*.md）     |

`nix fmt` 一発で Nix も Python も Markdown もまとめてフォーマットされる。

#### git-hooks — pre-commit フック

| フック   | 内容                                         |
| -------- | -------------------------------------------- |
| gitleaks | ステージングされたファイルの秘密情報チェック |
| treefmt  | コミット時に自動フォーマット                 |
| ty       | コミット時に `src/` の型チェック             |

`git commit` すると自動実行。チェックが通らないとコミットできない。

#### shellHook — 環境に入った時の自動処理

- `.venv` がなければ `uv sync` で Python 依存を自動インストール
- `uv.lock` が `.venv` より新しければ再同期
- pre-commit フックを `.git/hooks/` にインストール

### flake.lock

inputs の正確なリビジョン（コミットハッシュ）を記録。
誰がいつ `nix develop` しても同じバージョンのツールが手に入る。
`nix flake update` で更新。

### .envrc

```
watch_file uv.lock
use flake
```

- `use flake` → `cd` すると自動で devShell を有効化
- `watch_file uv.lock` → `uv.lock` が変わったら環境を再読み込み

初回のみ `direnv allow` が必要。

### pyproject.toml

Nix とは独立した、純粋な Python プロジェクト設定。

| セクション                | 役割                                                  |
| ------------------------- | ----------------------------------------------------- |
| `[project]`               | パッケージ名、バージョン、Python バージョン要件、依存 |
| `[build-system]`          | ビルドバックエンド（hatchling）                       |
| `[dependency-groups] dev` | 開発用依存（pytest, pytest-cov）                      |
| `[tool.pytest]`           | テスト設定（テストディレクトリの指定）                |
| `[tool.ruff]`             | リンター設定（行幅 110、有効ルール）                  |

### uv.lock

`pyproject.toml` の依存を解決した結果。`uv sync --locked` で再現可能。

### justfile

| コマンド     | 実行内容                                |
| ------------ | --------------------------------------- |
| `just fix`   | `ruff check --fix` + `ty check src`     |
| `just test`  | `uv run pytest`（テスト実行）           |
| `just check` | `just fix` + `just test` をまとめて実行 |

### .gitignore

| パターン                                    | 除外対象                                      |
| ------------------------------------------- | --------------------------------------------- |
| `.env`, `.env.*`                            | 環境変数ファイル（秘密情報）                  |
| `.venv`                                     | Python 仮想環境（uv が管理）                  |
| `.direnv`                                   | direnv のキャッシュ                           |
| `__pycache__`, `.pytest_cache`, `.coverage` | Python 実行時の生成物                         |
| `dist/`, `build/`, `*.egg-info`             | ビルド成果物                                  |
| `.pre-commit-config.yaml`                   | git-hooks.nix が自動生成するので Git 管理不要 |

---

## 日常の使い方

```bash
# 初回セットアップ
cd nix-python
direnv allow          # 以降は cd するだけで環境が有効

# 開発
just check            # fix + test を一括実行
just fix              # ruff fix + 型チェック
just test             # テスト実行

# 依存の追加
uv add httpx          # ライブラリ追加
uv add --dev mypy     # 開発依存の追加

# Nix 側の更新
nix flake update      # 全 input を最新に更新
nix flake update nixpkgs  # nixpkgs だけ更新
```

### 開発ツールのバージョン更新

uv, ty, just, ruff はすべて nixpkgs から提供されている。
`nix flake update` で nixpkgs を更新すれば、これらも nixpkgs 時点の最新バージョンに上がる。

- 全ツールが一括更新される（特定ツールだけの更新はできない）
- nixpkgs への取り込みにはラグがあるため、PyPI/GitHub の最新版とは限らない
- 問題があれば `git checkout flake.lock` で戻せる
