@echo off
setlocal EnableExtensions
cd /d "%~dp0.."

echo ========================================
echo  Luna - Production Build (Tauri / Windows)
echo ========================================
echo.

where node >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Node.js が見つかりません。Node.js 20+ をインストールしてください。
  exit /b 1
)

where cargo >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Rust / cargo が見つかりません。rustup で安定版をインストールしてください。
  exit /b 1
)

if not exist "package.json" (
  echo [ERROR] package.json がありません。実装スケルトン導入後に再実行してください。
  echo         仕様: plan\09-build-packaging.md
  exit /b 1
)

if not exist "src-tauri\Cargo.toml" (
  echo [ERROR] src-tauri\Cargo.toml がありません。Tauri プロジェクト導入後に再実行してください。
  exit /b 1
)

if not exist "node_modules\" (
  echo [INFO] 依存関係をインストールします...
  call npm install
  if errorlevel 1 (
    echo [ERROR] npm install に失敗しました。
    exit /b 1
  )
)

if not exist "release\" (
  mkdir "release"
)

echo [INFO] tauri build を実行します（Windows exe / NSIS）...
call npm run tauri build
set "EXIT_CODE=%ERRORLEVEL%"
if not "%EXIT_CODE%"=="0" (
  echo [ERROR] ビルドに失敗しました。exit code=%EXIT_CODE%
  exit /b %EXIT_CODE%
)

echo [OK] ビルド完了。
echo      成果物: src-tauri\target\release\bundle\
exit /b 0
