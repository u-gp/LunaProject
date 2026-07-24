# 05. 音声入出力（STT / VOICEVOX）

## 1. 概要

- **入力**: マイク音声をテキスト化する（STT）。
- **出力**: AI 応答テキストを VOICEVOX で音声合成し、再生する（TTS）。

## 2. 音声入力（STT）

### F-STT-01 エンジン

| 優先 | エンジン | 用途 |
|------|----------|------|
| 1 | Whisper.cpp（ローカル） | 本番・オフライン |
| 2 | Web Speech API | 開発時フォールバック（任意） |

### F-STT-02 操作

- トグル録音、またはプッシュトゥトーク（設定）。
- 録音中インジケータを表示する。
- 認識結果をテキストとして返す。

### F-STT-03 言語

- `stt.language`: `ja` / `en`（既定は UI ロケール）。

### F-STT-04 出力契約

```ts
type SttResult = {
  text: string;
  language: "ja" | "en";
  durationMs: number;
};
```

## 3. 音声出力（VOICEVOX）

### F-TTS-01 接続

- Base URL 既定: `http://127.0.0.1:50021`
- 典型フロー:
  1. `POST /audio_query?text=...&speaker=...`
  2. `POST /synthesis?speaker=...`（body: audio_query JSON）
  3. 返却 WAV を再生

### F-TTS-02 話者設定

- `voicevox.speakerId` を設定 UI から選択できる。
- 話者一覧は `GET /speakers` で取得する。

### F-TTS-03 再生キュー

- 実況モードでは複数発話が連続するため、FIFO キューを持つ。
- デスクトップモードは基本 1 発話。新規応答時は再生中を停止して差し替え可能（設定）。

### F-TTS-04 読み上げテキスト前処理

- マークダウン記号、URL、過度な記号を読み上げ用に正規化する。
- 英語／日本語で正規化ルールを切り替える。

### F-TTS-05 アバター連携イベント

再生開始／終了／ビゼーム（可能なら）を配信する。

```ts
type SpeakEvent = {
  text: string;
  audioDurationMs: number;
  startedAt: number;
};
```

## 4. エラーハンドリング

| 状況 | 挙動 |
|------|------|
| マイク権限なし | 権限要求案内、テキスト入力へ誘導 |
| Whisper バイナリなし | STT 無効＋インストール案内 |
| VOICEVOX 未起動 | TTS スキップ、テキストは表示 |
| 合成失敗 | エラーログ＋トースト |

## 5. 受け入れ条件

1. 日本語・英語それぞれで音声入力 → テキスト化ができる。
2. VOICEVOX で応答を読み上げできる。
3. VOICEVOX 停止時もテキスト対話は継続できる。
4. 実況連続時に音声が無秩序に重ならない（キュー制御）。

## 6. 関連仕様

- [02-desktop-agent.md](./02-desktop-agent.md)
- [03-obs-commentary.md](./03-obs-commentary.md)
- [06-avatar-3d.md](./06-avatar-3d.md)
