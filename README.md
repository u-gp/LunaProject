# Luna

Windows 向けローカル LLM エージェントアプリケーション。  
**Gemma 4**（ローカル）を中核に、調べ物・考察の対話補助と、OBS Studio 連携による自動実況を行う。

応答はテキストと **VOICEVOX** 音声で出力し、**FBX / VRM** の 3D アバターを発話に連動させる。

> 現状: 仕様策定フェーズ。実装コードは今後追加する。詳細仕様は [`plan/`](./plan/) を参照。  
> アプリシェルは **Tauri 2**（Electron は採用しない）。

## 主な用途

1. **デスクトップ常駐エージェント**  
   音声またはテキストで調べ物・考察を補助する。
2. **OBS 連動実況エージェント**  
   OBS の映像リソースを監視し、内容を自動実況し続ける。

## 技術スタック

| 領域 | 技術 |
|------|------|
| アプリ | **Tauri 2** + React + TypeScript |
| バックエンド | Rust |
| フロントバンドル | Vite |
| 配布 | `tauri build`（Windows exe / NSIS） |
| 3D | Three.js + `@pixiv/three-vrm` |
| LLM | Ollama 等（OpenAI 互換ローカル API）、想定モデル Gemma 4 |
| TTS | VOICEVOX Engine |
| STT | Whisper.cpp（ローカル） |
| OBS | obs-websocket v5 |
| テスト | Vitest（フロント）+ `cargo test`（Rust） |

Electron を使わない理由: Chromium 同梱によるサイズ・メモリ負荷が大きく、常駐アプリ向きでないため。Tauri は OS の WebView2 を利用する。

## プロジェクト構成

```
LunaProject/
├── README.md                 # 本ファイル
├── plan/                     # 仕様書（機能単位）
│   ├── README.md             # 仕様インデックス
│   ├── 00-overview.md
│   ├── 01-architecture.md
│   ├── 02-desktop-agent.md
│   ├── 03-obs-commentary.md
│   ├── 04-llm-integration.md
│   ├── 05-voice-io.md
│   ├── 06-avatar-3d.md
│   ├── 07-i18n.md
│   ├── 08-ui-shell.md
│   ├── 09-build-packaging.md
│   └── 10-testing.md
├── tools/                    # 開発用バッチ
│   ├── debug.bat             # デバッグ起動
│   ├── test.bat              # ユニットテスト
│   └── build.bat             # 本番ビルド / exe パッケージ
├── src/                      # React UI（WebView）
│   ├── avatar/               # Three.js / VRM・FBX
│   ├── i18n/
│   ├── components/
│   └── lib/                  # フロント寄りの純ロジック
├── src-tauri/                # Tauri / Rust コア
│   ├── src/
│   │   ├── main.rs
│   │   ├── agent/
│   │   ├── llm/
│   │   ├── voice/
│   │   ├── obs/
│   │   └── config/
│   ├── capabilities/
│   ├── Cargo.toml
│   └── tauri.conf.json
├── resources/                # 同梱リソース（アイコン、任意バイナリ等）
├── package.json
├── vite.config.ts
└── release/                  # 任意: 配布用コピー先
```

## 仕様書

機能単位の仕様は `plan/` 配下に分割している。起点は [plan/README.md](./plan/README.md)。

| 文書 | 内容 |
|------|------|
| [00-overview](./plan/00-overview.md) | 概要・要件・非目標 |
| [01-architecture](./plan/01-architecture.md) | アーキテクチャ・技術選定 |
| [02-desktop-agent](./plan/02-desktop-agent.md) | デスクトップ常駐エージェント |
| [03-obs-commentary](./plan/03-obs-commentary.md) | OBS 自動実況 |
| [04-llm-integration](./plan/04-llm-integration.md) | ローカル LLM |
| [05-voice-io](./plan/05-voice-io.md) | 音声入力 / VOICEVOX |
| [06-avatar-3d](./plan/06-avatar-3d.md) | FBX/VRM アバター |
| [07-i18n](./plan/07-i18n.md) | 日本語・英語 |
| [08-ui-shell](./plan/08-ui-shell.md) | UI / トレイ |
| [09-build-packaging](./plan/09-build-packaging.md) | exe ビルド |
| [10-testing](./plan/10-testing.md) | テスト方針 |

## 必要環境

### 実行時

| 依存 | 用途 | 備考 |
|------|------|------|
| Windows 10/11 | 実行 OS | |
| WebView2 Runtime | UI ホスト | 通常は OS に含まれる |
| Ollama 等 | ローカル LLM | Gemma 4 相当モデルをロード |
| VOICEVOX Engine | 音声合成 | 既定 `http://127.0.0.1:50021` |
| OBS Studio + obs-websocket v5 | 実況モード | 実況利用時のみ必須 |

### 開発時

| 依存 | 用途 |
|------|------|
| Node.js 20+ | フロント |
| Rust stable（rustup） | Tauri バックエンド |
| Visual Studio Build Tools（C++） | ネイティブビルド |

## 開発コマンド

実装導入後は、リポジトリルートで以下を使用する。

### デバッグ起動

```bat
tools\debug.bat
```

Vite + Tauri 開発モードで起動する（ホットリロード想定）。

### ユニットテスト

```bat
tools\test.bat
```

Vitest（フロント）と `cargo test`（Rust）を実行する。

### 本番ビルド（exe）

```bat
tools\build.bat
```

`tauri build` で Windows 向け exe（NSIS インストーラ）を生成する。成果物は `src-tauri/target/release/bundle/` を確認する。

## 対応言語

- UI: 日本語 / 英語
- エージェント応答・実況: ロケールに追従

## ライセンス

未定（実装開始時に確定）。

## 今後の実装順（推奨）

1. Tauri 2 + React スケルトン、設定、i18n
2. LLM クライアント＋デスクトップ対話
3. VOICEVOX / STT
4. アバター（VRM 口パク）
5. OBS 実況モード
6. テスト拡充と exe パッケージング仕上げ
