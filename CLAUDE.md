# flutter_kotlin

FlutterからKotlin(Android)を呼び出す方法を学ぶための学習用プロジェクト。

## 構成

- `lib/main.dart` — Dart側。`MethodChannel` でKotlinを呼ぶUI
- `android/app/src/main/kotlin/com/example/flutter_kotlin/MainActivity.kt` — Kotlin側。`configureFlutterEngine` でハンドラ登録
- チャンネル名: `com.example.flutter_kotlin/native`(Dart/Kotlin双方で一致させる)

## コマンド

- 実行: `flutter run`
- 静的解析: `flutter analyze`
- テスト: `flutter test`(MethodChannelはモックで検証)

## 方針

- 対象プラットフォームは Android のみ
- 学習用なので、コード内コメントは日本語で「なぜそうするか」を書く
- 新しいネイティブ機能は、まず Kotlin の `when (call.method)` に分岐を追加し、Dart側に呼び出しを追加する
- Kotlin側のエラーは `result.error(...)` で返し、Dart側で `PlatformException` として受ける
