#!/bin/sh
set -e

REPO="__REPO__"

OS=$(uname -s)
ARCH=$(uname -m)

case "${OS}-${ARCH}" in
  Linux-x86_64)   PLATFORM="Linux-64bit" ;;
  Linux-aarch64)  PLATFORM="Linux-ARM64" ;;
  Linux-armv*)    PLATFORM="Linux-ARM" ;;
  Linux-i686|Linux-i386) PLATFORM="Linux-32bit" ;;
  Darwin-x86_64)  PLATFORM="macOS-64bit" ;;
  Darwin-arm64)   PLATFORM="macOS-ARM64" ;;
  *) echo "Unsupported platform: ${OS}-${ARCH}"; exit 1 ;;
esac

TAG=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
  | grep '"tag_name"' \
  | sed 's/.*"tag_name": *"\(.*\)".*/\1/')
[ -z "$TAG" ] && { echo "Could not determine latest release"; exit 1; }

URL="https://github.com/${REPO}/releases/download/${TAG}/croc_${TAG}_${PLATFORM}.tar.gz"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "Downloading croc ${TAG} (${PLATFORM})..."
curl -fsSL "$URL" | tar -xz -C "$TMP"

if [ -w "/usr/local/bin" ]; then
  DEST="/usr/local/bin"
else
  DEST="${HOME}/.local/bin"
  mkdir -p "$DEST"
fi

cp "$TMP/croc" "$DEST/croc"
chmod +x "$DEST/croc"
echo "Installed croc ${TAG} -> ${DEST}/croc"
