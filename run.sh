#!/bin/bash
set -e

SERVICE_NAME=$1
RELEASE_VERSION=$2

echo "Generating for service: $SERVICE_NAME, version: $RELEASE_VERSION"

# install deps
sudo apt-get update
sudo apt-get install -y protobuf-compiler

go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

export PATH="$PATH:$(go env GOPATH)/bin"

# -------------------------
# version handling
# -------------------------
MAJOR_VERSION=$(echo "$RELEASE_VERSION" | grep -oE '^v[0-9]+' || true)

OUT_DIR="golang/${SERVICE_NAME}"

if [ "$MAJOR_VERSION" != "v1" ] && [ -n "$MAJOR_VERSION" ]; then
  OUT_DIR="golang/${SERVICE_NAME}/${MAJOR_VERSION}"
fi

echo "Output dir: $OUT_DIR"

mkdir -p "$OUT_DIR"

# -------------------------
# generate code
# -------------------------
protoc \
  --go_out="$OUT_DIR" \
  --go_opt=paths=source_relative \
  --go-grpc_out="$OUT_DIR" \
  --go-grpc_opt=paths=source_relative \
  ./${SERVICE_NAME}/*.proto

# -------------------------
# go module init
# -------------------------
cd "$OUT_DIR"

if [ ! -f "go.mod" ]; then
    MODULE_PATH="github.com/Yusufdot101/ripple-proto/golang/${SERVICE_NAME}"

    if [ "$MAJOR_VERSION" != "v1" ] && [ -n "$MAJOR_VERSION" ]; then
      MODULE_PATH="${MODULE_PATH}/${MAJOR_VERSION}"
    fi

    go mod init "$MODULE_PATH"
fi

go mod tidy
cd - >/dev/null

# -------------------------
# git commit
# -------------------------
git config --global user.email "github-actions@github.com"
git config --global user.name "github-actions"

git add .

git commit -m "chore: generate ${SERVICE_NAME} proto (${RELEASE_VERSION})" || echo "No changes to commit"

git push origin HEAD:main

# -------------------------
# tag
# -------------------------
TAG_NAME="golang/${SERVICE_NAME}/${RELEASE_VERSION}"

git tag -f "$TAG_NAME" -m "$TAG_NAME"
git push origin "refs/tags/$TAG_NAME" --force

echo "✅ Done: $TAG_NAME"
