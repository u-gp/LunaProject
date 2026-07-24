# 09. ビルド・パッケージング

## 1. 概要

Windows 向けに **軽量な exe アプリケーション**としてビルド／配布できること。開発時のデバッグ起動、本番ビルドは `tools/` 配下のバッチから実行する。

## 2. ツールチェイン

| 用途 | ツール |
|------|--------|
| フロント | Node.js + npm + Vite |
| バックエンド | Rust (rustup / cargo) |
| アプリ包装 | Tauri CLI（`tauri build`） |
| 成果物 | NSIS インストーラ（`.exe`）および MSI（任意） |

## 3. 成果物

| 成果物 | 説明 |
|--------|------|
| `Luna_x.y.z_x64-setup.exe` | NSIS インストーラ（Tauri 既定命名に準拠） |
| `Luna.exe` | 実行ファイル本体（バンドル内） |

出力先: `src-tauri/target/release/bundle/`（必要なら `release/` へコピーする運用でも可。プロジェクトで一方に統一）。

配布サイズは Electron 比で大幅に小さくなることを目標とする（WebView2 は OS 側利用）。

## 4. バッチコマンド（tools）

| ファイル | 目的 |
|----------|------|
| `tools/debug.bat` | 開発モード起動（`tauri dev` / HMR） |
| `tools/test.bat` | ユニットテスト（Vitest + `cargo test`） |
| `tools/build.bat` | 本番ビルド＋ Windows exe パッケージ（`tauri build`） |

詳細な呼び出しコマンドはルート `README.md` に記載する。

## 5. 開発・ビルド前提

| 依存 | 用途 |
|------|------|
| Node.js 20+ | フロント依存・Vite |
| Rust stable | Tauri バックエンド |
| Visual Studio Build Tools（C++） | Windows ネイティブビルド |
| WebView2 Runtime | 実行時（通常は OS に含まれる） |

## 6. 外部ランタイムの扱い

Luna 本体 exe に同梱しない／する方針:

| コンポーネント | MVP 方針 |
|----------------|----------|
| Ollama + モデル | 同梱しない。セットアップ手順を README に記載 |
| VOICEVOX Engine | 同梱しない。外部インストール前提 |
| OBS Studio | 同梱しない |
| Whisper バイナリ | 可能なら `src-tauri/resources/` に任意同梱、または別途配置パス設定 |

初回起動時に依存の health check を行い、不足を設定画面で案内する。

## 7. バージョンニング

- `src-tauri/tauri.conf.json` の `version` をアプリ版の正とし、`package.json` と同期する。
- ウィンドウタイトルまたは設定画面に表示する。

## 8. 受け入れ条件

1. `tools/debug.bat` でアプリが起動する。
2. `tools/test.bat` が成功終了する（テスト整備後）。
3. `tools/build.bat` で Windows 向け exe（インストーラ）が生成される。
4. 生成バイナリが Chromium 同梱型（Electron 系）に依存しない。

## 9. 関連仕様

- [01-architecture.md](./01-architecture.md)
- [10-testing.md](./10-testing.md)
