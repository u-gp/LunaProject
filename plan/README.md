# Luna 仕様書インデックス

本ディレクトリは、Windows 向けローカル LLM エージェントアプリ **Luna** の仕様書を機能単位で分割して管理する。

## 仕様書一覧

| 番号 | ファイル | 概要 |
|------|----------|------|
| 00 | [00-overview.md](./00-overview.md) | プロダクト概要・目標・非目標・用語定義 |
| 01 | [01-architecture.md](./01-architecture.md) | システム構成・技術スタック・モジュール境界 |
| 02 | [02-desktop-agent.md](./02-desktop-agent.md) | デスクトップ常駐エージェント（調べ物・考察補助） |
| 03 | [03-obs-commentary.md](./03-obs-commentary.md) | OBS Studio 連携・映像監視・自動実況 |
| 04 | [04-llm-integration.md](./04-llm-integration.md) | ローカル LLM（Gemma 4 想定）連携 |
| 05 | [05-voice-io.md](./05-voice-io.md) | 音声入力（STT）・VOICEVOX 音声出力 |
| 06 | [06-avatar-3d.md](./06-avatar-3d.md) | FBX/VRM 3D モデル読込・発話連動 |
| 07 | [07-i18n.md](./07-i18n.md) | 日本語・英語対応 |
| 08 | [08-ui-shell.md](./08-ui-shell.md) | ウィンドウ・トレイ・設定 UI |
| 09 | [09-build-packaging.md](./09-build-packaging.md) | exe ビルド・パッケージング |
| 10 | [10-testing.md](./10-testing.md) | ユニットテスト方針・カバレッジ |

## 仕様の読み方

1. まず `00-overview.md` でプロダクト範囲を把握する。
2. `01-architecture.md` で全体のモジュール分割と依存関係を確認する。
3. 実装対象の機能仕様（`02` 以降）を個別に参照する。
4. テスト・ビルドは `09` / `10` およびリポジトリ直下 `README.md`・`tools/` を参照する。

## 変更ルール

- 機能追加・仕様変更時は、該当する機能単位ファイルを更新する。
- 横断的な変更（技術スタック変更など）は `01-architecture.md` を先に更新する。
- 仕様番号（`00`〜`10`）は原則固定し、新規機能は `11` 以降を追加する。
