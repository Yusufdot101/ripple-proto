#!/bin/bash
set -euo pipefail

SERVICE_NAME="$1"
RELEASE_VERSION="$2"

echo "Generating for service: $SERVICE_NAME, version: $RELEASE_VERSION"

sudo apt-get update
sudo apt-get install -y protobuf-compiler

go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

export PATH="$PATH:$(go env GOPATH)/bin"

# Generate directly into the repo tree, using the repo root as the module prefix.
protoc \
  --go_out=. \
  --go_opt=module=github.com/Yusufdot101/ripple-proto \
  --go-grpc_out=. \
  --go-grpc_opt=module=github.com/Yusufdot101/ripple-proto \
  ./${SERVICE_NAME}/*.proto

# Keep the generated Go code as its own module.
OUT_DIR="golang/${SERVICE_NAME}/v2"
mkdir -p "$OUT_DIR"

cd "$OUT_DIR"

if [ ! -f "go.mod" ]; then
  go mod init github.com/Yusufdot101/ripple-proto/golang/${SERVICE_NAME}/v2
fi

go mod tidy
cd - >/dev/null

git config --global user.email "github-actions@github.com"
git config --global user.name "github-actions"

git add -A
git commit -m "chore: generate ${SERVICE_NAME} proto (${RELEASE_VERSION})" || echo "No changes to commit"

git push origin HEAD:main

TAG_NAME="golang/${SERVICE_NAME}/${RELEASE_VERSION}"
git tag -f "$TAG_NAME" -m "$TAG_NAME"
git push origin "refs/tags/$TAG_NAME" --force

echo "✅ Done: $TAG_NAME"
