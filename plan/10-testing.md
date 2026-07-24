# 10. テスト方針

## 1. 概要

ユニットテストを完備し、回帰を防ぐ。実行は `tools/test.bat` から行う。

## 2. テストスタック

| 項目 | 選定 |
|------|------|
| フロント | Vitest + Testing Library（React） |
| Rust | `cargo test` |
| HTTP モック | フロントは MSW 等、Rust は `mockito` / `wiremock` 等 |

## 3. テスト対象（必須）

| 領域 | 例 | 実行環境 |
|------|----|----------|
| LLM クライアント | リクエスト組み立て、エラー写像、ストリーム連結 | Rust |
| VOICEVOX クライアント | audio_query → synthesis フロー、失敗時挙動 | Rust |
| OBS クライアント | 接続パラメータ、スクリーンショット応答パース | Rust |
| エージェント | プロンプト組み立て、履歴トリム、モード別差分 | Rust |
| 設定 | スキーマバリデーション、デフォルトマージ | Rust |
| 読み上げ前処理 | 記号除去、言語別正規化 | Rust または TS |
| 実況キュー | Enqueue / 破棄ポリシー | Rust |
| i18n | キー解決、フォールバック | TS |
| UI 部品 | 入力送信、モード表示の薄い結合 | TS |

## 4. UI / ネイティブ境界

- 純粋 UI はロジック分離を優先し、コンテナの薄い結合テストに留める。
- Tauri コマンド境界は、ビジネスロジックをプレーンな Rust 関数に抽出し `cargo test` で検証する（ウィンドウ起動が必要なテストは MVP 対象外）。

## 5. 非対象（MVP）

- 実機 OBS / 実機 VOICEVOX / 実モデル推論を要する E2E（将来追加）。
- 3D GPU 描画のピクセル完全一致テスト。
- WebView 実機操作の自動 UI E2E。

## 6. カバレッジ目標

- Rust のコア（`agent` / `llm` / `voice` / `obs` / `config`）を中心にラインカバレッジ **80% 以上** を目標とする。
- フロントの `src/lib/**`・`src/i18n/**` も同様に重視する。

## 7. テスト配置

```
src/**/*.test.ts
src/**/*.test.tsx
src-tauri/src/**/*_test 相当（Rust の #[cfg(test)] / tests/）
src-tauri/tests/*.rs      # 統合寄りの Rust テスト（任意）
```

## 8. CI（将来）

- GitHub Actions 等で `npm test` と `cargo test` を実行可能にする（初期はローカルバッチ必須）。

## 9. 受け入れ条件

1. 主要モジュールにユニットテストが存在する。
2. `tools/test.bat` が非対話で完走する（フロント＋ Rust）。
3. 外部サービスはモックされ、オフラインでテスト可能。

## 10. 関連仕様

- [01-architecture.md](./01-architecture.md)
- [09-build-packaging.md](./09-build-packaging.md)
