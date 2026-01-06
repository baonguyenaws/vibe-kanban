# AI Coding 指南 (AGENTS.md)

本文档旨在为 AI 编程助手提供关于本项目的上下文、结构和开发规范，以便更准确地协助进行代码修改和维护。

## 1. 项目概览

本项目 (`vibe-kanban-in-docker`) 旨在提供一个便捷的 Docker 环境来运行 [Vibe Kanban](https://www.vibekanban.com/)。项目支持多种构建方式（Node 基础镜像或 Ubuntu 基础镜像），并提供了 Docker Compose 和 Shell 脚本两种启动方式。

## 2. 文件结构与职责

- **`Makefile`**: 项目的主要管理入口。包含构建镜像、运行容器、停止容器、清理环境（含卷）、查看日志、进入 Shell 等常用命令。
  - *注意*: `make build` 是交互式的，会提示用户选择 Dockerfile。
- **`docker-compose.yml`**: 推荐的启动方式。定义了服务配置、卷挂载（持久化数据、项目目录、Git 配置）和端口映射。
- **`docker-cli.sh`**: 一个快速启动脚本，封装了 `docker run` 命令。用于在不使用 Docker Compose 的情况下快速测试或部署。
- **`Dockerfile.node`**: 基于 Node.js 镜像的构建文件。
- **`Dockerfile.ubuntu`**: 基于 Ubuntu 镜像的构建文件。
- **`README.md`**: 用户文档，包含快速开始、配置说明（挂载路径、Git 认证等）。

## 3. 开发与运维指南

### 构建镜像
由于存在两个 Dockerfile，构建过程需要指定目标：
- **手动构建**:
  ```bash
  docker build -f Dockerfile.node -t vibe-kanban:dev .
  # 或
  docker build -f Dockerfile.ubuntu -t vibe-kanban:dev .
  ```
- **通过 Makefile 构建** (交互式):
  ```bash
  make build
  # AI 提示: 在非交互式环境中执行任务时，避免直接调用交互式的 make build，除非能够处理 stdin 输入。
  ```

### 运行容器
- **开发模式**: `make run` (会先清理旧容器)。
- **Docker Compose**: `docker-compose up -d` (支持更丰富的配置，如卷挂载)。
- **Shell 脚本**: `./docker-cli.sh` (便于快速重置环境)。

### 常用操作
- **停止容器**: `make stop` (仅停止，不删除容器)
- **清理环境**: `make clean` (停止并删除容器，**同时删除** `vibe-kanban-npm-cache` 卷)
- **查看日志**: `make logs`
- **进入容器**: `make shell`

## 4. AI 编码注意事项

1.  **配置同步**: 
    - 如果你修改了 `docker-compose.yml` 中的默认环境变量或挂载路径，请检查 `docker-cli.sh` 是否也需要更新，以保持两种启动方式的一致性。
    - 新增的环境变量（如 API Key）应在 `README.md` 中进行说明。

2.  **多架构/多基础镜像支持**:
    - 在修改构建逻辑时，请同时考虑 `Dockerfile.node` 和 `Dockerfile.ubuntu`。如果修改仅适用于特定基础镜像，请在注释中明确说明。

3.  **持久化数据**:
    - 注意 `.npm` 缓存和项目目录的挂载。在建议用户修改挂载路径时，优先推荐修改 `docker-compose.yml` 中的 `.env` 变量（如果有）或直接修改 `volumes` 部分。

4.  **安全隐患**:
    - 不要在代码中硬编码 API Key（如 OpenAI Key）。始终通过环境变量传递，并在文档中指导用户如何设置。
