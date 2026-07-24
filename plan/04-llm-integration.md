# 04. ローカル LLM 連携

## 1. 概要

Luna の推論バックエンドとしてローカル LLM を利用する。想定モデルは **Gemma 4**（および互換のローカル配信形態）。クラウド必須依存は持たない。

## 2. 接続方式

### 推奨: Ollama OpenAI 互換 API

- Base URL 既定: `http://127.0.0.1:11434`
- エンドポイント例:
  - `POST /api/chat`（Ollama ネイティブ）
  - または `POST /v1/chat/completions`（互換レイヤ）
- モデル名は設定 `llm.model` で指定（例: `gemma4` / 実際のタグ名）

### 代替

- LM Studio / llama.cpp server 等、OpenAI 互換 Chat Completions を提供するローカルサーバー。

## 3. 機能要件

### F-LLM-01 クライアント抽象

- `LLMClient` インタフェースを定義し、実装差し替え可能にする。
- 必須メソッド:
  - `healthCheck(): Promise<boolean>`
  - `listModels(): Promise<string[]>`
  - `chat(messages, options): Promise<ChatResult>`
  - `chatStream(messages, options): AsyncIterable<string>`

### F-LLM-02 メッセージモデル

```ts
type Role = "system" | "user" | "assistant";

type ContentPart =
  | { type: "text"; text: string }
  | { type: "image"; mimeType: string; dataBase64: string };

type ChatMessage = {
  role: Role;
  content: string | ContentPart[];
};
```

### F-LLM-03 ストリーミング

- デスクトップモードはストリーミング表示を推奨。
- 実況モードは短文一括生成を既定とし、ストリームは任意。

### F-LLM-04 パラメータ

| 項目 | 既定 | 説明 |
|------|------|------|
| `temperature` | 0.7（対話）/ 0.8（実況） | 設定で変更可 |
| `maxTokens` | モード別 | 実況は短め |
| `timeoutMs` | 60000 | 超過でエラー |

### F-LLM-05 マルチモーダル（実況）

- Gemma 4 ビジョン対応ビルドがある場合: フレーム画像を `image` part として送信。
- 非対応時のフォールバック:
  1. 別ビジョンモデルでキャプション生成 → テキストのみ Gemma に渡す。
  2. または実況モードでビジョン必須エラーを表示し、設定で代替モデルを要求。

MVP では「画像入力対応モデルを設定する」か「キャプションパイプラインを有効化」のいずれかを選択可能にする。

## 4. プロンプト管理

- システムプロンプトは `src/shared/agent/prompts/` にロケール別で配置する。
- モード別テンプレート:
  - `desktop.research`
  - `desktop.thinking`
  - `commentary.live`

## 5. エラー分類

| コード | 意味 | UI 表示 |
|--------|------|---------|
| `LLM_UNREACHABLE` | サーバー未起動等 | 接続先確認を促す |
| `LLM_MODEL_MISSING` | モデル未取得 | pull／モデル名確認 |
| `LLM_TIMEOUT` | 時間超過 | 再試行 |
| `LLM_INVALID_RESPONSE` | 応答パース失敗 | ログ付きエラー |

## 6. 受け入れ条件

1. 設定したローカルエンドポイントでチャット応答を得られる。
2. モデル未配置時に明確なエラーになる。
3. デスクトップ／実況で異なるシステムプロンプトが適用される。
4. ユニットテストでクライアントのリクエスト組み立て・エラー写像を検証できる。

## 7. 関連仕様

- [02-desktop-agent.md](./02-desktop-agent.md)
- [03-obs-commentary.md](./03-obs-commentary.md)
- [10-testing.md](./10-testing.md)
