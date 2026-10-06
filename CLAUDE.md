# flutter_kotlin

FlutterからKotlin(Android)を呼び出す方法を学ぶための学習用プロジェクト。

## 構成

- `lib/main.dart` — エントリ。`ProviderScope` + `MaterialApp.router`
- `lib/router.dart` — go_router のルート定義(`/` と `/round-trip`)
- `lib/core/` — 複数ページで共有するもの(MethodChannel名など)
- `lib/features/<ページ名>/` — **ページ(機能)ごとにディレクトリを分ける**
  - `pages/` — 画面(Widget)
  - `widgets/` — そのページ専用の部品
  - `providers/` — Provider と Notifier
  - `state/` — 状態・結果クラス
  - `services/` — MethodChannelを呼ぶサービス
  - 現在のページ: `native_call`(単発呼び出し)、`round_trip`(往復処理。Kotlin → Dart のハンドラは `RoundTripService`)
- `test/features/<ページ名>/` — `lib` と同じ構成でテストを置く
- `android/app/src/main/kotlin/com/example/flutter_kotlin/plugins/` — Kotlin側。**プラグインと同じ構造**(`FlutterPlugin` + `MethodCallHandler`)で、機能ごとに1プラグイン
  - `NativeCallPlugin.kt` / `RoundTripPlugin.kt` — 各機能のプラグイン
  - `MethodChannelExt.kt` — `invokeMethodAwait`(Flutterの戻り値を suspend で待つ拡張関数)
- `MainActivity.kt` — `configureFlutterEngine` で `flutterEngine.plugins.add(...)` して自作プラグインを登録するだけ
- チャンネル名: 機能ごとに別名(`.../native_call`、`.../round_trip`)。Dartは `lib/core/native_channel.dart`、Kotlinは各プラグインの `CHANNEL_NAME` で一致させる。同名チャンネルに複数ハンドラを登録すると後勝ちで上書きされるため、共有しない

## コマンド

- 実行: `flutter run`
- 静的解析: `flutter analyze`
- テスト: `flutter test`(MethodChannelはモックで検証)

## Dartコーディング規約

- [Effective Dart](https://dart.dev/effective-dart) に従う(命名、`///` ドキュメントコメント、`lib` 内は相対 import など)
- 状態クラス・モデル・サービスなどのクラスは **1ファイルに1つ**(ファイル名は `snake_case` でクラス名に対応)
- Provider ファイルでは、**Provider の定義を上、その Notifier クラスを下**に書く
- 新しいページは `features/<ページ名>/` を作り、`pages` / `providers` / `state` / `services` に分けて置く
- 整形は `dart format`、静的解析は `flutter analyze` を通すこと

## 方針

- 対象プラットフォームは Android のみ
- 学習用なので、コード内コメントは日本語で「なぜそうするか」を書く
- 新しいネイティブ機能は、Kotlin側に `plugins/XxxPlugin.kt` を追加して `MainActivity` で登録し、Dart側は対応する `features/xxx/` を追加する
- Kotlinの処理は原則メインスレッドのまま、待ちは Coroutines の suspend 関数で書く。重い処理(通信・ファイル・DB)だけ `withContext(Dispatchers.IO)` に逃がす
- Kotlin側のエラーは `result.error(...)` で返し、Dart側で `PlatformException` として受ける
