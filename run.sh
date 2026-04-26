#!/bin/bash
set -euo pipefail

SERVICE_NAME="$1"
RELEASE_VERSION="$2"

# 1. Setup paths
# Extract the version (e.g., v3) directly from the .proto file to stay in sync
MAJOR_VERSION=$(grep "go_package" ./${SERVICE_NAME}/${SERVICE_NAME}.proto | grep -oE 'v[0-9]+' | head -1)
OUT_DIR="golang/${SERVICE_NAME}/${MAJOR_VERSION}"

echo "Targeting Directory: $OUT_DIR"

# 2. Dependencies
sudo apt-get update && sudo apt-get install -y protobuf-compiler
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
export PATH="$PATH:$(go env GOPATH)/bin"

# 3. Generate
protoc \
  --go_out=. \
  --go_opt=module=github.com/Yusufdot101/ripple-proto \
  --go-grpc_out=. \
  --go-grpc_opt=module=github.com/Yusufdot101/ripple-proto \
  ./${SERVICE_NAME}/*.proto

# 4. Initialize Module in the ACTUAL output directory
if [ -d "$OUT_DIR" ]; then
    pushd "$OUT_DIR"
    
    # Initialize if go.mod doesn't exist
    if [ ! -f "go.mod" ]; then
        echo "Initializing go module in $OUT_DIR"
        go mod init "github.com/Yusufdot101/ripple-proto/golang/${SERVICE_NAME}/${MAJOR_VERSION}"
    fi
    
    go mod tidy
    popd
else
    echo "Error: Generation directory $OUT_DIR was not created. Check your proto go_package option."
    exit 1
fi

# 5. Git Sync
git config --global user.email "github-actions@github.com"
git config --global user.name "github-actions"

git add .
# Avoid empty commit errors
git commit -m "chore: generate ${SERVICE_NAME} stubs (${RELEASE_VERSION})" || echo "No changes to commit"
git push origin HEAD:main

# Tagging
TAG_NAME="golang/${SERVICE_NAME}/${RELEASE_VERSION}"
git tag -f "$TAG_NAME"
git push origin "$TAG_NAME" --force
