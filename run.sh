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

# ensure PATH includes Go bin
export PATH="$PATH:$(go env GOPATH)/bin"

# ensure output directory exists
mkdir -p golang/${SERVICE_NAME}
# generate code
protoc \
  --go_out=./golang \
  --go_opt=paths=source_relative \
  --go-grpc_out=./golang \
  --go-grpc_opt=paths=source_relative \
  ./${SERVICE_NAME}/*.proto

# init module if not exists
cd golang/${SERVICE_NAME}

if [ ! -f "go.mod" ]; then
  go mod init github.com/Yusufdot101/ripple-proto/golang/${SERVICE_NAME}
fi

go mod tidy
cd ../../

# git config
git config --global user.email "github-actions@github.com"
git config --global user.name "github-actions"

# commit changes (if any)
git add .

# commit might fail if nothing changed — that's fine
git commit -m "chore: generate ${SERVICE_NAME} proto (${RELEASE_VERSION})" || echo "No changes to commit"

git push origin HEAD:main

# create/update tag
TAG_NAME="golang/${SERVICE_NAME}/${RELEASE_VERSION}"

git tag -f "$TAG_NAME" -m "$TAG_NAME"

# push tag
git push origin "refs/tags/$TAG_NAME" --force

echo "✅ Done: $TAG_NAME"
