 <div align="center">
 〰️ Ripple Proto

**API contracts for Ripple — chat service definitions for all clients.**

</div>

---

## 🌊 What is this repo?

This repository contains the **`.proto` files** that define how all Ripple services communicate. It’s the single source of truth for messages, chats, users, and events.

> Think of this as the contract between the server and any client — whether it’s Go, React, or something else.

---

## ✨ Why a separate proto repo?

- Keep **API definitions** independent of implementation.
- Generate **client/server stubs** in multiple languages.
- Enable **versioning per service**, so updates don’t break clients.
- Automate code generation for faster development.

---

## 📦 Services

Each service has its own folder with `.proto` files:

ripple-proto/

├── chat<br>
│ └── chat.proto <br>
├── user/<br>
│ └── user.proto<br>
└── golang/<br>
├──── chat/<br>
├────user/<br>

- `.proto` files live in the root service folders (`chat/`, `user/`, etc.)
- Generated code for Go clients lives in `golang/<service>/`

---

## 🚀 Generating Code

You can generate Go stubs from `.proto` files using:

```bash
# example for chat service
protoc --go_out=./golang --go_opt=paths=source_relative \
       --go-grpc_out=./golang --go-grpc_opt=paths=source_relative \
       ./chat/*.proto
```

After generating, each service is a Go module so clients can import:

```
go get github.com/Yusufdot101/ripple-proto/golang/chat@v1.0.0
```

---

## 📌 Versioning

Each service can be tagged independently:

```
git tag -a golang/chat/v1.0.0 -m "Initial chat service stub"
git push origin --tags
```

> Clients can safely pin versions or use latest for quick updates.

---

## ⚡ Automation

We use GitHub Actions to automatically:

Generate Go stubs for each service
Tag the repository per service version
Push generated code to remote

> This ensures clients always get up-to-date and consistent API code.

---

## 🤝 Contributing

PRs are welcome. For major changes, open an issue first so we can talk about it.

```bash
git switch -c feature/your-feature
git commit -m "feat: add your feature"
git push origin feature/your-feature
```

> Don’t forget to follow the folder structure for services and run code generation for Go before submitting.

---

## 📄 License

MIT — do whatever you want with it.

---

<div align="center">
  Built with ☕ and too many WebSocket debugging sessions.
</div>
