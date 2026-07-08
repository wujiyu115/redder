#!/usr/bin/env bash
#
# 打包未签名 iOS ipa（用于自签 / 侧载 / AltStore 等场景）。
#
# 用法:
#   ./build_ios.sh            # release 模式打包未签名 ipa
#   ./build_ios.sh --debug    # debug 模式
#   ./build_ios.sh --clean    # 打包前先 flutter clean
#
# 产物: build/ios/ipa/reeder-unsigned.ipa
#
set -euo pipefail

# ── 参数解析 ─────────────────────────────────────────────
BUILD_MODE="release"
DO_CLEAN=0
for arg in "$@"; do
  case "$arg" in
    --debug)   BUILD_MODE="debug" ;;
    --profile) BUILD_MODE="profile" ;;
    --release) BUILD_MODE="release" ;;
    --clean)   DO_CLEAN=1 ;;
    *) echo "未知参数: $arg"; exit 1 ;;
  esac
done

# ── 前置检查 ─────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  echo "错误: iOS 打包只能在 macOS 上进行。" >&2
  exit 1
fi
if ! command -v flutter >/dev/null 2>&1; then
  echo "错误: 找不到 flutter，请确认已安装并加入 PATH。" >&2
  exit 1
fi

# 切到脚本所在目录（项目根目录）
cd "$(dirname "$0")"

APP_NAME="Runner"
OUTPUT_DIR="build/ios/ipa"
OUTPUT_IPA="$OUTPUT_DIR/reeder-unsigned.ipa"
APP_PATH="build/ios/iphoneos/${APP_NAME}.app"

echo "==> 构建模式: ${BUILD_MODE}（未签名）"

# ── 构建 ─────────────────────────────────────────────────
if [[ "$DO_CLEAN" == "1" ]]; then
  echo "==> flutter clean"
  flutter clean
fi

echo "==> flutter pub get"
flutter pub get

echo "==> flutter build ios --${BUILD_MODE} --no-codesign"
flutter build ios "--${BUILD_MODE}" --no-codesign

if [[ ! -d "$APP_PATH" ]]; then
  echo "错误: 未找到 ${APP_PATH}，构建可能失败。" >&2
  exit 1
fi

# ── 组装 ipa ─────────────────────────────────────────────
echo "==> 组装未签名 ipa"
STAGE_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGE_DIR"' EXIT

mkdir -p "$STAGE_DIR/Payload"
cp -R "$APP_PATH" "$STAGE_DIR/Payload/"

mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_IPA"

# 在 Payload 的父目录里压缩，保证 ipa 内部结构为 Payload/Runner.app
( cd "$STAGE_DIR" && zip -qr -X "ipa.zip" "Payload" )
mv "$STAGE_DIR/ipa.zip" "$OUTPUT_IPA"

SIZE="$(du -h "$OUTPUT_IPA" | cut -f1)"
echo ""
echo "✅ 打包完成"
echo "   路径: ${OUTPUT_IPA}"
echo "   大小: ${SIZE}"
echo ""
echo "提示: 这是未签名 ipa，需自行用签名工具 (如 Sideloadly / AltStore / codesign) 签名后安装。"
