# 01. アーキテクチャ

## 1. 技術スタック選定

Windows 上で **軽量な** exe 配布・3D 表示・OBS 連携・ユニットテストを両立するため、以下を採用する。

| レイヤ | 技術 | 選定理由 |
|--------|------|----------|
| アプリシェル | **Tauri 2** | OS 標準 WebView2 を利用し、Chromium 同梱の Electron より遥かに軽量。Windows exe 配布・トレイ・ホットキーに対応 |
| UI | React + TypeScript | コンポーネント指向、テスト容易性 |
| バックエンド | Rust（Tauri commands / イベント） | ネイティブ性能、外部プロセス連携、小さなバイナリ |
| フロントバンドル | Vite | 高速開発・HMR |
| 配布 | `tauri build`（NSIS / MSI） | Windows インストーラ／exe 出力 |
| 3D | Three.js + `@pixiv/three-vrm` | VRM 標準サポート、FBX は Three.js ローダで対応 |
| ローカル LLM | Ollama（推奨） / OpenAI 互換 HTTP API | Gemma 系モデルをローカル起動しやすい |
| 音声合成 | VOICEVOX Engine（HTTP） | 要件準拠、ローカル完結 |
| 音声認識 | Whisper.cpp（ローカル）または Web Speech API（開発フォールバック） | オフライン優先 |
| OBS 連携 | obs-websocket（v5） | 公式プロトコル、ソース取得・制御 |
| テスト | Vitest（フロント）+ `cargo test`（Rust） | レイヤ別に単体検証 |
| 状態管理 | Zustand（または同等の軽量ストア） | モード切替・設定の単純管理 |

### 1.1 Electron を採用しない理由

- Chromium ランタイム同梱により配布サイズ・メモリ使用量が大きい。
- Luna は常駐・実況用途のため、常時メモリコストを抑える必要がある。
- Tauri は WebView2（Windows に標準的に存在する）を使い、本体バイナリを小さく保てる。

## 2. 論理構成

```
┌─────────────────────────────────────────────────────────┐
│                   WebView (React + Vite)                 │
│  ChatUI / CommentaryUI / AvatarViewport / Settings       │
└───────────────┬─────────────────────────┬───────────────┘
                │ Tauri IPC (invoke/event) │
┌───────────────▼─────────────────────────▼───────────────┐
│                   Rust Core (Tauri)                      │
│  AppShell / Tray / WindowManager / ConfigStore           │
│  AgentOrchestrator                                       │
│    ├─ DesktopAgentService                                │
│    └─ CommentaryAgentService                             │
│  LLMClient / STTService / VOICEVOXClient / OBSClient     │
│  AvatarBridge (発話イベント配信)                           │
└───────────────┬──────────┬──────────┬──────────┬────────┘
                │          │          │          │
         ┌──────▼──┐  ┌────▼────┐ ┌──▼───┐ ┌───▼────┐
         │ Ollama  │  │VOICEVOX │ │ OBS  │ │Whisper │
         │ (LLM)   │  │ Engine  │ │ WS   │ │ (STT)  │
         └─────────┘  └─────────┘ └──────┘ └────────┘
```

## 3. モジュール境界

| モジュール | 責務 | 配置（予定） |
|------------|------|--------------|
| `ui` | React UI・アバター描画 | `src/` |
| `tauri-app` | ウィンドウ／トレイ／起動エントリ | `src-tauri/src/` |
| `agent` | エージェント制御・プロンプト組み立て | `src-tauri/src/agent/`（コア）＋必要なら `src/lib/agent/` |
| `llm` | LLM API クライアント | `src-tauri/src/llm/` |
| `voice` | STT / TTS クライアント | `src-tauri/src/voice/` |
| `obs` | OBS WebSocket クライアント | `src-tauri/src/obs/` |
| `avatar` | モデル読込・アニメーション制御 | `src/avatar/` |
| `i18n` | 文言・ロケール | `src/i18n/` |
| `config` | 設定スキーマ・永続化 | `src-tauri/src/config/` |

フロントに置くロジック（表示整形・i18n・アバター）と、Rust に置くロジック（外部 I/O・オーケストレーション・秘密情報）を明確に分離する。

## 4. プロセスモデル

- **Rust Core**: 外部プロセス通信（LLM / VOICEVOX / OBS / STT）、エージェントオーケストレーション、設定永続化、トレイ／ウィンドウ制御。
- **WebView (React)**: UI、Three.js シーン、ユーザー操作。音声再生は WebView 側を基本とし、合成 WAV は Rust から受け取る（詳細は `05-voice-io.md`）。
- **IPC**: `invoke`（コマンド）と `emit`（イベント）のみを公開。フロントから任意の OS API を直接叩かない。

## 5. モード管理

アプリは同時に 1 つの主モードを持つ。

| モード | 説明 |
|--------|------|
| `desktop` | 対話エージェント（UC-1） |
| `commentary` | OBS 実況（UC-2） |
| `idle` | 待機（起動直後・設定中） |

モード切替時は進行中のエージェントジョブをキャンセルし、音声再生を停止する。

## 6. 設定・永続化

- 設定ファイル: `%APPDATA%/Luna/config.json`（スキーマは `config` モジュールで定義）
- ログ: `%APPDATA%/Luna/logs/`
- モデルキャッシュパス等は設定で上書き可能

主要設定キー（抜粋）:

- `locale`: `ja` | `en`
- `llm.baseUrl`, `llm.model`
- `voicevox.baseUrl`, `voicevox.speakerId`
- `stt.engine`, `stt.language`
- `obs.host`, `obs.port`, `obs.password`, `obs.sourceName`
- `avatar.modelPath`, `avatar.format` (`vrm` | `fbx`)
- `commentary.intervalMs`, `commentary.maxTokens`

## 7. 外部依存（ランタイム）

| 依存 | 必須 | 備考 |
|------|------|------|
| WebView2 Runtime | 必須 | Windows 10/11 では通常利用可能。未導入時は案内 |
| Ollama（または互換 LLM サーバー） | 必須 | Gemma 4 相当モデルをロード済みであること |
| VOICEVOX Engine | 必須 | 既定 `http://127.0.0.1:50021` |
| OBS Studio + obs-websocket | 実況モード時必須 | v5 想定 |
| Whisper 実行バイナリ | 音声入力利用時 | 配布形態は `09-build-packaging.md` 参照 |

## 8. セキュリティ方針

- フロントから外部 HTTP へ直接アクセスせず、原則 Rust コマンド経由とする（CORS／秘密情報保護）。
- OBS パスワード、API キー類は平文ログに出さない。
- ローカル専用のため、リモート公開ポートはデフォルトで開かない。
- Tauri の CSP / capability（権限）を最小権限で設定する。

## 9. 関連仕様

- [00-overview.md](./00-overview.md)
- [04-llm-integration.md](./04-llm-integration.md)
- [09-build-packaging.md](./09-build-packaging.md)
